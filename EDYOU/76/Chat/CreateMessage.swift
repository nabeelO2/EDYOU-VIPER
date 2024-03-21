//
//  CreateMessage.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

// MARK: - CreateMessage
class CreateMessage: Codable {
    
    let content: String
    
    internal init(content: String) {
        self.content = content
    }

    enum CodingKeys: String, CodingKey {
        case content
    }
    
   
    
}
