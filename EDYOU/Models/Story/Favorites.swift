//
//  Favorites.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//

import Foundation

class Favorites: Codable {
    var groups: [GroupBasic]?
    var friends: [User]?
    var posts: [Post]?
    var events: FavoriteEvents?
}


class FavoriteEvents: Codable {
    var onlineEvents: [Event]?
    var inPersonEvents: [Event]?
    enum CodingKeys: String, CodingKey {
        case onlineEvents = "online_events"
        case inPersonEvents = "in_person_events"
    }
}
