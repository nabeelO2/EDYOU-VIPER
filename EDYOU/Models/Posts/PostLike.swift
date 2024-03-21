//
//  PostLike.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

struct PostLike: Codable {
    let likeEmotion: String?
    let userId: String?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case likeEmotion = "like_emotion"
        case user
        case userId = "user_id"
    }
}

extension PostLike : EmojiModelProtocol {
    var emoji: String {
        return likeEmotion?.decodeEmoji() ?? ""
    }
    
    var userName: String {
        return user?.name?.completeName ?? ""
    }
    
    var userPicture: String {
        return user?.profileImage ?? ""
    }
    
    var userUniversity: String {
        return user?.getCurrentEducation()?.instituteName ?? ""
    }
    
}
