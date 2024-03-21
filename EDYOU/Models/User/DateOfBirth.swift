//
//  DateOfBirth.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift


class DateOfBirth: Object, Codable {
    @objc dynamic var birthYear, birthMonth, birthDate: String?
   
    internal init(birthYear: String?, birthMonth: String?, birthDate: String?) {
        self.birthYear = birthYear
        self.birthMonth = birthMonth
        self.birthDate = birthDate
    }
    
    override init() {
        super.init()
    }
    
    var toDate: Date? {
        guard let day = birthDate , let month = birthMonth, let year = birthYear else {
            return  nil
        }
        return "\(day)-\(month)-\(year)".toDate
    }
    
    
    enum CodingKeys: String, CodingKey {
        case birthYear = "birth_year"
        case birthMonth = "birth_month"
        case birthDate = "birth_date"
    }
}
