//
//  Name.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class UserSchool: Object, Codable {
    
   
    @objc dynamic var school_id, college, state_code, state, email_suffix: String?
 
    internal init(school_id: String?, college: String?, state_code: String?, state: String?, email_suffix: String?) {
        self.school_id = school_id
        self.college = college
        self.state_code = state_code
        self.state = state
        self.email_suffix = email_suffix
    }
 
  
   
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case school_id = "school_id"
        case college = "college"
        case state_code = "state_code"
        case state = "state"
        case email_suffix = "email_suffix"

    }
    
}
