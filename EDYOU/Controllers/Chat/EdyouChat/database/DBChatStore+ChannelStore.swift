//
// DBChatStore+ChannelStore.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//
import Foundation
import Martin

extension DBChatStore: ChannelStore {
    
    public func channels(for context: Context) -> [Channel] {
        return convert(items: conversations(for: context.userBareJid));
    }
    
    public func channel(for context: Context, with jid: BareJID) -> Channel? {
        return conversation(for: context.userBareJid, with: jid) as? Channel;
    }
    
    public func createChannel(for context: Context, with channelJid: BareJID, participantId: String, nick: String?, state: ChannelState) -> ConversationCreateResult<Channel> {
        self.conversationsLifecycleQueue.sync {
        if let channel = channel(for: context, with: channelJid) {
            return .found(channel);
        }
    
        let account = context.userBareJid;
        guard let channel: Channel = createConversation(for: account, with: channelJid, execute: {
            let timestamp = Date();
            let options = ChannelOptions(participantId: participantId, nick: nick, state: state);
            
            let id = try! self.openConversation(account: account, jid: channelJid, type: .channel, timestamp: timestamp, options: options);
            let channel = Channel(dispatcher: self.conversationDispatcher, context: context, channelJid: channelJid, id: id, timestamp: timestamp, lastActivity: lastActivity(for: account, jid: channelJid), unread: 0, options: options, creationTimestamp: timestamp);

            return channel;
        }) else {
            if let channel = self.channel(for: context, with: channelJid) {
                return .found(channel);
            }
            return .none;
        }
        return .created(channel);
        }
    }
    
    public func close(channel: Channel) -> Bool {
        return close(conversation: channel);
    }
    
}
