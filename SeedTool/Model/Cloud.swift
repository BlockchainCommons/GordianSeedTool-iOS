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

class Cloud: ObservableObject {
    @Published private(set) var accountStatus: CKAccountStatus? {
        didSet {
            isSyncing = accountStatus == .available && settings.syncToCloud == .on
        }
    }
    
    var isSyncing: Bool = false {
        didSet {
            if oldValue != isSyncing && isSyncing == true {
                startSyncing()
            }
        }
    }

    private lazy var container = CKContainer(identifier: "iCloud.com.blockchaincommons.Fehu")
    private lazy var database = container.privateCloudDatabase
    private lazy var primaryZone = CKRecordZone(zoneName: "Primary")
    private var bag = Set<AnyCancellable>()
    private let model: Model
    private let settings: Settings
    private var isMock: Bool {
        settings.isMock
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
            //print("🔥 CKAccountChanged")
            self.updateAccountStatus()
        }.store(in: &bag)
        
        settings.$syncToCloud.sink { value in
            //print("🔥 syncToCloud: \(value) isSyncing: \(self.isSyncing)")
            self.updateAccountStatus()
        }.store(in: &bag)
        
        updateAccountStatus()
    }
    
    var syncStatus: String {
        guard settings.syncToCloud == .on else {
            return "🟡 Sync to iCloud is not active."
        }
        
        switch accountStatus {
        case .available?:
            return "🟢 Sync to iCloud is active."
        case .couldNotDetermine?:
            return "🔴 Could not determine status of iCloud account."
        case .noAccount?:
            return "🔴 You are currently logged out of iCloud. No synchronization will be performed."
        case .restricted?:
            return "🔴 Use of iCloud is currently restricted by permissions settings."
        case nil:
            return "🔴 Not determined."
        @unknown default:
            return "🔴 Unknown."
        }
    }

    private func updateAccountStatus() {
        guard !isMock else {
            self.accountStatus = .available
            return
        }
        
        self.container.accountStatus { status, error in
            if let error = error {
                print("⛔️ Unable to get cloud account status: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.accountStatus = status
                    //print("🔥 CKAccountStatus: \(status)")
                }
            }
        }
    }
    
    private func startSyncing() {
        print("🔵 startSyncing")
        setupZones() {
            print("🔵 Done with setupZones: \($0)")
            //print("needsMergeWithCloud: \(self.settings.needsMergeWithCloud)")
            if self.settings.needsMergeWithCloud {
                self.model.mergeWithCloud() { result in
                    switch result {
                    case .success:
                        print("✅ mergeWithCloud")
                    case .failure(let error):
                        print("⛔️ mergeWithCloud: \(error)")
                    }
                    phase2()
                }
            } else {
                phase2()
            }
        }
        
        func phase2() {
            self.setupSubscriptions() {
                print("🔵 Done with setupSubscriptions: \($0)")
                if !self.settings.needsMergeWithCloud {
                    self.fetchChanges {
                        print("🔵 Done with fetchChanges: \($0)")
                    }
                }
            }
        }
        self.settings.needsMergeWithCloud = false
    }
    
    private func setupZones(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !UserDefaults.standard.bool(forKey: "savedPrimaryZone") else {
            completion(.success(()))
            return
        }
        database.save(primaryZone) { _, error in
            if let error = error {
                print("⛔️ Unable to save primary record zone: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Saved primary record zone")
                UserDefaults.standard.setValue(true, forKey: "savedPrimaryZone")
                completion(.success(()))
            }
        }
    }
    
    private func setupSubscriptions(completion: @escaping (Result<Void, Error>) -> Void) {
        setupSubscription(type: "Seed", subscriptionID: "seed-changes", userDefaultsKey: "hasSeedSubscription") { result in
            completion(result)
        }
    }
    
    private func setupSubscription(type: String, subscriptionID: String, userDefaultsKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !UserDefaults.standard.bool(forKey: userDefaultsKey) else {
            completion(.success(()))
            return
        }
        
        let subscription = CKRecordZoneSubscription(zoneID: primaryZone.zoneID, subscriptionID: subscriptionID)
        subscription.recordType = type
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        operation.modifySubscriptionsCompletionBlock = { subscriptions, deleted, error in
            if let error = error {
                print("⛔️ Couldn't create subscription: \(error)")
                completion(.failure(error))
            } else {
                print("✅ Saved subscription for: \(subscriptionID)")
                UserDefaults.standard.setValue(true, forKey: userDefaultsKey)
                completion(.success(()))
            }
        }
        operation.qualityOfService = .utility
        database.add(operation)
    }
    
    func decodeRecord<O>(type: O.Type, record: CKRecord) throws -> O where O: Decodable {
        guard let valueString = record.object(forKey: "value") as? String else {
            throw GeneralError("Could not retrieve value field from CloudKit record.")
        }
        guard let decodedRecord = try? JSONDecoder().decode(type, from: valueString.data) else {
            throw GeneralError("Could not decode value field in CloudKit record.")
        }
        return decodedRecord
    }
    
    func fetchAll<O>(type: String, completion: @escaping (Result<[O], Error>) -> Void) where O: Decodable {
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: primaryZone.zoneID) { records, error in
            if let error = error {
                print("⛔️ Could not fetch records of type \(type), error: \(error)")
                completion(.failure(error))
            } else {
                var decodedRecords = [O]()
                for record in records! {
                    guard let decodedRecord = try? self.decodeRecord(type: O.self, record: record) else {
                        continue
                    }
                    decodedRecords.append(decodedRecord)
                }
                completion(.success(decodedRecords))
            }
        }
    }

    func save<O>(type: String, id: UUID, object: O, completion: @escaping (Result<Void, Error>) -> Void) where O: Encodable {
        guard isSyncing else {
            completion(.success(()))
            return
        }
        
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: primaryZone.zoneID)
        database.fetch(withRecordID: recordID) { fetchedRecord, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == CKErrorDomain, nsError.code == CKError.unknownItem.rawValue {
                    // Item not found, ignore
                } else {
                    print("⛔️ Could not fetch existing record \(id) error: \(error)")
                }
            }
            let record = fetchedRecord ?? CKRecord(recordType: type, recordID: recordID)
            let value = try! JSONEncoder().encode(object)
            let valueString = value.utf8
            record.setValue(valueString, forKey: "value")
            //print("⬆️ Saving to cloud \(Date()) \(record)")
            self.database.save(record) { _, error in
                if let error = error {
                    print("⛔️ Could not save to cloud \(Date()) \(record) error: \(error)")
                    completion(.failure(error))
                } else {
                    //print("✅ Saved to cloud \(Date()) \(record)")
                    completion(.success(()))
                }
            }
        }
    }
    
    func fetch(id: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let recordID = CKRecord.ID(recordName: id, zoneID: primaryZone.zoneID)
        database.fetch(withRecordID: recordID, completionHandler: completion)
    }
    
    func delete(id: UUID) {
        let recordID = CKRecord.ID(recordName: id.uuidString, zoneID: primaryZone.zoneID)
        guard isSyncing else {
            return
        }
        database.delete(withRecordID: recordID) { _, error in
            if let error = error {
                print("⛔️ Could not delete from cloud \(Date()) \(recordID) error: \(error)")
            } else {
                //print("🟥 Deleted from cloud \(Date()) \(recordID)")
            }
        }
    }
    
    let serialQueue = DispatchQueue(label: "serial")
    
    enum Action {
        case upsert(Seed)
        case delete(UUID)
    }
    
    var actions = [Action]()
    
    private func addAction(_ action: Action) {
        serialQueue.sync {
            actions.append(action)
        }
    }
    
    func fetchChanges(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isSyncing else {
            return
        }
        
        let previousToken = primaryZoneToken
        let recordZoneIDs = [primaryZone.zoneID]
        let configurations: [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration] = [
            primaryZone.zoneID: CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: previousToken)
        ]
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: recordZoneIDs, configurationsByRecordZoneID: configurations)
        
        operation.recordChangedBlock = { record in
            //print("record changed: \(record)")
            guard record.recordType == "Seed" else {
                return
            }
            guard record.recordID.zoneID == self.primaryZone.zoneID else {
                return
            }
            guard let seed = try? self.decodeRecord(type: Seed.self, record: record) else {
                return
            }
            self.addAction(.upsert(seed))
        }
        
        operation.recordWithIDWasDeletedBlock = { recordID, recordType in
            //print("record deleted: \(recordID) \(recordType)")
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
        
        operation.recordZoneChangeTokensUpdatedBlock = { recordZoneID, token, _ in
            self.primaryZoneToken = token
        }
        
        operation.recordZoneFetchCompletionBlock = { recordZoneID, token, _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.primaryZoneToken = token
                completion(.success(()))
            }
            
            func indexForSeed(in seeds: [Seed], withID id: UUID) -> Int? {
                return seeds.firstIndex { $0.id == id }
            }
            
            let actions = self.actions
            DispatchQueue.main.async {
                withAnimation {
                    var newSeeds = self.model.seeds
                    for action in actions {
                        switch action {
                        case .upsert(let fetchedSeed):
                            fetchedSeed.isDirty = true
                            fetchedSeed.needsReplicationToCloud = false
                            if let index = indexForSeed(in: newSeeds, withID: fetchedSeed.id) {
                                newSeeds[index] = fetchedSeed
                            } else {
                                newSeeds.append(fetchedSeed)
                            }
                        case .delete(let deletedSeedID):
                            if let index = indexForSeed(in: newSeeds, withID: deletedSeedID) {
                                let deletedSeed = newSeeds[index]
                                deletedSeed.isDirty = true
                                deletedSeed.needsReplicationToCloud = false
                                newSeeds.remove(at: index)
                            }
                        }
                    }
                    newSeeds.sortByOrdinal()
                    self.model.seeds = newSeeds
                }
            }
        }
        
        operation.qualityOfService = .utility
        database.add(operation)
    }
}

extension CKAccountStatus: CustomStringConvertible {
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
