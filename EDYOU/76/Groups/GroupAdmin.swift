//
//  GroupAdmin.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class GroupAdminData: Codable {
    
    var groupID: String?
    var groupActiveStatus: String?
    var growth: Int?
    var joined, pending, invited, blocked,received, sent: [User]?
    var groupAdmins: [User]?
    var pendingPosts: [Post]?

    internal init(groupID: String? = nil, groupActiveStatus: String? = nil, growth: Int? = nil, joined: [User]? = nil, pending: [User]? = nil, invited: [User]? = nil, blocked: [User]? = nil, groupAdmins: [User]? = nil, pendingPosts: [Post]? = nil,received: [User]? = nil,sent: [User]? = nil) {
        self.groupID = groupID
        self.groupActiveStatus = groupActiveStatus
        self.growth = growth
        self.joined = joined
        self.pending = pending
        self.invited = invited
        self.blocked = blocked
        self.received = received
        self.sent = sent
        self.groupAdmins = groupAdmins
        self.pendingPosts = pendingPosts
    }
    
    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupActiveStatus = "group_active_status"
        case growth, joined, pending, invited, blocked,received, sent
        case groupAdmins = "group_admins"
        case pendingPosts = "pending_posts"
    }
}
