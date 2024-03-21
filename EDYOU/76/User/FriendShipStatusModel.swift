//
//  FriendShipStatusModel.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class FriendShipStatusModel: Codable {
    var friendID: String?
    var friendRequestStatus: FriendShipStatus?
    var requestOrigin: FriendRequestOrigin?
    
    //    var friendRequestStatus: FriendShipStatus? {
    //        return FriendShipStatus(rawValue: requestStatus ?? "")
    //    }
    
    enum CodingKeys: String, CodingKey {
        case friendID = "friend_id"
        case friendRequestStatus = "friend_request_status"
        case requestOrigin = "request_origin"
        //        case friend_request_status
    }
    
    
    init(friendID: String?, friendRequestStatus: FriendShipStatus?, requestOrigin: FriendRequestOrigin) {
        self.friendID = friendID
        self.friendRequestStatus = friendRequestStatus
        self.requestOrigin = requestOrigin
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)    
        friendID = try container.decode(String.self, forKey: .friendID)
        let requestStatus = (try? container.decode(String.self, forKey: .friendRequestStatus)) ?? "Default Value"
        friendRequestStatus = FriendShipStatus(rawValue: requestStatus) ?? FriendShipStatus.none
        
        let origin = (try? container.decode(String.self, forKey: .requestOrigin)) ?? "Default Value"
        requestOrigin = FriendRequestOrigin(rawValue: origin)
    }
}
