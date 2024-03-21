//
//  Comment.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class Comment: Codable {
    var assets: PostAsset?
    var commentID, userID: String?
    var owner: User?
    var message: String?
    var tagFriends: [String]?
    var tagFriendsProfile: [User?]?
    var likes: Int?
    var commentLikes: [CommentLike]?
    var createdAt: String?
    var childComments: [Comment] = []
    
    var isLiked = false
    var commentType : CommentType = .parent
    var showSeperator: Bool = false
    var parentCommentId: String? = nil
    
    var formattedText: String {
        var text = message
        for u in (tagFriendsProfile ?? []) {
            if let user = u , let userId = user.userID {
                text = text?.replacingOccurrences(of: "id{\(userId)}", with: "@\(user.formattedUserName)")
            }
        }
        return text ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case assets
        case commentID = "comment_id"
        case userID = "user_id"
        case owner = "comment_owner"
        case message
        case tagFriends = "tag_friends"
        case likes
        case tagFriendsProfile = "tag_friends_profile"
        case commentLikes = "comment_likes"
        case createdAt = "created_at"
        case childComments = "child_comments"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        assets = try values.decodeIfPresent(PostAsset.self, forKey: .assets)
        commentID = try values.decodeIfPresent(String.self, forKey: .commentID)
        userID = try values.decodeIfPresent(String.self, forKey: .userID)
        owner = try values.decodeIfPresent(User.self, forKey: .owner)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        tagFriends = try values.decodeIfPresent([String].self, forKey: .tagFriends)
        likes = try values.decodeIfPresent(Int.self, forKey: .likes)
        tagFriendsProfile = try values.decodeIfPresent([User?].self, forKey: .tagFriendsProfile)
        commentLikes = try values.decodeIfPresent([CommentLike].self, forKey: .commentLikes)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        childComments = try values.decodeIfPresent([Comment].self, forKey: .childComments) ?? []
        childComments.forEach { comment in
            comment.commentType = .child
            comment.parentCommentId = commentID
        }
        childComments.last?.showSeperator = true
    }
}
