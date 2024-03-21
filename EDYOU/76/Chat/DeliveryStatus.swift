//
//  DeliveryStatus.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - DeliveryStatus
 class DeliveryStatus: Object,Codable {
    internal init(seen: Bool = false, delivered: Bool = false, sent: Bool = false, seenAt: String? = nil, deliveredAt: String? = nil, sentAt: String? = nil, sending: Bool = false, failed: Bool = false) {
        self.seen = seen
        self.delivered = delivered
        self.sent = sent
        self.seenAt = seenAt
        self.deliveredAt = deliveredAt
        self.sentAt = sentAt
        self.sending = sending
        self.failed = failed
    }
    
   
    
    @objc dynamic  var seen: Bool = false
    @objc dynamic  var delivered: Bool = false
    @objc dynamic  var sent: Bool = false
    @objc dynamic  var seenAt: String?
    @objc dynamic  var deliveredAt: String?
    @objc dynamic  var sentAt: String?
    
    @objc dynamic var sending : Bool = false
    @objc dynamic var failed : Bool = false
    

 
    
     override init() {
         super.init()
     }
     
    
    
    enum CodingKeys: String, CodingKey {
        case seen, delivered, sent
        case seenAt = "seen_at"
        case deliveredAt = "delivered_at"
        case sentAt = "sent_at"
    }
}

