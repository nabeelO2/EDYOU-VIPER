//
//  GroupsData.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class GroupsData: Codable {
    let my: [GroupBasic]?
    let joined: [GroupBasic]?
    let pending: [GroupBasic]?
    let invited: [GroupBasic]?
    
    enum CodingKeys: String, CodingKey {
        case my = "my_groups"
        case joined
        case pending = "waiting_for_admin_approval"
        case invited = "waiting_for_my_approval"
    }
}
