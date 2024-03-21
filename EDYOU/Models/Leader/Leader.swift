//
//  Leader.swift
//  EDYOU
//
//  Created by imac3 on 12/09/2023.
//

import Foundation

struct Leader: Codable {
    
    let rank: Int?
    let score: Int?
    var user: User?
    
}

struct LeaderFilter : Codable{
    var daily : [Leader]
    var weekly : [Leader]
    var monthly : [Leader]
    var all_time : [Leader]
    var yearly : [Leader]
}


enum LeaderBoardPeriodFilter : String {
    case all = "all_time"
    case weekly = "weekly"
    case daily = "daily"
    case monthly = "monthly"
    case yearly = "yearly"
    
    func getValue()->String{
        return self == .daily ? "today" : self.rawValue
    }
}


enum LeaderBoardTypeFilter : String {
    case friends = "friends"
    case school = "school"
    case national = "national"
   
}
