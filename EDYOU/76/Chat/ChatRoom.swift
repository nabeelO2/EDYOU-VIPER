//
//  Chat.swift
//  EDYOU
//
//  Created by  Mac on 18/11/2021.
//

import Foundation
import RealmSwift

enum RoomType: String {
    case personal = "personal"
    case group = "group"
}

enum CallType: String {
    case audio = "audio"
    case video = "video"
}


// MARK: - ChatRoom
 class ChatRoom: Object, Codable {
     
     @objc dynamic var roomId:  String?
     @objc dynamic var roomName, roomType, lastPinged: String?
     @objc dynamic var active: Int = 0
     var membersInfo: List<User> = List<User>()
     var messages: List<ChatMessage> = List<ChatMessage>()
     @objc dynamic var roomAvatar: String?
     @objc dynamic var roomDescription: String?
     var roomAdmins: List<String> = List<String>()
     @objc dynamic var unseenMessages: Int = 0
     @objc dynamic var userRoomSettings: UserRoomSettings?
     @objc dynamic var createdAt, updatedAt: String?
     //@objc dynamic var deletedMessages
     @objc dynamic var deliveredCount : Int = 0
     //@objc dynamic var globalRoomRettings =
     @objc dynamic var last_delivered_at, last_delivered_message_id : String?
     @objc dynamic var last_read_at, last_read_message_id : String?
     @objc dynamic var messages_count : Int =  0
     @objc dynamic var read_count : Int = 0
     //@objc dynamic var room_marked_for_deletion : Int = 0
     var isLocallyCreated = false
   
     required init(from decoder: Decoder) throws {
         let values = try decoder.container(keyedBy: CodingKeys.self)
         roomId = try values.decodeIfPresent(String.self, forKey: .roomId)
         roomName = try values.decodeIfPresent(String.self, forKey: .roomName)
         roomType = try values.decodeIfPresent(String.self, forKey: .roomType)
         lastPinged = try values.decodeIfPresent(String.self, forKey: .lastPinged)
         active = try values.decodeIfPresent(Int.self, forKey: .active) ?? 0
         membersInfo = try values.decodeIfPresent(List<User>.self, forKey: .membersInfo) ?? List<User>()
         messages = try values.decodeIfPresent(List<ChatMessage>.self, forKey: .messages) ?? List<ChatMessage>()
         roomAvatar = try values.decodeIfPresent(String.self, forKey: .roomAvatar)
         roomDescription = try values.decodeIfPresent(String.self, forKey: .roomDescription)
         roomAdmins = try values.decodeIfPresent(List<String>.self, forKey: .roomAdmins) ?? List<String>()
         unseenMessages = try values.decodeIfPresent(Int.self, forKey: .unseenMessages) ?? 0
         userRoomSettings = try values.decodeIfPresent(UserRoomSettings.self, forKey: .userRoomSettings)
         createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
         updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
         deliveredCount = try values.decodeIfPresent(Int.self, forKey: .deliveredCount) ?? 0
         last_delivered_at = try values.decodeIfPresent(String.self, forKey: .last_delivered_at)
         last_delivered_message_id = try values.decodeIfPresent(String.self, forKey: .last_delivered_message_id)
         last_read_at = try values.decodeIfPresent(String.self, forKey: .last_read_at)
         last_read_message_id = try values.decodeIfPresent(String.self, forKey: .last_read_message_id)
         messages_count = try values.decodeIfPresent(Int.self, forKey: .messages_count) ?? 0
         read_count = try values.decodeIfPresent(Int.self, forKey: .read_count) ?? 0
         //room_marked_for_deletion = try values.decodeIfPresent(Int.self, forKey: .room_marked_for_deletion) ?? 0
          
         
         
     }
    
     internal init(roomId: String? = nil, roomName: String? = nil, roomType: String? = nil, lastPinged: String? = nil, active: Int = 0, membersInfo: List<User> = List<User>(), messages: List<ChatMessage> = List<ChatMessage>(), roomAvatar: String? = nil, roomDescription: String? = nil, roomAdmins:  List<String> =  List<String>(), unseenMessages: Int = 0, userRoomSettings: UserRoomSettings? = nil, createdAt: String? = nil, updatedAt: String? = nil,deliveredCount:Int = 0,last_delivered_at:String? = nil,last_delivered_message_id:String? = nil,last_read_at:String? = nil,last_read_message_id:String? = nil, messages_count: Int = 0, read_count : Int = 0) {
        self.roomId = roomId
        self.roomName = roomName
        self.roomType = roomType
        self.lastPinged = lastPinged
        self.active = active
        self.membersInfo = membersInfo
        self.messages = messages
        self.roomAvatar = roomAvatar
        self.roomDescription = roomDescription
        self.roomAdmins = roomAdmins
        self.unseenMessages = unseenMessages
        self.userRoomSettings = userRoomSettings
         self.createdAt = createdAt
         self.updatedAt  = updatedAt
         //@objc dynamic var deletedMessages
         self.deliveredCount = deliveredCount
         //@objc dynamic var globalRoomRettings =
         self.last_delivered_at = last_delivered_at
         self.last_delivered_message_id = last_delivered_message_id
         self.last_read_at = last_read_at
         self.last_read_message_id = last_read_message_id
         self.messages_count  = messages_count
         self.read_count = read_count
         //self.room_marked_for_deletion = room_marked_for_deletion
    }
    
    
    
    override init() {
        super.init()
    }
    
    override static func primaryKey() -> String? {
           return "roomId"
       }
    
    var type: RoomType {
        return RoomType(rawValue: roomType ?? "") ?? .personal
    }
    var isMyGroup: Bool {
        return roomAdmins.contains(Cache.shared.user?.userID ?? "")
    }
    
   
    
    var otherUsers: List<User> {
        
        let userArray  = self.membersInfo.toArray(type: User.self)
        let filteredUserArray  = userArray.filter({ $0.userID != Cache.shared.user?.userID })
        var otherUsersArray : List<User> = List<User>()
        for user in filteredUserArray
        {
            otherUsersArray.append(user)
            
        }
        
        return otherUsersArray

        
    }
     
     func  getParticipantBy(userId: String)  ->  User?{
         let userArray  = self.membersInfo.toArray(type: User.self)
         let filteredUserArray  = userArray.filter({ $0.userID == userId })
         return  filteredUserArray.first
     }
    
    func formatMessageEmojis() {
        self.messages.toArray(type: ChatMessage.self).formatEmojis()
    }

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case roomName = "room_name"
        case roomType = "room_type"
        case lastPinged = "last_pinged"
        case membersInfo = "members_info"
        case active
        case messages
        case roomAvatar = "room_avatar"
        case roomDescription = "room_description"
        case roomAdmins = "room_admins"
        case unseenMessages = "unseen_messages"
        case userRoomSettings = "user_room_settings"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        //case deletedMessages = "deleted_messages"
        case deliveredCount = "delivered_count"
        //case globalRoomRettings = "global_room_settings"
        case last_delivered_at = "last_delivered_at"
        case last_delivered_message_id = "last_delivered_message_id"
        case last_read_at = "last_read_at"
        case last_read_message_id = "last_read_message_id"
        case messages_count = "messages_count"
        case read_count = "read_count"
        //case room_marked_for_deletion = "room_marked_for_deletion"
        
    }
}




extension ChatRoom {
    func updateSentByUserInfo() {
        for (index, value) in (self.messages).enumerated() {
            if value.byUser?.userID == "" || value.byUser?.userID == nil {
                let member = self.membersInfo.first(where: { $0.userID == value.by })
                self.messages[index].byUser = member ?? User()
                let messageIndex = index
                for(index, value) in (self.messages[index].emojis).enumerated()
                {
                    if value.senderProfile?.userID == "" || value.senderProfile?.userID == nil {
                        let member = self.membersInfo.first(where: { $0.userID == value.senderUserID })
                        self.messages[messageIndex].emojis[index].senderProfile = member ?? User()
                    }
                }
            }
        }
    }
    func updateTaggedMessages() {
        for (index, _) in (self.messages).enumerated() {
            let m = self.messages.toArray(type: ChatMessage.self)[index].content?.replaceTags(users: self.membersInfo.toArray(type: User.self) )
            self.messages[index].content = m
        }
    }
}








