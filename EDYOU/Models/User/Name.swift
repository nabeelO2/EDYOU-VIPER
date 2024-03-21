//
//  Name.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class Name: Object, Codable {
    
   
    @objc dynamic var firstName, lastName, middleName, nickName: String?
 
    internal init(firstName: String?, lastName: String?, middleName: String?, nickName: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.nickName = nickName
    }
 
  
    var completeName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmed
    }

    var nameIntials: String {

        return "\(firstName?.first ?? Character("")) \(lastName?.first ?? Character(""))".trimmed;
    }

    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case nickName = "nick_name"
    }
    
}
