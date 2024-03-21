//
//  EventEnums.swift
//  EDYOU
//
//  Created by Masroor Elahi on 15/10/2022.
//

import Foundation
import UIKit

enum EventPrivacy: String {
    case `public` = "public"
    case `private` = "private"
    case friends =  "friends"
    case specificFriends = "specific"
    case specificGroup = "group"
    
    var name: String {
        switch self {
        case .public:           return "Public"
        case .friends:          return "Friends"
        case .specificFriends:  return "Specific Friends"
        case .private:          return "Private"
        case .specificGroup:    return "Specific Group"
        }
    }
    
    init?(name: String) {
        switch name {
        case "Public":
            self = .public
            break
        case "Friends":
            self = .friends
            break
        case "Private":
            self = .private
            break
        case "Specific Group":
            self = .specificGroup
            break
        case "Specific Friends":
            self = .specificFriends
        default:
            return nil
        }
    }
}

enum EventQuery: String {
    case `public` = "public"
    case specific = "specific"
    case friends = "friends"
    case group = "group"
    case me = ""
}

enum EventAction: String {
    case going = "going"
    case notGoing = "not_going"
    case maybe = "maybe"
    case interested = "interested"
    case like = "likes"
    case addAdmin = "add_admin"
    case invite = "invite"
    case leave = "leave"
    
    private var actionFilledImage: UIImage {
        switch self {
        case .going:
            return UIImage(systemName: "checkmark.circle.fill")!
        case .notGoing:
            return UIImage(systemName: "xmark.circle.fill")!
        case .interested:
            return UIImage(systemName: "star.fill")!
        default:
            return UIImage(systemName: "questionmark")!
        }
    }
    private var actionImageUnfilled: UIImage {
        switch self {
        case .going:
            return UIImage(systemName: "checkmark.circle")!
        case .notGoing:
            return UIImage(systemName: "xmark.circle")!
        case .interested:
            return UIImage(systemName: "star")!
        default:
            return UIImage(systemName: "questionmark")!
        }
    }
    func getActionImage(actionStatus: Bool) -> UIImage {
        return actionStatus ? actionFilledImage : actionImageUnfilled
    }
}

enum EventGoOutType: String {
    case anyTime = "AnyTime"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case thisWeekend = "This Weekend"
    case chooseADate = "Choose a date..."
}


enum PeopleProfileTypes: Int, CaseIterable {
    case admins
    case going
    case notGoing
    case maybe
    case interseted //Particents
    case likes
    case invited
    case notInvited
    
    static var guestListTypes: [PeopleProfileTypes] {
        return [.going,.invited,.interseted]
    }
    static var manageList: [PeopleProfileTypes] {
        return [.admins,.going,.notGoing,.maybe,.interseted,.likes,.invited]
    }
    
    var title: String {
        switch self {
        case .admins:
            return "Organisers"
        case .going:
            return "Going"
        case .notGoing:
            return "Not Going"
        case .maybe:
            return "May Be"
        case .interseted:
            return "Interested"
        case .likes:
            return "Likes"
        case .invited:
            return "Invited"
        case .notInvited:
            return "Not Invited"
        }
    }
}

enum EventCategories: String, CaseIterable {
    case beauty = "Beauty"
    case birthday = "Birthday"
    case breakfast = "Breakfast"
    case drinks = "Drinks"
    case hangouts = "Hangouts"
    case lunchDinner = "Lunch / Dinner"
    case specialOccasion = "Special Occasion"
    case sportsActivity = "Sport / Activities"
    case workMeeting = "Work Meeting"
    case other = "Other"
    case anniversary = "Anniversary"
    case travel = "Travel"
    
    var serverValues: String {
        switch self {
        case .beauty,.birthday,.drinks,.travel,.other,.hangouts,.anniversary,.breakfast:
            return String(describing: self)
        case .lunchDinner:
            return "lunch/dinner"
        case .specialOccasion:
            return "special_occasions"
        case .sportsActivity:
            return "sport_activities"
        case .workMeeting:
            return "work_meeting"
        }
    }
    init(serverValue: String) {
        switch serverValue {
        case "beauty":
            self = .beauty
        case "birthday":
            self = .birthday
        case "drinks":
            self = .drinks
        case "travel":
            self = .travel
        case "other":
            self = .other
        case "hangouts":
            self = .hangouts
        case "anniversary":
            self = .anniversary
        case "breakfast":
            self = .breakfast
        case "lunch/dinner":
            self = .lunchDinner
        case "special_occasions":
            self = .sportsActivity
        case "sport_activities":
            self = .sportsActivity
        case "work_meeting":
            self = .workMeeting
        default:
            self = .other
        }
    }
}
