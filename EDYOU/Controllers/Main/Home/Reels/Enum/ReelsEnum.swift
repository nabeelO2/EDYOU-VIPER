//
//  ReelsEnum.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/08/2022.
//

import Foundation
import UIKit

enum ReelsType: Int {
    case following = 1
    case forYou
    case category
}

enum ReelsCategories: Int , CaseIterable {
case categories
case actionCategory
case anime
case childrenFamily
case comedies
case crime
case documentries
case dramas
case fantasy
case horror
case reality
case romance
case standups
case thrillers
    
    var description : String {
        switch self {
        case .actionCategory:
            return "Action"
        case .childrenFamily:
            return "Children&Family"
        case .standups:
            return "Stand-Up"
        default:
            return String(describing: self).capitalizingFirstLetter()
        }
    }
}

enum ReelsPostOptions: Int, CaseIterable {
    case privacy
    case categories
    case allowComments
    case saveToGallery
    case location
    
    var title: String {
        switch self {
        case .privacy:
            return "Who can watch this video"
        case .categories:
            return "Categories"
        case .allowComments:
            return "Allow Comments"
        case .saveToGallery:
            return "Save to Gallery"
        case .location:
            return "Location"
        }
    }
    
    var isSwitch: Bool {
        switch self {
        case .privacy, .categories,.location:
            return false
        case .allowComments,.saveToGallery:
            return true
        }
    }
    
    var filterType: FilterType {
        switch self {
        case .privacy, .categories,.location:
            return FilterType.dropdown
        case .allowComments,.saveToGallery:
            return FilterType.boolean
        }
    }
    var defaultValue: String {
        switch self {
        case .privacy:
            return ReelsPrivacy.public.description
        case .categories:
            return " Choose category"
        case .location:
            return "Anywhere"
        default:
            return ""
            
        }
    }
    
    var image: UIImage {
        return UIImage(named: "icon-map-pin")!
    }
    var subOptions: [String] {
        switch self {
        case .privacy:
            return ReelsPrivacy.allCases.map({$0.description})
        case .categories:
            return ReelsCategories.allCases.map { $0.description }
        case .allowComments:
            return []
        case .saveToGallery:
            return []
        case .location:
            return StaticData.shared.cities
        }
    }
}

enum ReelsPrivacy: Int, CaseIterable {
    case `public`
    case friends
    
    var description: String {
        switch self {
        case .public:
            return "Everyone"
        case .friends:
            return "Friends"
        }
    }
    var serverValue: String {
        return String(describing: self)
    }
}
