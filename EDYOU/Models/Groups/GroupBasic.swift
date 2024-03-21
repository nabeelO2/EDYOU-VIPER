//
//  GroupBasic.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
class GroupBasic: Codable {
    
    let groupMembers: [String]?
    let groupOwnerID: String?
    let groupAdmins: [String]?
    let groupID, groupName, groupDataDescription, groupTabName: String?
    let privacy, groupActiveStatus, joinSetting, purpose: String?
    let groupIcon: String?
    let recievedRequests : [RequestMember]?

    enum CodingKeys: String, CodingKey {
        case groupMembers = "group_members"
        case groupOwnerID = "group_owner_id"
        case groupAdmins = "group_admins"
        case groupID = "group_id"
        case groupName = "group_name"
        case groupDataDescription = "description"
        case groupTabName = "group_tab_name"
        case privacy
        case groupActiveStatus = "group_active_status"
        case joinSetting = "join_setting"
        case purpose
        case groupIcon = "group_icon"
        case recievedRequests = "received"
    }
    
    internal init(groupMembers: [String]?, groupOwnerID: String?, groupAdmins: [String]?, groupID: String?, groupName: String?, groupDataDescription: String?, groupTabName: String?, privacy: String?, groupActiveStatus: String?, joinSetting: String?, purpose: String?, groupIcon: String?,recievedRequests: [RequestMember]? = nil) {
        self.groupMembers = groupMembers
        self.groupOwnerID = groupOwnerID
        self.groupAdmins = groupAdmins
        self.groupID = groupID
        self.groupName = groupName
        self.groupDataDescription = groupDataDescription
        self.groupTabName = groupTabName
        self.privacy = privacy
        self.groupActiveStatus = groupActiveStatus
        self.joinSetting = joinSetting
        self.purpose = purpose
        self.groupIcon = groupIcon
        self.recievedRequests = recievedRequests
    }
    
    var group: Group {
         var g = Group(groupID: groupID, groupName: groupName, groupDescription: groupDataDescription, groupTabName: groupTabName, privacy: privacy, groupActiveStatus: groupActiveStatus, joinSetting: joinSetting, purpose: purpose, groupIcon: groupIcon, groupMembers: [], groupOwner: nil, groupAdmins: [], groupPosts: nil)
        
        let m = (self.groupMembers ?? []).map { strId -> User in
            let u = User.nilUser
            u.userID = strId
            return u
        }
        g.groupMembers = m
        let a = (self.groupAdmins ?? []).map { strId -> User in
            let u = User.nilUser
            u.userID = strId
            return u
        }
        g.groupAdmins = a
        let owener = User.nilUser
        owener.userID = groupOwnerID ?? ""
        g.groupOwner = owener
        g.requestMembers = self.recievedRequests
        return g
    }
}

struct RequestMember : Codable {
    let status : String?
    let userID : String?
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case userID = "user_id"
    }
}
