//
//  ActiveUser.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift
// MARK: - ActiveUsers
 class ActiveUsers: Codable {
  
     var activeUsers: [User]?

    internal init(activeUsers: [User]? = nil) {
        self.activeUsers = activeUsers
    }
    
   
    
    enum CodingKeys: String, CodingKey {
        case activeUsers = "active_users"
    }
}
