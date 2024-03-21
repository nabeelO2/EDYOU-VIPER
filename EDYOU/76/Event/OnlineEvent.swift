//
//  OnlineEvent.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class OnlineEvent: Codable {
    var eventFormat, onlineEventThirdPartyURL: String?

    enum CodingKeys: String, CodingKey {
        case eventFormat = "event_format"
        case onlineEventThirdPartyURL = "online_event_third_party_url"
    }
}
