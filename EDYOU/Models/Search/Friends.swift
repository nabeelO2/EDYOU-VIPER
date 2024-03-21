//
//  Friends.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class SearchFriends: Codable {
    let friends, pendingFriends, rejectedFriends, blockedusers: [User]?
    enum CodingKeys: String, CodingKey {
        case friends
        case pendingFriends = "pending_friends"
        case rejectedFriends = "rejected_friends"
        case blockedusers = "blocked_users"
    }
}
