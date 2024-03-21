//
//  UserAddress.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class UserAddress: Object, Codable {
    
    @objc dynamic var type, streetAddress, addressLocality, addressRegion: String?
    @objc dynamic var postalCode, addressCountry: String?
    
    internal init(type: String?, streetAddress: String?, addressLocality: String?, addressRegion: String?, postalCode: String?, addressCountry: String?) {
        self.type = type
        self.streetAddress = streetAddress
        self.addressLocality = addressLocality
        self.addressRegion = addressRegion
        self.postalCode = postalCode
        self.addressCountry = addressCountry
    }
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case streetAddress = "street_address"
        case addressLocality = "address_locality"
        case addressRegion = "address_region"
        case postalCode = "postal_code"
        case addressCountry = "address_country"
    }
}
