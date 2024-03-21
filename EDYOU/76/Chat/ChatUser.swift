//
//  ChatUser.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation


 class ChatUser {
   
    
    var user: User?
    var chatRoom: ChatRoom?
    
    internal init(user: User? = nil, chatRoom: ChatRoom? = nil) {
        self.user = user
        self.chatRoom = chatRoom
    }
    
}


extension Array where Element == User {
    var chatUsers: [ChatUser] {
        let u = self.map {
            ChatUser(user: $0, chatRoom: nil)
        }
        return u
    }
}

extension Array where Element == ChatRoom {
    
    func contains(userId: String) -> Bool {
        
        for room in self {
            let isContain = room.membersInfo.contains(where: { $0.userID == userId })
            
            if isContain == true {
                return true
            }
            
        }
        return false
    }
    
}

