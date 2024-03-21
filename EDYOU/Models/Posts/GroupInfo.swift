//
//  GroupInfo.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class GroupInfo: Codable {
    var groupID, groupName: String?
    var groupIcon: String?
    internal init(groupID: String? = nil, groupName: String? = nil, groupIcon: String? = nil) {
        self.groupID = groupID
        self.groupName = groupName
        self.groupIcon = groupIcon
    }
    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case groupIcon = "group_icon"
    }
}
