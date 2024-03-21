//
//  NotificationSenderName.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class NotificationSenderName : Codable {
    let firstName : String?
    let lastName : String?
    let middleName : String?
    let nickName : String?
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case nickName = "nick_name"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        middleName = try values.decodeIfPresent(String.self, forKey: .middleName)
        nickName = try values.decodeIfPresent(String.self, forKey: .nickName)
    }
}
