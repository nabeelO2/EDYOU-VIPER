//
//  GroupFriend.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class GroupFriends: Codable {
    var joined: [User]?
    var pending: [User]?
    var invited: [User]?
    var blocked: [User]?
    var notJoined: [User]?
    
    internal init(joined: [User]? = nil, pending: [User]? = nil, invited: [User]? = nil, blocked: [User]? = nil, notJoined: [User]? = nil) {
        self.joined = joined
        self.pending = pending
        self.invited = invited
        self.blocked = blocked
        self.notJoined = notJoined
    }
    
    enum CodingKeys: String, CodingKey {
        case joined, pending, invited, blocked
        case notJoined = "not_joined"
    }
}
