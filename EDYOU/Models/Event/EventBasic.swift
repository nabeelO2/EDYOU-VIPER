//
//  EventBasic.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventBasic: Codable {
    
    var eventID, ownerID, eventType, eventName: String?
    var eventDescription, startTime, endTime, dressCode, inviterName, meetingLink: String?
    var eventCategory: String?
    var eventPrivacy: String?
    var guestListVisible, anyoneCanInvite: Bool?
    var coverImages: [String]?
   // var onlineEvent: OnlineEvent?
    var location: EventLocation?
    var eventOwner: User?
    var admins, going, notGoing, maybe : [User]?
    var interested, likes, invited: [User]?
    

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case ownerID = "owner_id"
        case eventOwner = "event_owner"
        case eventType = "event_type"
        case eventName = "event_name"
        case eventDescription = "description"
        case startTime = "start_time"
        case endTime = "end_time"
        case eventCategory = "event_category"
        case eventPrivacy = "event_privacy"
        case coverImages = "cover_images_url"
        case location = "event_location"
        case admins = "admins_profile"
        case going = "going_profile"
        case notGoing = "not_going_profile"
//        case notInvited = "not_invited"
        case maybe = "maybe_profile", interested = "interested_profile", likes = "likes_profile", invited = "invited_users_profile"
        case dressCode = "dress_code"
        case inviterName = "event_inviter_name"
        case guestListVisible = "guest_list_visible"
        case anyoneCanInvite = "anyone_can_invite"
        case meetingLink = "meeting_link"
    }
    
    internal init(eventID: String? = nil, ownerID: String? = nil, eventType: String? = nil, eventName: String? = nil, eventDescription: String? = nil, startTime: String? = nil, endTime: String? = nil, eventCategory: String? = nil, eventPrivacy: String? = nil, coverImages: [String]? = nil, onlineEvent: OnlineEvent? = nil, location: EventLocation? = nil, admins: [User]? = nil, going: [User]? = nil, notGoing: [User]? = nil, maybe: [User]? = nil, interested: [User]? = nil, likes: [User]? = nil, invited: [User]? = nil, dressCode: String? = nil, inviterName: String? = nil, eventOwner: User? = User.nilUser, anyoneCanInvite: Bool? = false, guestListVisible: Bool? = false, meetingLink: String? = nil) {
        self.eventID = eventID
        self.ownerID = ownerID
        self.eventType = eventType
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.startTime = startTime
        self.endTime = endTime
        self.eventCategory = eventCategory
        self.eventPrivacy = eventPrivacy
        self.coverImages = coverImages
       // self.onlineEvent = onlineEvent
        self.location = location
        self.admins = admins
        self.going = going
        self.notGoing = notGoing
        self.maybe = maybe
        self.interested = interested
        self.likes = likes
        self.invited = invited
//        self.notInvited = notInvited
        self.dressCode = dressCode
        self.inviterName = inviterName
        self.eventOwner = eventOwner
        self.anyoneCanInvite = anyoneCanInvite
        self.guestListVisible = guestListVisible
        self.meetingLink = meetingLink
    }
    
    
    class func build(_ json:JSON) -> EventBasic {
        let coverImages = json["cover_images_url"].arrayValue as? [String]
        let onlineEvent = json["online_event"].object as? OnlineEvent
        let eventLocation = json["online_event"].object as? EventLocation
        let admins = json["admins_profile"].array?.map { return User.build($0) }
        let going = json["going_profile"].array?.map { return User.build($0) }
        let notGoing = json["not_going_profile"].array?.map { return User.build($0) }
        let maybe_profile = json["maybe_profile"].array?.map { return User.build($0) }
        let interested = json["interested_profile"].array?.map { return User.build($0) }
        let likes = json["likes_profile"].array?.map { return User.build($0) }
        let invited = json["invited_users_profile"].array?.map { return User.build($0) }
        let owner = User.build(json["event_owner"])
        
        
        return EventBasic(eventID: json["event_id"].stringValue, ownerID: json["owner_id"].stringValue, eventType: json["event_type"].stringValue, eventName: json["event_name"].stringValue, eventDescription: json["description"].stringValue, startTime: json["start_time"].stringValue, endTime: json["end_time"].stringValue, eventCategory: json["event_category"].stringValue, eventPrivacy: json["event_privacy"].stringValue, coverImages: coverImages , onlineEvent: onlineEvent, location: eventLocation, admins: admins, going: going, notGoing: notGoing, maybe: maybe_profile, interested: interested, likes: likes, invited: invited, dressCode: json["dress_code"].stringValue, inviterName: json["event_inviter_name"].stringValue, eventOwner: owner, anyoneCanInvite: json["anyone_can_invite"].boolValue, guestListVisible: json["guest_list_visible"].boolValue, meetingLink: json["meeting_link"].stringValue)
      }
}
