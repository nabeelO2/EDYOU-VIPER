//
//  User+Enums.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

enum AddFriendAction {
    case none, unfriend, addFriend, cancelRequest, acceptRequest
    static func from(status: FriendShipStatusModel) -> AddFriendAction {
        
        if status.friendRequestStatus == .approved {
            return .unfriend
        } else if status.friendRequestStatus == FriendShipStatus.none {
            return .addFriend
        } else if status.friendRequestStatus == FriendShipStatus.pending {
            if status.requestOrigin == .sent {
                return .cancelRequest
            } else {
                return .acceptRequest
            }
        }
        return .none
    }
    var title: String {
        
        switch self {
        case .none:             return ""
        case .unfriend:         return "Unfriend"
        case .addFriend:        return "Add Friend"
        case .cancelRequest:    return "Cancel Request"
        case .acceptRequest:    return "Accept Request"
        }
    }
}
