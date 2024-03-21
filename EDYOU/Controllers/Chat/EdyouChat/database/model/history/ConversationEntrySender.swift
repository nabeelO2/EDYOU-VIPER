//
// ConversationEntrySender.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

public enum ConversationEntrySender: Hashable {
    
    case none
    case me(nickname: String)
    case buddy(nickname: String)
    case occupant(nickname: String, jid: BareJID?)
    case participant(id: String, nickname: String, jid: BareJID?)
    case channel
    
    var nickname: String? {
        switch self {
        case .me(let nickname):
            return nickname;
        case .buddy(let nickname), .occupant(let nickname, _), .participant(_, let nickname,  _):
            return nickname;
        case .none, .channel:
            return nil;
        }
    }
    
    func avatar(for key: ConversationKey) -> Avatar? {
        switch self {
        case .me:
            return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: key.account, mucNickname: nil));
        case  .buddy(_):
            return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: key.jid, mucNickname: nil));
        case .occupant(let nickname, let jid):
            if let jid = jid {
                return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: jid, mucNickname: nil));
            } else {
                return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: key.jid, mucNickname: nickname));
            }
        case .participant(let participantId, _, let jid):
            if let jid = jid {
                return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: jid, mucNickname: nil));
            } else {
                return AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: BareJID(localPart: "\(participantId)#\(key.jid.localPart ?? "")", domain: key.jid.domain), mucNickname: nil));
            }
        case .none, .channel:
            return nil;
        }
    }
    
    var isGroupchat: Bool {
        switch self {
        case .none, .buddy(_), .me(_):
            return false;
        default:
            return true;
        }
    }

    var jid:BareJID? {
        switch self {
            case .none:
                return nil
            case .me(_):
                return BareJID("\(Cache.shared.user?.userID ?? "")@ejabberd.edyou.io")
            case .buddy(_):
                return nil
            case .occupant(_, let jid):
                return jid
            case .participant(let id, _, let jid):
                return jid
            case .channel:
                return nil
        }
    }

    static func me(conversation: ConversationKey) -> ConversationEntrySender {
        return .me(nickname: AccountManager.getAccount(for: conversation.account)?.nickname ?? conversation.account.stringValue);
    }
    
    static func buddy(conversation: ConversationKey) -> ConversationEntrySender {
        if let conv = conversation as? Conversation {
            return .buddy(nickname: conv.displayName);
        } else {
            return .buddy(nickname: DBRosterStore.instance.item(for: conversation.account, jid: JID(conversation.jid))?.name ?? conversation.jid.stringValue);
        }
    }
}
