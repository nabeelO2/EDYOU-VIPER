//
//  ChatMessage.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


// MARK: - ChatMessage
 class ChatMessage: Object, Codable {
  
    
    
     internal init(id: String? = nil, by: String, byUser: User? = User(), to: List<String> = List<String>(), content: String? = nil, createdTimestamp: String? = nil, expInMin: Int = 0, assets: ChatAsset? = ChatAsset(), type: String? = nil, roomName: String? = nil, roomId: String? = nil, deliveryStatus: DeliveryStatus? = DeliveryStatus(), emojis: List<EmojiModel> = List<EmojiModel>(), formattedEmojis: List<EmojiFormatted> = List<EmojiFormatted>(), messageSeqNo:Int = 0,messageSettings: MessageSettings? = MessageSettings(),marked_for_deletion: Bool = false) {
        self.id = id
        self.by = by
        self.byUser = byUser
        self.to = to
        self.content = content
        self.createdTimestamp = createdTimestamp
        self.expInMin = expInMin
        self.assets = assets
        self.type = type
        self.roomName = roomName
        self.roomId = roomId
        self.deliveryStatus = deliveryStatus
        self.emojis = emojis
        self.formattedEmojis = formattedEmojis
         self.messageSeqNo = messageSeqNo
         self.messageSettings = messageSettings
         self.marked_for_deletion =  marked_for_deletion
    }
    
  
    
    
 
   
    @objc dynamic var id: String? = ""
    @objc dynamic var by: String = ""
    @objc dynamic var byUser: User? = User()
    var to: List<String> = List<String>()
    @objc dynamic  var content: String?
    @objc dynamic var createdTimestamp: String?
    @objc dynamic var expInMin: Int = 0
    @objc dynamic var assets: ChatAsset? = ChatAsset()
    @objc dynamic  var type: String?
    @objc dynamic var roomName: String?
    @objc dynamic  var roomId: String?
     @objc dynamic  var messageSeqNo: Int = 0
     @objc dynamic  var marked_for_deletion: Bool = false
    @objc dynamic var deliveryStatus: DeliveryStatus? = DeliveryStatus()
     @objc dynamic var messageSettings : MessageSettings? = MessageSettings()
    var emojis: List<EmojiModel> = List<EmojiModel>()
    var formattedEmojis: List<EmojiFormatted> = List<EmojiFormatted>()
      
    override static func primaryKey() -> String? {
           return "id"
       }
   
   
     override init() {
         super.init()
     }
     
     
     
    var messageType: MessageType {
        return MessageType(rawValue: type ?? "") ?? .typing
    }
    
    var messageTimeDate: String
        {
            var date1 = createdTimestamp?.toDate
            let calendar: NSCalendar = NSCalendar.current as NSCalendar
            let date2 = Date()
            
            if date1 == nil
            {
                date1 = Date()
            }
            
            let flags = NSCalendar.Unit.day
            let flagsHours = NSCalendar.Unit.hour
            let flagsMinutes = NSCalendar.Unit.minute
            let flagsYear = NSCalendar.Unit.year
            let flagsSeconds = NSCalendar.Unit.second
            
            let componentsForDay = calendar.components(flags, from: date1!, to: date2)
            let componentsForMinutes = calendar.components(flagsMinutes, from: date1!, to: date2)
            let componentsForYears = calendar.components(flagsYear, from: date1!, to: date2)
            let componentsForSeconds = calendar.components(flagsSeconds, from: date1!, to: date2)
            let componentsForHours = calendar.components(flagsHours, from: date1!, to: date2)
        
            
            
            if componentsForSeconds.second ?? 0 < 30
            {
                return "Just Now"
            }
            else
            if componentsForMinutes.minute ?? 0 < 1
            {
               return "few seconds ago"
            }
            if componentsForMinutes.minute ?? 0 < 60
            {
                let minutes = componentsForMinutes.minute
                return "\(minutes!) min ago"
            }
            else
            if componentsForHours.hour ?? 0 < 24
            {
                let hours = componentsForHours.hour
                return "\(hours!) hr ago"
            }
            else
            if componentsForDay.day == 1
            {
               return "Yesterday"
            }
            else
            if componentsForDay.day ?? 0 < 7
            {
                let days = componentsForDay.day
                return "\(days!) day ago"
            }
            else
            if componentsForDay.day ?? 0 > 7 && componentsForDay.day ?? 0 < 14
            {
                return "1 week ago"
            }
            else
            if componentsForDay.day ?? 0 > 14 && componentsForDay.day ?? 0 < 21
            {
                return "2 week ago"
            }
            else
            {
                if componentsForYears.year ?? 0 < 1
                {
                    return date1!.stringValue(format: "hh:mm a dd MMM", timeZone: .current)
                   
                }
                else
                {
                    return date1!.stringValue(format: "hh:mm a dd/MM/yyyy", timeZone: .current)
                }
            }
            
        
            
            return ""
        }
       
    var chatType : ChatType
        {
            if assets != nil
            {
                if assets?.images != nil && assets?.images.count ?? 0 > 0
                {
                    return .images
                    
                }
                else
                if assets?.videos != nil && assets?.videos.count ?? 0 > 0
                {
                    return .videos
                }
                else
                if assets?.documents != nil && assets?.documents.count ?? 0 > 0
                {
                    return .documents
                }
                else
                if assets?.gifs != nil && assets?.gifs.count ?? 0 > 0
                {
                    return .gifs
                }
                else
                if assets?.audios != nil && assets?.audios.count ?? 0 > 0
                {
                    return .audio
                }
                else
                {
                    return .text
                }
            }
            else
            {
                return .text
            }
        }

     func formatEmojis() {
         var formatted =  List<EmojiFormatted>()
         for emoji in (emojis) {
             let contain = formatted.contains(where: { $0.emojiCode == emoji.emojiCode })
             if contain == false {
                 let a = emojis.filter({ $0.emojiCode == emoji.emojiCode })
                 formatted.append(EmojiFormatted(emojiCode: emoji.emojiCode, emojiID: emoji.emojiID, count: a.count ?? 0))
             }
         }
         formattedEmojis = formatted
     }
    enum CodingKeys: String, CodingKey {
        case by, to, content
        case createdTimestamp = "created_at"
       // case expInMin = "exp_in_min"
        case id = "message_id"
        case messageSeqNo = "message_seq"
        case byUser
        case assets
        case roomName = "room_name"
        case roomId = "room_id"
        case deliveryStatus = "delivery_status"
        case emojis = "emojis"
        case messageSettings = "message_settings"
        case marked_for_deletion
    }
}


extension ChatMessage {
    static func from(json data: NSDictionary) -> ChatMessage? {
        
        let dict = data.dictionary(for: "data")
        let a = dict.dictionary(for: "assets")
        let emojisA = dict.dictionary(for: "emojis")
        let emojis = EmojiModel(createdAt: emojisA["created_at"] as? String, updatedAt:  emojisA["updated_at"] as? String, emojiCode: emojisA["emoji_code"] as? String, emojiID: emojisA["emoji_id"] as? String, senderUserID: emojisA["sender_user_id"] as? String, senderProfile: emojisA["sender_profile"] as? User)
        
        let decoder = JSONDecoder()
        let imageSJSON = a["images"] ?? []
        let audiosJSON  =  a["audios"] ?? []
        let videosJSON  = a["videos"] ?? []
        let gifsJSON  =  a["gifs"] ?? []
        let documentsJSON  = a["documents"] ?? []
        
        var images = [ChatAssetDetail]()
        var audios = [ChatAssetDetail]()
        var videos = [ChatAssetDetail]()
        var gifs = [ChatAssetDetail]()
        var documents = [ChatAssetDetail]()
      
//        for dict in imageSJSON
//        {
//              // Condition required to check for type safety :)
//                guard let assetID =  dict.dictionary(for: "asset_id"),
//                      let assetName =  dict.dictionary(for: "asset_name"),
//                      let assetUrl =  dict.dictionary(for: "asset_url") ,
//                      let createdAt = dict.dictionary(for: "created_at") ,
//                      let updatedAt =  dict.dictionary(for: "updated_at") else {
//                      print("Something is not well")
//                     continue
//                 }
//                let object = ChatAssetDetail(assetsID: assetID, name: assetName, url: assetUrl, localUrl: "", createdAt: createdAt, updatedAt: updatedAt)
//            images.append(object)
//        }
        var assets = ChatAsset()
        do {
        let jsonData =  try JSONSerialization.data(withJSONObject: a , options: .prettyPrinted)
            assets =  try JSONDecoder().decode(ChatAsset.self, from: jsonData)
        
        }
        catch {
            print(error.localizedDescription)
        }
                                  
                                  
    
        if let by = dict["by"] as? String {
            let message = ChatMessage(id: dict.string(for: "message_id"), by: by, to: (dict["to"] as? List<String> ?? List<String>()), content: dict.string(for: "content"), createdTimestamp: dict.string(for: "created_at"), expInMin: dict.int(for: "exp_in_min"), assets: assets, type: dict.string(for: "type"), roomName: dict.string(for: "room_name"), roomId: dict.string(for: "room_id"),emojis: emojis as? List<EmojiModel> ?? List<EmojiModel>())
            
            return message
            
        } else if let byUser = dict["by_user"] as? NSDictionary {
            let toUser = (dict["to_user"] as? [NSDictionary])?.first
            let message = ChatMessage(id: dict.string(for: "message_id"), by: byUser.string(for: "user_id"), to: (toUser?.string(for: "user_id") ?? "") as? List<String> ?? List<String>(), content: dict.string(for: "content"), createdTimestamp: dict.string(for: "created_at"), expInMin: dict.int(for: "exp_in_min"), assets: assets, type: dict.string(for: "type"), roomName: dict.string(for: "room_name"), roomId: dict.string(for: "room_id"),emojis: emojis as? List<EmojiModel>  ?? List<EmojiModel>() )
            
            return message
            
        } else {
            print("[Socket] Joined: \(dict)")
        }
           
        return nil
        
    }
    static func from(message: String, roomId: String) -> ChatMessage {
        let u = Cache.shared.user
        let m = ChatMessage(id: "", by: u?.userID ?? "", to: List<String>(), content: message, createdTimestamp: Date().stringValue(format: "yyyy-MM-dd'T'HH:mm:ss"), expInMin: 0, assets: nil, type: MessageType.send.rawValue, roomId: roomId)
        return m
    }
}

enum ChatType: String {
    case images, audio ,videos ,gifs, documents, text
}

extension Array where Element == ChatMessage {
    
     func formatEmojis() {
        for (index, _) in self.enumerated() {
            self[index].formatEmojis()
        }
    }
    
}
