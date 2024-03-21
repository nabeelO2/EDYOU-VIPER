//
//  MyEventsDataModel.swift
//  EDYOU
//
//  Created by Aksa on 29/08/2022.
//

import Foundation

// MARK: - MyEventsDataModel
class MyEventsDataModel: Codable {
    var eventsICreated, eventsIAmGoing, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested: [EventBasic]?
    
    enum CodingKeys: String, CodingKey {
        case eventsICreated = "events_i_created"
        case eventsIAmGoing = "events_i_am_going"
        case eventsIAmNotGoing = "events_i_am_not_going"
        case eventsIAmInvited = "events_i_am_invited"
        case eventsIAmInterested = "events_i_am_interested"
    }

    init(eventsICreated: [EventBasic]?, eventsIAmGoing: [EventBasic]?, eventsIAmNotGoing: [EventBasic]?, eventsIAmInvited: [EventBasic]?, eventsIAmInterested: [EventBasic]?) {
        self.eventsICreated = eventsICreated
        self.eventsIAmGoing = eventsIAmGoing
        self.eventsIAmNotGoing = eventsIAmNotGoing
        self.eventsIAmInvited = eventsIAmInvited
        self.eventsIAmInterested = eventsIAmInterested
    }
}
