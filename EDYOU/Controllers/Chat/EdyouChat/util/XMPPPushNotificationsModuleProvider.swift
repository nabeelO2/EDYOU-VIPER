//
// XMPPPushNotificationsModuleProvider.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

class XMPPPushNotificationsModuleProvider: XMPPPushNotificationsModuleProviderProtocol {
    
    func mutedChats(for context: Context) -> [BareJID] {
        return DBChatStore.instance.chats(for: context).filter({ $0.options.notifications == .none }).map({ $0.jid }).sorted { (j1, j2) -> Bool in
            return j1.stringValue.compare(j2.stringValue) == .orderedAscending;
        }
    }
    
    func groupchatFilterRules(for context: Context) -> [TigasePushNotificationsModule.GroupchatFilter.Rule] {
        return DBChatStore.instance.conversations(for: context.userBareJid).filter({ (c) -> Bool in
            switch c {
            case let channel as Channel:
                switch channel.options.notifications {
                case .none:
                    return false;
                case .always, .mention:
                    return true;
                }
            case let room as XMPPRoom:
                switch room.options.notifications {
                case .none:
                    return false;
                case .always, .mention:
                    return true;
                }
            default:
                break;
            }
            return false;
        }).sorted(by: { (r1, r2) -> Bool in
            return r1.jid.stringValue.compare(r2.jid.stringValue) == .orderedAscending;
        }).map({ (c) -> TigasePushNotificationsModule.GroupchatFilter.Rule in
            switch c {
            case let channel as Channel:
                switch channel.options.notifications {
                case .none:
                    return .never(room: channel.channelJid);
                case .always:
                    return .always(room: channel.channelJid);
                case .mention:
                    return .mentioned(room: channel.channelJid, nickname: channel.nickname ?? "");
                }
            case let room as XMPPRoom:
                switch room.options.notifications {
                case .none:
                    return .never(room: room.roomJid);
                case .always:
                    return .always(room: room.roomJid);
                case .mention:
                    return .mentioned(room: room.roomJid, nickname: room.nickname);
                }
            default:
                // should not happen
                return .never(room: c.account);
            }
        });
    }
    
}
