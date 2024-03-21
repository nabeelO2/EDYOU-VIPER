//
//  MyFriends.swift
//  EDYOU
//
//  Created by imac3 on 26/02/2024.
//

import Foundation
import RealmSwift

class MyFriends:Object
{
    @objc dynamic var userId: String?
    @objc dynamic var name: String?
    @objc dynamic var school: String?
    @objc dynamic var profile: String?
    @objc dynamic var status: String?
    
    
    init(userId: String? = nil, name: String? = nil, school: String? = nil, profile: String? = nil, status: String? = nil) {
        self.userId = userId
        self.name = name
        self.school = school
        self.profile = profile
        self.status = status
    }
    
    override init() {
        
    }
}

enum MyFriendShipStatus: String{
    case pending  = "2"
    case sent  = "1"
    case approved  = "3"
    case rejected = "4"
    case blocked  = "5"
}
