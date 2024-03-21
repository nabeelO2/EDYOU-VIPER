//
//  UserRoomSettings.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift
 class UserRoomSettings: Object, Codable {
   
    
    @objc dynamic var isArchived : Bool = false
    @objc dynamic var isMute: Bool = false
    @objc dynamic var downloadMedia: Bool = false
    @objc dynamic var selfDestroyMessages: Int = 0
    @objc dynamic var name: String?

     override init() {
         super.init()
     }
     
    internal init(isArchived: Bool = false, isMute: Bool = false, downloadMedia: Bool? = false, selfDestroyMessages: Int? = 0) {
        self.isArchived = isArchived
        self.isMute = isMute
        self.downloadMedia = downloadMedia ?? false
        self.selfDestroyMessages = selfDestroyMessages ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case isArchived = "is_archived"
        case isMute = "is_mute"
        case downloadMedia = "download_media"
        case selfDestroyMessages = "self_destroy_messages"
    }
}
