//
//  ModelObject.swift
//  Fehu
//
//  Created by Wolf McNally on 12/15/20.
//

import Foundation
import LifeHash
import URKit

protocol ModelObject: Fingerprintable, ObservableObject {
    static var modelObjectType: ModelObjectType { get }
    var name: String { get }
    var ur: UR { get }
}
