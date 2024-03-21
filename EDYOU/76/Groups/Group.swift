//
//  Group.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import Foundation

struct Group: Codable {
    var groupID, groupName, groupDescription, groupTabName: String?
    var privacy, groupActiveStatus, joinSetting, purpose: String?
    var groupIcon: String?
    var groupMembers: [User]?
    var groupOwner: User?
    var groupAdmins: [User]?
    var groupPosts: GroupsPostsData?
    var groupTags: [String?]?
    var groupJoinedStatus: String?
    var isFavorite: Bool?
    var requestMembers : [RequestMember]?
    var recievedInvitations : [User]?
    var sentInvitations : [User]?
    
    var groupJoinedStatusEnum: GroupMemberStatus {
        GroupMemberStatus(rawValue: self.groupJoinedStatus ?? "" ) ?? .defaultState
    }


    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case groupDescription = "description"
        case groupTabName = "group_tab_name"
        case privacy
        case groupActiveStatus = "group_active_status"
        case joinSetting = "join_setting"
        case purpose
        case groupIcon = "group_icon"
        case groupMembers = "group_members"
        case groupOwner = "group_owner"
        case groupAdmins = "group_admins"
        case groupPosts = "group_posts"
        case groupTags = "group_tags"
        case groupJoinedStatus = "group_joined_status"
        case isFavorite = "is_favourite"
        case recievedInvitations = "received"
        case sentInvitations = "sent"
    }
    
    func allowedToDisplayPosts() -> Bool {
        return (self.groupJoinedStatusEnum == .joined_by_me || self.groupJoinedStatusEnum == .joined_via_invite || (groupOwner?.isMe ?? false) || (self.privacy == "public"))
    }
}

extension Sequence where Element == GroupBasic {
    var groups: [Group] {
        let g = self.map { $0.group }
        return g
    }

}
