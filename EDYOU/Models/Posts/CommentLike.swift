//
//  CommentLike.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class CommentLike: Codable {
    var likeEmotion, userID: String?

    enum CodingKeys: String, CodingKey {
        case likeEmotion = "like_emotion"
        case userID = "user_id"
    }
}
