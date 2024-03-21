//
//  PeopleProfile.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation



class PeoplesProfile: Codable {
    var admins, going, notGoing, maybe: [User]?
    var interested, likes, invited, notInvited: [User]?
    
    internal init(admins: [User]? = nil, going: [User]? = nil, notGoing: [User]? = nil, maybe: [User]? = nil, interested: [User]? = nil, likes: [User]? = nil, invited: [User]? = nil, notInvited: [User]? = nil) {
        self.admins = admins
        self.going = going
        self.notGoing = notGoing
        self.maybe = maybe
        self.interested = interested
        self.likes = likes
        self.invited = invited
        self.notInvited = notInvited
    }
    
    var allUsers: [User] {
        var u = admins ?? []
        u.append(contentsOf: going ?? [])
        u.append(contentsOf: notGoing ?? [])
        u.append(contentsOf: maybe ?? [])
        u.append(contentsOf: interested ?? [])
        u.append(contentsOf: likes ?? [])
        u.append(contentsOf: invited ?? [])
        return u
    }

    enum CodingKeys: String, CodingKey {
        case admins, going
        case notGoing = "not_going"
        case notInvited = "not_invited"
        case maybe, interested, likes, invited
    }
    static func fromIds(admins: [User], going: [User], notGoing: [User], maybe: [User], interested: [User], likes: [User], invited: [User]) -> PeoplesProfile {
        let profiles = PeoplesProfile()
        profiles.admins = admins
        profiles.going = going
        profiles.notGoing = notGoing
        profiles.maybe = maybe
        profiles.interested = interested
        profiles.likes = likes
        profiles.invited = invited
        return profiles
    }
    
    func getUsersFrom(type: PeopleProfileTypes) -> [User] {
        switch type {
        case .admins:
            return self.admins ?? []
        case .going:
            return self.going ?? []
        case .notGoing:
            return self.notGoing ?? []
        case .maybe:
            return self.maybe ?? []
        case .interseted:
            return self.interested ?? []
        case .likes:
            return self.likes ?? []
        case .invited:
            return invited ?? []
        case .notInvited:
            return notInvited ?? []
        }
    }
    
    func getCountFromType(type: PeopleProfileTypes)->Int {
        switch type {
        case .admins:
            return self.admins?.count ?? 0
        case .going:
            return self.going?.count ?? 0
        case .notGoing:
            return self.notGoing?.count ?? 0
        case .maybe:
            return self.maybe?.count ?? 0
        case .interseted:
            return self.interested?.count ?? 0
        case .likes:
            return self.likes?.count ?? 0
        case .invited:
            return invited?.count ?? 0
        case .notInvited:
            return notInvited?.count ?? 0
        }
    }
}
