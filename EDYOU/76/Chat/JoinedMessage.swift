//
//  JoinedMessage.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - JoinedMessage
 class JoinedMessage: Object, Codable {
  
    
    @objc dynamic var userID, roomName, message: String?

    internal init(userID: String? = nil, roomName: String? = nil, message: String? = nil) {
        self.userID = userID
        self.roomName = roomName
        self.message = message
    }
    
     override init() {
         super.init()
     }
     
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case roomName = "room_name"
        case message
    }
}
