//
//  Notification.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class Notifications : Codable {
    let status_code : Int?
    let success : Bool?
    let detail : String?
    let data : [NotificationData]?

    enum CodingKeys: String, CodingKey {

        case status_code = "status_code"
        case success = "success"
        case detail = "detail"
        case data = "data"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status_code = try values.decodeIfPresent(Int.self, forKey: .status_code)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        detail = try values.decodeIfPresent(String.self, forKey: .detail)
        data = try values.decodeIfPresent([NotificationData].self, forKey: .data)
    }
}
