//
//  EventLocation.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class EventLocation: Codable {
    var city, country, countryCode: String?
    var latitude: Double?
    var locatedIn: String?
    var longitude: Double?
    var locationName, region, state, street: String?
    var zipCode, placeName: String?

    var completeAddress: String {
        var address = ""
        if let locName = self.locationName {
            address += locName
        }
        
        if let locCity = self.city {
            address += ", " + locCity
        }
        
        if let locCountry = self.country {
            address += ", " + locCountry
        }
        return address == "" ? "No Address" : address
    }
    
    enum CodingKeys: String, CodingKey {
        case city, country
        case countryCode = "country_code"
        case latitude
        case locatedIn = "located_in"
        case longitude
        case locationName = "location_name"
        case region, state, street
        case zipCode = "zip_code"
        case placeName = "place_name"
    }
}
