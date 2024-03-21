//
//  SenderProfile.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class SenderProfile : Codable {
    internal init(profileImage: String?, coverPhoto: String?, profileThumbnail: String?, userId: String?, name: NotificationSenderName?) {
        self.profileImage = profileImage
        self.coverPhoto = coverPhoto
        self.profileThumbnail = profileThumbnail
        self.userId = userId
        self.name = name
    }
    
    let profileImage : String?
    let coverPhoto : String?
    let profileThumbnail : String?
    let userId : String?
    let name : NotificationSenderName?

    enum CodingKeys: String, CodingKey {

        case profileImage = "profile_image"
        case coverPhoto = "cover_photo"
        case profileThumbnail = "profile_thumbnail"
        case userId = "user_id"
        case name = "name"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        coverPhoto = try values.decodeIfPresent(String.self, forKey: .coverPhoto)
        profileThumbnail = try values.decodeIfPresent(String.self, forKey: .profileThumbnail)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        name = try values.decodeIfPresent(NotificationSenderName.self, forKey: .name)
    }

}
