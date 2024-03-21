//
//  ChatEmojiReaction.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/23/22.
//

import Foundation
import RealmSwift


class EmojiModel: Object, Codable {
   
    
    @objc dynamic var createdAt, updatedAt, emojiCode, emojiID: String?
    @objc dynamic var senderUserID: String?
    var senderProfile: User? = User()

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case emojiCode = "emoji_code"
        case emojiID = "emoji_id"
        case senderUserID = "sender_user_id"
        case senderProfile = "sender_profile"
    }
    
     override init() {
         super.init()
     }
     
    
    internal init(createdAt: String?, updatedAt: String?, emojiCode: String?, emojiID: String?, senderUserID: String?, senderProfile: User?) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.emojiCode = emojiCode
        self.emojiID = emojiID
        self.senderUserID = senderUserID
        self.senderProfile = senderProfile ?? User()
    }
}

extension EmojiModel: EmojiModelProtocol {
    var emoji: String {
        return emojiCode ?? ""
    }
    
    var userName: String {
        return senderProfile?.name?.completeName ?? ""
    }
    
    var userPicture: String {
        return senderProfile?.profileImage ?? ""
    }
    
    var userUniversity: String {
        return self.senderProfile?.getCurrentEducation()?.instituteName ?? ""
    }
}

final class EmojiFormatted: Object, Codable  {
   
    
    @objc dynamic var emojiCode, emojiID: String?
    @objc dynamic var count: Int = 0
    
    internal init(emojiCode: String?, emojiID: String?, count: Int?) {
        self.emojiCode = emojiCode
        self.emojiID = emojiID
        self.count = count ?? 0
    }
    
    override init() {
        super.init()
    }
    
}
