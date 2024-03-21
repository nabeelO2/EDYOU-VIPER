//
//  FriendRequest.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class FriendRequestSent: Codable {
    let userID, message: String?
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case message
    }
    internal init(userID: String?, message: String?) {
        self.userID = userID
        self.message = message
    }
}

class FriendRequestStatusReceived: Codable {
    let userID, friendRequestStatus: String?
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case friendRequestStatus = "friend_request_status"
    }
    internal init(userID: String?, friendRequestStatus: String?) {
        self.userID = userID
        self.friendRequestStatus = friendRequestStatus
    }
}
