//
// Conversation.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import TigaseSQLite3
import Martin
import Combine
import Shared

public enum ConversationFeature {
    case omemo
    case httpFileUpload
}

public protocol Conversation: ConversationProtocol, ConversationKey, DisplayableIdWithKeyProtocol {
        
    var status: Presence.Show? { get }
    var statusPublisher: Published<Presence.Show?>.Publisher { get }
    
    var displayName: String { get }
    var displayNamePublisher: Published<String>.Publisher { get }
    
    var id: Int { get }
    var timestamp: Date { get }
    var timestampPublisher: AnyPublisher<Date,Never> { get }
    var unread: Int { get }
    var unreadPublisher: AnyPublisher<Int,Never> { get }
    var lastActivity: LastConversationActivity? { get }
    var lastActivityPublisher: Published<LastConversationActivity?>.Publisher { get }
    
    var notifications: ConversationNotification { get }
    
    var automaticallyFetchPreviews: Bool { get }
    
    var markersPublisher: AnyPublisher<[ChatMarker],Never> { get }
    
    var features: [ConversationFeature] { get }
    var featuresPublisher: AnyPublisher<[ConversationFeature],Never> { get }
    
    func mark(as markerType: ChatMarker.MarkerType, before: Date, by sender: ConversationEntrySender);
    func markAsRead(count: Int) -> Bool;
    func update(lastActivity: LastConversationActivity?, timestamp: Date, isUnread: Bool) -> Bool;
    
    func sendMessage(text: String, correctedMessageOriginId: String?);
    func prepareAttachment(url: URL, completionHandler: @escaping (Result<(URL,Bool,((URL)->URL)?),ShareError>)->Void);
    func sendAttachment(url: String, appendix: ChatAttachmentAppendix, originalUrl: URL?, completionHandler: (()->Void)?);
    func canSendChatMarker() -> Bool;
    func sendChatMarker(_ marker: Message.ChatMarkers, andDeliveryReceipt: Bool);
    
    func isLocal(sender: ConversationEntrySender) -> Bool;
}

//import MartinOMEMO
import uxmpp

extension Conversation {
     
    
    func loadItems(_ type: ConversationLoadType) -> [ConversationEntry] {
        return DBChatHistoryStore.instance.history(for: self, queryType: type);
    }
    
    func retract(entry: ConversationEntry) {
        guard context != nil else {
            return;
        }
        DBChatHistoryStore.instance.originId(for: account, with: jid, id: entry.id, completionHandler: { originId in
            let message = self.createMessageRetraction(forMessageWithId: originId);
            self.send(message: message, completionHandler: nil);
            DBChatHistoryStore.instance.retractMessage(for: self, stanzaId: originId, sender: entry.sender, retractionStanzaId: message.id, retractionTimestamp: Date(), serverMsgId: nil, remoteMsgId: nil);
        })
    }
}

public typealias LastConversationActivity = LastChatActivity

public enum LastChatActivity {
    case message(String, direction: MessageDirection, sender: String?)
    case attachment(String, direction: MessageDirection, sender: String?)
    case invitation(String, direction: MessageDirection, sender: String?)
    case location(String, direction: MessageDirection, sender: String?)
    
    static func from(itemType: ItemType?, data: String?, direction: MessageDirection, sender: String?) -> LastChatActivity? {
        guard itemType != nil else {
            return nil;
        }
        switch itemType! {
        case .message:
            return data == nil ? nil : .message(data!, direction: direction, sender: sender);
        case .location:
            return data == nil ? nil : .location(data!, direction: direction, sender: sender);
        case .invitation:
            return data == nil ? nil : .invitation(data!, direction: direction, sender: sender);
        case .attachment:
            return data == nil ? nil : .attachment(data!, direction: direction, sender: sender);
        case .linkPreview:
            return nil;
        case .messageRetracted, .attachmentRetracted:
            // TODO: Should we notify user that last message was retracted??
            return nil;
        }
    }
}

typealias ConversationEncryption = ChatEncryption

public enum ChatEncryption: String, Codable, CustomStringConvertible {
    case none = "none";
    case omemo = "omemo";
    
    public var description: String {
        switch self {
        case .none:
            return NSLocalizedString("None", comment: "encyption option");
        case .omemo:
            return NSLocalizedString("OMEMO", comment: "encryption option");
        }
    }
}

public protocol ChatOptionsProtocol: DatabaseConvertibleStringValue {
    
    var notifications: ConversationNotification { get }
    
    var confirmMessages: Bool { get }
    
    func equals(_ options: ChatOptionsProtocol) -> Bool
}

public struct ChatMarker: Hashable {
    let sender: ConversationEntrySender;
    let timestamp: Date;
    let type: MarkerType;
        
    public enum MarkerType: Int, Comparable, Hashable {
        case received = 0
        case displayed = 1

        public var label: String {
            switch self {
            case .received:
                return NSLocalizedString("Received", comment: "label for chat marker")
            case .displayed:
                return NSLocalizedString("Displayed", comment: "label for chat marker")
            }
        }
        
        public static func < (lhs: MarkerType, rhs: MarkerType) -> Bool {
            return lhs.rawValue < rhs.rawValue;
        }

        static func from(chatMarkers: Message.ChatMarkers) -> MarkerType {
            switch chatMarkers {
            case .received(_):
                return .received;
            case .displayed(_), .acknowledged(_):
                return .displayed;
            }
        }
    }
}

extension Conversation {
     
//    public func readTillTimestampPublisher(for jid: JID) -> Published<Date?>.Publisher {
//        return entry(for: jid).$timestamp;
//    }
//    
//    public func markers(inRange range: ClosedRange<Date>) -> [Date] {
//        return chatMarkers.filter({ (arg0) -> Bool in
//            let (key, value) = arg0;
//            return key.account == self.account && key.conversationJID == self.jid && value.timestamp != nil && range.contains(value.timestamp!);
//        }).map { (arg0) -> Date in
//            let (_, value) = arg0
//            return value.timestamp!;
//        }
//    }
    
}
