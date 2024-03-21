//
//  FavoriteCategories.swift
//  EDYOU
//
//  Created by Masroor Elahi on 13/12/2022.
//

import Foundation

enum FavoriteCategories: Int, CaseIterable, PropertyDescriptionProtocol {
    case post = 0
    case events
    case groups
   // case friends
   // case marketplace
    
    var propertyDescription: String {
        switch self {
        case .post:
            return "Posts"
        case .events:
            return "Events"
        case .groups:
            return "Groups"
//        case .friends:
//            return "Friends"
//        case .marketplace:
//            return "Marketplace"
        }
    }
    var id: String {
        return "\(self.rawValue)"
    }
}
