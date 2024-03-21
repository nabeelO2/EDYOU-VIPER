//
//  Event.swift
//  EDYOU
//
//  Created by  Mac on 02/11/2021.
//

import Foundation
import UIKit

// MARK: - DataClass
class Event: Codable {

    var eventID, groupID, ownerID, eventType, showMeAs, eventPrivacy, dressCode, inviterName: String?
    var eventName, title, eventDescription, startTime, endTime, eventCategory, meetingLink: String?
    var shareWith, shareWithUsers, reminders, coverImages : [String]?
    var peoplesProfile: PeoplesProfile?
    var owner: User?
    var eventPosts: Posts?
    var onlineEvent: OnlineEvent?
    var location: EventLocation?
    var isFavorite: Bool?
    var guestListVisible, anyoneCanInvite: Bool?
    
    var isIAmAdmin: Bool {
        return self.peoplesProfile?.admins?.first?.isMe ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case groupID = "group_id"
        case ownerID = "owner_id"
        case eventType = "event_type"
        case eventName = "event_name"
        case eventDescription = "description"
        case startTime = "start_time"
        case endTime = "end_time"
        case eventCategory = "event_category"
        case eventPrivacy = "event_privacy"
        case coverImages = "cover_images"
        case peoplesProfile = "peoples_profile"
        case owner = "event_owner"
        case eventPosts = "event_posts"
        case onlineEvent = "online_event"
        case location = "in_person_event"
        case title = "title"
        case shareWithUsers = "share_with_users"
        case shareWith = "share_with"
        case showMeAs = "show_me_as"
        case isFavorite = "is_favourite"
        case dressCode = "dress_code"
        case inviterName = "event_inviter_name"
        case guestListVisible = "guest_list_visible"
        case anyoneCanInvite = "anyone_can_invite"
        case meetingLink = "meeting_link"
    }
    
    init(event: EventBasic) {
        eventID = event.eventID
        ownerID = event.ownerID
        eventType = event.eventType
        eventName = event.eventName
        eventDescription = event.eventDescription
        startTime = event.startTime
        endTime = event.endTime
        eventCategory = event.eventCategory
        eventPrivacy = event.eventPrivacy
        coverImages = event.coverImages
        onlineEvent = event.onlineEvent
        location = event.location
        owner = event.eventOwner
        let profiles = PeoplesProfile.fromIds(admins: event.admins ?? [], going: event.going ?? [], notGoing: event.notGoing ?? [], maybe: event.maybe ?? [], interested: event.interested ?? [], likes: event.likes ?? [], invited: event.invited ?? []) 
        peoplesProfile = profiles
        dressCode = event.dressCode
        inviterName = event.inviterName
        meetingLink = event.meetingLink
        anyoneCanInvite = event.anyoneCanInvite
        guestListVisible = event.guestListVisible
    }
}
// MARK: - Helpers

extension Event {
    
    var eventLocationAddress: String {
        return self.location?.completeAddress ?? "No Address"
    }
    var formattedStartDate: String {
        if let s = self.startTime?.toDate {
           return "\(s.stringValue(format: "EEE dd MMM yyyy, hh:mm a", timeZone: .current))"
        }
        return "--/--"
    }
    
    func checkMeGoing(userId: String) -> (going:Bool,image: UIImage) {
        let going = self.peoplesProfile?.going?.contains(userId: userId) ?? false
        return (going, EventAction.going.getActionImage(actionStatus: going))
    }
    
    func checkMeInterested(userId: String) -> (going:Bool,image: UIImage) {
        let interested = self.peoplesProfile?.interested?.contains(userId: userId) ?? false
        return (interested, EventAction.interested.getActionImage(actionStatus: interested))
    }
    
    func checkMeNotGoing(userId: String) -> (going:Bool,image: UIImage) {
        let noGoing = self.peoplesProfile?.notGoing?.contains(userId: userId) ?? false
        return (noGoing, EventAction.notGoing.getActionImage(actionStatus: noGoing))
    }
}
