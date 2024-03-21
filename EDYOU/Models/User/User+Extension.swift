//
//  User+Extension.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

extension Array where Element == User {
    var ids: [String] {
        let ids = self.map { $0.userID! }
        return ids
    }
    var names: String {
        let n = self.reduce("") { result, user in
            var r = result.trimmed
            if r == "" {
                r += "\(user.name?.completeName ?? "")"
            } else {
                r += ", \(user.name?.completeName ?? "")"
            }
            return r
        }
        return n
    }
    var firstNames: String {
        let n = self.reduce("") { result, user in
            var r = result.trimmed
            if r == "" {
                r += "\(user.name?.firstName ?? "")"
            } else {
                r += ", \(user.name?.firstName ?? "")"
            }
            return r
        }
        return n
    }
    
    mutating func append(userId: String) {
        let u = User.nilUser
        u.userID = userId
        self.append(u)
    }
    
    mutating func remove(userId: String) {
        let index = self.firstIndex { $0.userID == userId }
        
        if let i = index, i >= 0 {
            self.remove(at: i)
        }
    }
    func contains(userId: String) -> Bool {
        let c = self.contains { $0.userID == userId }
        return c
    }
}

extension String {
    func replaceTags(users: [User?]) -> String {
        var text = self
        for u in (users) {
            if let user = u {
                text = text.replacingOccurrences(of: "id{\(user.userID)}", with: "@\(user.formattedUserName)")
            }
        }
        return text
    }
}
