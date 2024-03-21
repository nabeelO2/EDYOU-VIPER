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
    var events: Events?
}
