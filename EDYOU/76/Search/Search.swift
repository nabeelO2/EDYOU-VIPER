//
//  Search.swift
//  EDYOU
//
//  Created by  Mac on 13/09/2021.
//

import Foundation

// MARK: - User
class SearchResults: Codable {
    var people: [User]?
    var groups: [GroupBasic]?
    var friends: [User]?
    var posts: [Post]?
    var events: [EventBasic]?
}
