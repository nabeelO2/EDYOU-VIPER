//
// DBChatStore+ChatStore.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import Foundation
import Martin

extension DBChatStore: ChatStore {
    public func chats(for context: Context) -> [Chat] {
        return convert(items: self.conversations(for: context.userBareJid));
    }
    
    public func chat(for context: Context, with jid: BareJID) -> Chat? {
        return conversation(for: context.userBareJid, with: jid) as? Chat;
    }
    
    public func createChat(for context: Context, with jid: BareJID,name:String) -> ConversationCreateResult<Chat> {
        defer {
            self.refreshConversationsList()
        }
        guard let client = XmppService.instance.getClient(for: context.userBareJid) else {
            return createChat(for: context, with: jid);
        }

        if DBRosterStore.instance.item(for: context.userBareJid, jid: JID(jid)) == nil {
            DBRosterStore.instance.addFrindToRoster(client: client , jid: jid, userName: name)
        }

        if let conversation = DBChatStore.instance.conversation(for: context.userBareJid, with: jid) {
            return .found(conversation as! Chat)
        } else {
            if let chat = client.module(.message).chatManager.createChat(for: client, with: jid) {
                return .created(chat as! Chat)
            } else {
                return createChat(for: context, with: jid)
            }
        }
    }

    public func createChat(for context: Context, with jid: BareJID) -> ConversationCreateResult<Chat> {
        self.conversationsLifecycleQueue.sync {
        if let chat = chat(for: context, with: jid) {
            return .found(chat);
        }
    
        let account = context.userBareJid;
        guard let chat: Chat = createConversation(for: account, with: jid, execute: {
            let timestamp = Date();
            let id = try! self.openConversation(account: account, jid: jid, type: .chat, timestamp: timestamp, options: nil);
            let chat = Chat(dispatcher: self.conversationDispatcher, context: context, jid: jid, id: id, timestamp: timestamp, lastActivity: lastActivity(for: account, jid: jid), unread: 0, options: ChatOptions());

            return chat;
        }) else {
            if let chat = self.chat(for: context, with: jid) {
                return .found(chat);
            }
            return .none;
        }
        return .created(chat);
        }
    }
    public func close(chat: Chat) -> Bool {
        return close(conversation: chat);
    }
 
}
