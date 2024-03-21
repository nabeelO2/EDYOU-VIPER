//
// ConversationEntryRecipient.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation

enum ConversationEntryRecipient: Hashable {
    case none
    case occupant(nickname: String)
    
    var nickname: String? {
        switch self {
        case .none:
            return nil;
        case .occupant(let nickname):
            return nickname;
        }
    }
}
