//
//  LocationModel.swift
//  Carzly
//
//  Created by Zuhair Hussain on 24/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import Foundation

class LocationModel {
    var formattAdaddress = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var country = ""
    var placeId = ""
    
    init() {}
    init(prediction: NSDictionary) {
        formattAdaddress = prediction.string(for: "description")
        country = (prediction["terms"] as? [NSDictionary])?.last?.string(for: "value") ?? ""
        if country == "" {
            country = formattAdaddress.components(separatedBy: ",").last?.trimmed ?? ""
        }
        placeId = prediction.string(for: "place_id")
    }
}




// MARK: - Utility Methods
extension LocationModel {
    func getDetail(completion: @escaping () -> Void) {
        LocationManager.shared.getPlaceDetail(placeId: placeId) { (location, status) in
            self.latitude = location.latitude
            self.longitude = location.longitude
            
            completion()
        }
    }
}


