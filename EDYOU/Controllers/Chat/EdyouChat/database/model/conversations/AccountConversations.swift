//
// AccountConversations.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

public class AccountConversations {

    private var conversations = [BareJID: Conversation]();

    private let queue = DispatchQueue(label: "accountChats");

    var count: Int {
        return self.queue.sync(execute: {
            return self.conversations.count;
        })
    }

    var items: [Conversation] {
        return self.queue.sync(execute: {
            return self.conversations.values.map({ (chat) -> Conversation in
                return chat;
            });
        });
    }

    init(items: [Conversation]) {
        items.forEach { item in
            self.conversations[item.jid] = item;
        }
    }

    func open(with jid: BareJID, execute: () -> Conversation) -> Conversation? {
        return self.queue.sync(execute: {
            var chats = self.conversations;
            guard let existingChat = chats[jid] else {
                let conversation = execute();
                chats[jid] = conversation;
                self.conversations = chats;
                return conversation;
            }
            return existingChat;
        });
    }

    func close(conversation: Conversation, execute: ()->Void) -> Bool {
        return self.queue.sync(execute: {
            var chats = self.conversations;
            let removed = chats.removeValue(forKey: conversation.jid) != nil;
            self.conversations = chats;
            if removed {
                execute();
            }
            return removed;
        });
    }

    func get(with jid: BareJID) -> Conversation? {
        return self.queue.sync(execute: {
            let chats = self.conversations;
            return chats[jid];
        });
    }

    func lastMessageTimestamp() -> Date {
        return self.queue.sync(execute: {
            var timestamp = Date(timeIntervalSince1970: 0);
            self.conversations.values.forEach { (chat) in
                guard chat.lastActivity != nil else {
                    return;
                }
                timestamp = max(timestamp, chat.timestamp);
            }
            return timestamp;
        });
    }
}
