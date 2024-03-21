 //
//  RealmProtocols.swift
//  EDYOU
//
//  Created by Masroor Elahi on 29/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

public protocol Storable { }

extension Object: Storable { }

public struct Sorted {

    /// sort by key
    var key: String

    /// sort direction
    var ascending: Bool = true

}

enum RealmError: Error {
    case eitherRealmIsNilOrNotRealmSpecificModel
    case realmException(String)
}

extension RealmError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .eitherRealmIsNilOrNotRealmSpecificModel:
            return "Realm not found"
        case .realmException(let error):
            return error
        }
    }
}
