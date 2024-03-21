//
//  NotificationData.swift
//  EDYOU
//
//  Created by PureLogics on 06/01/2022.
//

import Foundation

class NotificationData : Codable {
    let notificationId : String?
    let alert : String?
    let badge : Int?
    let sound : String?
    let userId : String?
    let read : Bool?
    let createdAt : String?
    let updatedAt : String?
    let actionName : String?
    let actionIdName : String?
    let actionId : String?
    let senderId: String?
    var receiverId: String?
    let senderProfile : SenderProfile?

    enum CodingKeys: String, CodingKey {

        case notificationId = "notification_id"
        case alert = "alert"
        case badge = "badge"
        case sound = "sound"
        case userId = "user_id"
        case read = "read"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case actionName = "action_name"
        case actionIdName = "action_id_name"
        case actionId = "action_id"
        case senderProfile = "sender_profile"
        case senderId = "sender_id"
        case receiverId = "receiver_id"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        notificationId = try values.decodeIfPresent(String.self, forKey: .notificationId)
        alert = try values.decodeIfPresent(String.self, forKey: .alert)
        badge = try values.decodeIfPresent(Int.self, forKey: .badge)
        sound = try values.decodeIfPresent(String.self, forKey: .sound)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        read = try values.decodeIfPresent(Bool.self, forKey: .read)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        actionName = try values.decodeIfPresent(String.self, forKey: .actionName)
        actionIdName = try values.decodeIfPresent(String.self, forKey: .actionIdName)
        actionId = try values.decodeIfPresent(String.self, forKey: .actionId)
        senderProfile = try values.decodeIfPresent(SenderProfile.self, forKey: .senderProfile)
        senderId = try values.decodeIfPresent(String.self, forKey: .senderId)
        receiverId = try values.decodeIfPresent(String.self, forKey: .receiverId)
    }

}

extension Array where Iterator.Element == NotificationData {
    func unreadCount() -> Int {
        let unread = self.filter { $0.read == false }
        return unread.count
    }
}

