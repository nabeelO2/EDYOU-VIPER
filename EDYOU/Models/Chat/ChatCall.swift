//
//  ChatCall.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/31/22.
//

import Foundation



class ChatCall: Codable  {
    internal init(accessToken: String? = nil) {
        self.accessToken = accessToken
    }
    
    
    var accessToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "call_access_token"
      
    }
    
    
    
}
