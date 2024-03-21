//
//  Institute.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import Foundation


// MARK: - Institute
class Institute: Codable {
    let name, emailSuffix,schoolID : String
    var icon: String?
    internal init(name: String, emailSuffix: String, icon: String, schoolID: String) {
        self.name = name
        self.emailSuffix = emailSuffix
        self.icon = icon
        self.schoolID = schoolID
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case icon
        case schoolID = "school_id"
        case emailSuffix = "email_suffix"
    }
}


extension Sequence where Element == Institute {
    func dataPickerItems() -> [DataPickerItem<Institute>] {
        
        let items = self.map { institute in
            return DataPickerItem(title: institute.name, imageURL: institute.icon, data: institute)
        }
        return items
    }
}

extension Sequence where Element == String {
    func stringToDatePickerItem() -> [DataPickerItem<String>] {
        
        let items = self.map { value in
            return DataPickerItem<String>(title: value.capitalized)
        }
        return items
    }
}
