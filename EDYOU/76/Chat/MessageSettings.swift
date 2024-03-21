//
//  MessageSettings.swift
//  EDYOU
//
//  Created by amjad on 04/10/2022.
//

import Foundation
import RealmSwift

class MessageSettings: Object,Codable {
    
    @objc dynamic  var is_edited : Bool = false
    @objc dynamic  var is_forwarded : Bool = false
    @objc dynamic  var is_replied : Bool = false
    @objc dynamic  var editedAt : String?
    @objc dynamic  var repliedAt : String?
    @objc dynamic  var repliedBy : String?
    @objc dynamic  var self_destruct_message_in_minutes : Int = 0
    
    internal init(is_edited: Bool = false, is_forwarded : Bool = false, is_replied: Bool = false, editedAt: String? = nil, repliedAt:String? = nil,repliedBy:String? = nil,self_destruct_message_in_minutes: Int = 0){
        self.is_edited = is_edited
        self.is_forwarded = is_forwarded
        self.is_replied = is_replied
        self.editedAt =  editedAt
        self.repliedAt = repliedAt
        self.repliedBy = repliedBy
        self.self_destruct_message_in_minutes = self_destruct_message_in_minutes
    }
    override init() {
        super.init()
    }
    
   
   
   enum CodingKeys: String, CodingKey {
       case is_edited, is_forwarded, is_replied
       case editedAt = "edited_at"
       case repliedAt = "replied_at"
       case repliedBy = "replied_by"
       case self_destruct_message_in_minutes
   }
}
