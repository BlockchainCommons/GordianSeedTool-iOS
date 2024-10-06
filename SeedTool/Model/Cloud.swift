//
//  Cloud.swift
//  SeedTool
//
//  Created by Wolf McNally on 6/12/21.
//

import Foundation
import CloudKit
import Combine
import UIKit
import SwiftUI
import os
import WolfBase
import BCApp
import Observation

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "Cloud")

class Cloud: ObservableObject {
    @Published private(set) var accountStatus: CKAccountStatus? {
        didSet {
            isSyncing = accountStatus == .available && settings.syncToCloud == .on
        }
    }
    
    var isSyncing: Bool = false {
        didSet {
            if oldValue != isSyncing && isSyncing == true {
                Task {
                    try await startSyncing()
                }
            }
        }
    }

    static let container = CKContainer(identifier: "iCloud.com.blockchaincommons.Fehu")
    private lazy var database = Self.container.privateCloudDatabase
    private lazy var primaryZone = CKRecordZone(zoneName: "Primary")
    private var bag = Set<AnyCancellable>()
    private let model: Model
    private let settings: Settings
    private var isMock: Bool {
        settings.isMock
    }
    
    func removeChangeToken() {
        primaryZoneToken = nil
    }
    
    private var primaryZoneToken: CKServerChangeToken? {
        get {
            guard let data = UserDefaults.standard.value(forKey: "primaryZoneToken") as? Data else {
                return nil
            }
            
            guard let token = try! NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) else {
                return nil
            }
            
            return token
        }
        set {
            if let token = newValue {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
                UserDefaults.standard.set(data, forKey: "primaryZoneToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "primaryZoneToken")
            }
        }
    }
    
    init(model: Model, settings: Settings) {
        self.model = model
        self.settings = settings
        
        NotificationCenter.default.publisher(for: .CKAccountChanged).sink { value in
            //logger.debug("🔥 CKAccountChanged")
            self.updateAccountStatus()
        }.store(in: &bag)
        
        withObservationTracking {
            _ = settings.syncToCloud
        } onChange: {
            //logger.debug("🔥 syncToCloud: \(value) isSyncing: \(self.isSyncing)")
            self.updateAccountStatus()
        }
        
        updateAccountStatus()
    }
    
    var syncStatus: (String, String) {
        guard settings.syncToCloud == .on else {
            return ("🟡", "Sync to iCloud is not active.")
        }
        
        switch accountStatus {
        case .available?:
            return ("🟢", "Sync to iCloud is active.")
        case .couldNotDetermine?:
            return ("🔴", "Could not determine status of iCloud account.")
        case .noAccount?:
            return ("🔴", "You are currently logged out of iCloud. No synchronization will be performed.")
        case .restricted?:
            return ("🔴", "Use of iCloud is currently restricted by permissions settings.")
        case .temporarilyUnavailable?:
            return ("🔴", "Temporarily unavailable.")
        case nil:
            return ("🔴", "Not determined.")
        @unknown default:
            return ("🔴", "Unknown.")
        }
    }

    private func updateAccountStatus() {
        Task { @MainActor in
            do {
                self.accountStatus = isMock ? .available : try await Self.container.accountStatus()
            } catch {
                logger.error("⛔️ updateAccountStatus: \(error.localizedDescription)")
            }
        }
    }
    
    private func startSyncing() async throws {
        try await setupZones()
        
        if self.settings.needsMergeWithCloud {
            do {
                try await self.model.mergeWithCloud()
                logger.debug("✅ mergeWithCloud")
                try await phase2()
            } catch {
                logger.error("⛔️ mergeWithCloud: \(error.localizedDescription)")
            }
        } else {
            try await phase2()
        }
        
        func phase2() async throws {
            try await self.setupSubscriptions()
            logger.debug("🔵 Done with setupSubscriptions")
            if !self.settings.needsMergeWithCloud {
                try await self.fetchChanges()
                logger.debug("🔵 Done with fetchChanges")
            }
        }
        self.settings.needsMergeWithCloud = false
    }
    
    private func setupZones() async throws {
        guard !UserDefaults.standard.bool(forKey: "savedPrimaryZone") else {
            return
        }
        
        do {
            try await database.save(primaryZone)
        } catch {
            logger.error("⛔️ Unable to save primary record zone: \(error.localizedDescription)")
            throw error
        }

        logger.debug("✅ Saved primary record zone")
        UserDefaults.standard.setValue(true, forKey: "savedPrimaryZone")
    }
    
    private func setupSubscriptions() async throws {
        try await setupSubscription(type: "Seed", subscriptionID: "seed-changes", userDefaultsKey: "hasSeedSubscription")
    }
    
    private func setupSubscription(type: String, subscriptionID: String, userDefaultsKey: String) async throws {
        guard !UserDefaults.standard.bool(forKey: userDefaultsKey) else {
            return
        }
        
        let subscription = CKRecordZoneSubscription(zoneID: primaryZone.zoneID, subscriptionID: subscriptionID)
        subscription.recordType = type
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        do {
            _ = try await database.modifySubscriptions(saving: [subscription], deleting: [])
            UserDefaults.standard.setValue(true, forKey: userDefaultsKey)
            logger.debug("✅ Saved subscription for: \(subscriptionID)")
        } catch {
            logger.error("⛔️ Couldn't create subscription: \(error.localizedDescription)")
            throw error
        }
    }
    
    func decodeRecord<O>(type: O.Type, record: CKRecord) throws -> O where O: Decodable {
        guard let valueString = record.object(forKey: "value") as? String else {
            throw GeneralError("Could not retrieve value field from CloudKit record.")
        }
        guard let decodedRecord = try? JSONDecoder().decode(type, from: valueString.utf8Data) else {
            throw GeneralError("Could not decode value field in CloudKit record.")
        }
        return decodedRecord
    }
    
    func fetchAll<O>(type: String) async throws -> [O] where O: Decodable {
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        let (matchResults, _) = try await database.records(matching: query, inZoneWith: primaryZone.zoneID, desiredKeys: nil)
        var decodedRecords = [O]()
        for recordResult in matchResults {
            switch recordResult.1 {
            case .success(let record):
                guard let decodedRecord = try? self.decodeRecord(type: O.self, record: record) else {
                    continue
                }
                decodedRecords.append(decodedRecord)
            case .failure(let error):
                logger.error("⛔️ Could not fetch record \(recordResult.0) of type \(type), error: \(error.localizedDescription)")
            }
        }
        return decodedRecords
    }

    func save<O>(type: String, id: UUID, object: O) async throws where O: Encodable {
        guard isSyncing else {
            return
        }
        
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: primaryZone.zoneID)
        let record: CKRecord
        do {
            record = try await database.record(for: recordID)
        } catch {
            let nsError = error as NSError
            if nsError.domain == CKErrorDomain, nsError.code == CKError.unknownItem.rawValue {
                // Item not found, ignore
                record = CKRecord(recordType: type, recordID: recordID)
            } else {
                logger.error("⛔️ Could not fetch existing record \(id) error: \(error.localizedDescription)")
                throw error
            }
        }
        let value = try! JSONEncoder().encode(object)
        let valueString = value.utf8
        record.setValue(valueString, forKey: "value")
        //logger.debug("⬆️ Saving to cloud \(Date()) \(record.recordID)")
        do {
            try await self.database.save(record)
        } catch {
            logger.error("⛔️ Could not save to cloud \(Date()) \(record) error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetch(id: String) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: id, zoneID: primaryZone.zoneID)
        return try await database.record(for: recordID)
    }
    
    func delete(id: UUID) async throws {
        guard isSyncing else {
            return
        }
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: primaryZone.zoneID)
        do {
            try await database.deleteRecord(withID: recordID)
        } catch {
            logger.error("⛔️ Could not delete from cloud \(Date()) \(recordID) error: \(error.localizedDescription)")
        }
    }
    
    let serialQueue = DispatchQueue(label: "serial")
    
    enum Action {
        case upsert(ModelSeed)
        case delete(UUID)
    }
    
    var actions = [Action]()
    
    private func addAction(_ action: Action) {
        serialQueue.sync {
            actions.append(action)
        }
    }
    
    func fetchChanges() async throws {
        guard isSyncing else {
            logger.debug("☁️ fetchChanges aborted, syncing not started.")
            return
        }
        logger.debug("☁️ fetchChanges")
        do {
            try await tryFetchChanges()
        } catch {
            if let error = error as? CKError, error.code == .changeTokenExpired {
                logger.debug("⚠️ Change token expired. Retrying.")
                removeChangeToken()
                try await tryFetchChanges()
            }
        }
    }
    
    private func tryFetchChanges() async throws {
        let (modificationResultsByID, deletions, changeToken, _) = try await database.recordZoneChanges(inZoneWith: primaryZone.zoneID, since: primaryZoneToken)
        
        for (recordID, result) in modificationResultsByID {
            switch result {
            case .success(let modification):
                let record = modification.record
                logger.debug("🔶 record changed: \(record.recordID)")
                guard record.recordType == "Seed" else {
                    continue
                }
                guard record.recordID.zoneID == self.primaryZone.zoneID else {
                    continue
                }
                guard let seed = try? self.decodeRecord(type: ModelSeed.self, record: record) else {
                    continue
                }
                self.addAction(.upsert(seed))
            case .failure(let error):
                logger.debug("⛔️ Error changing record \(Date()) \(recordID) error: \(error.localizedDescription)")
            }
        }
        
        for deletion in deletions {
            let recordID = deletion.recordID
            let recordType = deletion.recordType
            logger.debug("🔶 record deleted, id: \(recordID) type: \(recordType)")
            guard recordType == "Seed" else {
                return
            }
            guard recordID.zoneID == self.primaryZone.zoneID else {
                return
            }
            guard let id = UUID(uuidString: recordID.recordName) else {
                return
            }
            self.addAction(.delete(id))
        }
        
        logger.debug("🔶 tokens updated: \(String(describing: changeToken))")
        self.primaryZoneToken = changeToken

        func indexForSeed(in seeds: [ModelSeed], withID id: UUID) -> Int? {
            return seeds.firstIndex { $0.id == id }
        }

        withAnimation {
            var newSeeds = self.model.seeds
            for (_ /*actionIndex*/, action) in actions.enumerated() {
                switch action {
                case .upsert(let fetchedSeed):
                    fetchedSeed.isDirty = true
                    if let index = indexForSeed(in: newSeeds, withID: fetchedSeed.id) {
                        newSeeds.remove(at: index)
                        //logger.debug("🔥 \(actionIndex) update \(fetchedSeed.id)")
                    } else {
                        //logger.debug("🔥 \(actionIndex) insert \(fetchedSeed.id)")
                    }
                    newSeeds.append(fetchedSeed)
                case .delete(let deletedSeedID):
                    if let index = indexForSeed(in: newSeeds, withID: deletedSeedID) {
                        let deletedSeed = newSeeds[index]
                        //logger.debug("🔥 \(actionIndex) delete \(deletedSeed.id) at \(index)")
                        deletedSeed.isDirty = true
                        newSeeds.remove(at: index)
                    }
                }
            }
            newSeeds.sortByOrdinal()
            self.model.setSeeds(newSeeds, replicateToCloud: false)
            self.actions.removeAll()
        }
    }
}

extension CKAccountStatus: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .available:
            return "available"
        case .couldNotDetermine:
            return "couldNotDetermine"
        case .noAccount:
            return "noAccount"
        case .restricted:
            return "restricted"
        case .temporarilyUnavailable:
            return "temporarilyUnavailable"
        @unknown default:
            fatalError()
        }
    }
}

extension CKRecord.ID {
    convenience init(recordName: UUID) {
        self.init(recordName: recordName.uuidString)
    }
}
