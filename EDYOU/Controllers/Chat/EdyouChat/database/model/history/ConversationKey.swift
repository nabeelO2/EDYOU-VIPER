//
// ConversationKey.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//
import Foundation
import Martin

public protocol ConversationKey: CustomDebugStringConvertible {

    var account: BareJID { get }
    var jid: BareJID { get }
        
}

public class ConversationKeyItem: ConversationKey {
    
    public let account: BareJID;
    public let jid: BareJID;
    
    public var debugDescription: String {
        return "ConversationKeyItem(account: \(account), jid: \(jid))";
    }
    
    init(account: BareJID, jid: BareJID) {
        self.account = account;
        self.jid = jid;
    }
    
}
