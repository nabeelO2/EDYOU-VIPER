//
//  Phone.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class Phone: Object, Codable {
    @objc dynamic var phoneNumber: String?
    @objc dynamic  var phoneVerified : Bool = false
    @objc dynamic var  isPrimary: Bool = false
    
    internal init(phoneNumber: String?, phoneVerified: Bool?, isPrimary: Bool?) {
        self.phoneNumber = phoneNumber
        self.phoneVerified = phoneVerified ?? false
        self.isPrimary = isPrimary ?? false
    }
    
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phone_number"
        case phoneVerified = "phone_verified"
        case isPrimary = "is_primary"
    }
}
