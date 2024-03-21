//
// XMPPRoom.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
//import MartinOMEMO
import UIKit
import Combine
import Shared
import Intents
import uxmpp

public class XMPPRoom: ConversationBaseWithOptions<XMPPRoomOptions>, RoomProtocol, Conversation, RoomWithPushSupportProtocol {

    open override var defaultMessageType: StanzaType {
        return .groupchat;
    }

    private let occupantsStore = RoomOccupantsStoreBase();
    
    public var occupantsPublisher: AnyPublisher<[MucOccupant], Never> {
        return occupantsStore.occupantsPublisher;
    }
    
    private let displayable: RoomDisplayableId;
    @Published
    public var role: MucRole = .none;
    @Published
    public var affiliation: MucAffiliation = .none;
    
    @Published
    public private(set) var state: RoomState = .not_joined() {
        didSet {
            switch state {
            case .joined:
                DispatchQueue.main.async {
                    self.displayable.status = .online;
                }
            case .requested:
                DispatchQueue.main.async {
                    self.displayable.status = .away;
                }
            default:
                DispatchQueue.main.async {
                    self.displayable.status = nil;
                }
            }
        }
    }
    public var statePublisher: AnyPublisher<RoomState, Never> {
        return $state.eraseToAnyPublisher();
    }
    
    public var subject: String? {
        get {
            return displayable.description;
        }
        set {
            DispatchQueue.main.async {
                self.displayable.description = newValue;
            }
        }
    }
    
    public var name: String? {
        return options.name;
    }
    
    public var nickname: String {
        return options.nickname;
    }
    
    public var password: String? {
        return options.password;
    }
    
    public var automaticallyFetchPreviews: Bool {
        return true;
    }
    
    public var roomJid: BareJID {
        return jid;
    }

    public var debugDescription: String {
        return "Room(account: \(account), jid: \(jid))";
    }
    
    @Published
    public var roomFeatures: Set<Feature> = [] {
        didSet {
            if self.roomFeatures.contains(.membersOnly) && self.roomFeatures.contains(.nonAnonymous) {
                if let mucModule = context?.module(.muc) {
                    var members: [JID] = [];
                    let group = DispatchGroup();
                    for affiliation: MucAffiliation in [.member, .admin, .owner] {
                        group.enter();
                        mucModule.getRoomAffiliations(from: self, with: affiliation, completionHandler: { result in
                            switch result {
                            case .success(let affs):
                                members.append(contentsOf: affs.map({ $0.jid }));
                            case .failure(_):
                                break;
                            }
                            group.leave();
                        });
                    }
                    group.notify(queue: DispatchQueue.global(), execute: { [weak self] in
                        self?.dispatcher.async {
                            self?._members = members;
                        }
                    })
                }
            }
        }
    }
        
    public enum Feature: String {
        case membersOnly = "muc_membersonly"
        case nonAnonymous = "muc_nonanonymous"
        case messageModeration = "urn:xmpp:message-moderate:0"
    }
    
    private var cancellables: Set<AnyCancellable> = [];
    
    init(dispatcher: QueueDispatcher,context: Context, jid: BareJID, id: Int, timestamp: Date, lastActivity: LastChatActivity?, unread: Int, options: XMPPRoomOptions) {
        self.displayable = RoomDisplayableId(displayName: options.name ?? jid.stringValue, status: nil, avatar: AvatarManager.instance.avatarPublisher(for: .init(account: context.userBareJid, jid: jid, mucNickname: nil)), description: nil);
        super.init(dispatcher: dispatcher, context: context, jid: jid, id: id, timestamp: timestamp, lastActivity: lastActivity, unread: unread, options: options, displayableId: displayable);
        self.statePublisher.sink{ state in
            switch state {
                case .destroyed:
                    print("destroyed")
                case .joined:
                    print("joined")
                case .not_joined(let reason):
                    print("not_joined \(reason)")
                case .requested:
                    print("requested")
            }

        }.store(in: &cancellables)
        (context.module(.httpFileUpload) as! HttpFileUploadModule).isAvailablePublisher.combineLatest(self.statePublisher, self.$roomFeatures, { isAvailable, state, roomFeatures -> [ConversationFeature] in
            var features: [ConversationFeature] = [];
            if state == .joined {
                if isAvailable {
                    features.append(.httpFileUpload);
                }
                if roomFeatures.contains(.membersOnly) && roomFeatures.contains(.nonAnonymous) {
                    features.append(.omemo);
                }
            }
            return features;
        }).sink(receiveValue: { [weak self] value in self?.update(features: value); }).store(in: &cancellables);
    }

    @Published
    public var roomUsers: Set<JID> = []

    public func fetchAllMember(_ affiliation:String = "member") {
        if affiliation.isEmpty {
            return
        }
        let iq = Iq()
        iq.type = .get
        iq.id = UUID().getCleanString
        iq.to = JID(self.roomJid)
        let discoItemsQuery = Element(name: "query", xmlns: "http://jabber.org/protocol/muc#admin")
        let member = Element(name: "item",xmlns: nil)
        member.setAttribute("affiliation", value: affiliation)
        discoItemsQuery.addChild(member)
        iq.addChild(discoItemsQuery)
        self.context?.writer.write(iq,completionHandler: {
            result in
            switch result {
                case .success(let iqa):
                    let items = iqa.children.first?.children ?? []
                    print(items)
                    for itemElement in items {
                        if let jid = itemElement.getAttribute("jid") {
                            self.roomUsers.insert(JID(jid))
                        }
                    }
                    self.roomUsers.insert(JID(self.account.stringValue))
                    if affiliation == "member" {
                        self.fetchAllMember("owner")
                    } else if affiliation == "owner" {
                        self.fetchAllMember("admin")
                    }else if affiliation == "admin" {
                        self.fetchAllMember("none")
                    } else {
                        print(self.roomUsers)
                        self.fetchAllMember("")
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
            }
        })
    }
    
    public override func isLocal(sender: ConversationEntrySender) -> Bool {
        switch sender {
        case .occupant(let nickname, let jid):
            guard let jid = jid else {
                return nickname == self.nickname;
            }
            return jid == account;
        default:
            return false;
        }
    }
    
    private static let nonMembersAffiliations: Set<MucAffiliation> = [.none, .outcast];
    private var _members: [JID]?;
    public var members: [JID]? {
        return dispatcher.sync {
            return _members;
        }
    }
    
    public var occupants: [MucOccupant] {
        return dispatcher.sync {
            return self.occupantsStore.occupants;
        }
    }
    
    public func occupant(nickname: String) -> MucOccupant? {
        return dispatcher.sync {
            return occupantsStore.occupant(nickname: nickname);
        }
    }
    
    public func addOccupant(nickname: String, presence: Presence) -> MucOccupant {
        let occupant = MucOccupant(nickname: nickname, presence: presence, for: self);
        dispatcher.async(flags: .barrier) {
            self.occupantsStore.add(occupant: occupant);
            if let jid = occupant.jid {
                if !XMPPRoom.nonMembersAffiliations.contains(occupant.affiliation) {
                    if !(self._members?.contains(jid) ?? false) {
                        self._members?.append(jid);
                    }
                } else {
                    self._members = self._members?.filter({ $0 != jid });
                }
            }
        }
        return occupant;
    }
    
    public func remove(occupant: MucOccupant) {
        dispatcher.async(flags: .barrier) {
            self.occupantsStore.remove(occupant: occupant);
            if let jid = occupant.jid {
                self._members = self._members?.filter({ $0 != jid });
            }
        }
    }
    
    public func addTemp(nickname: String, occupant: MucOccupant) {
        dispatcher.async(flags: .barrier) {
            self.occupantsStore.addTemp(nickname: nickname, occupant: occupant);
        }
    }
    
    public func removeTemp(nickname: String) -> MucOccupant? {
        return dispatcher.sync(flags: .barrier) {
            return occupantsStore.removeTemp(nickname: nickname);
        }
    }
    
    public func updateRoom(name: String?) {
        updateOptions({ options in
            options.name = name;
        });
    }
    
    public override func updateOptions(_ fn: @escaping (inout XMPPRoomOptions) -> Void, completionHandler: (()->Void)? = nil) {
        super.updateOptions(fn, completionHandler: completionHandler);
        DispatchQueue.main.async {
            self.displayable.displayName = self.options.name ?? self.jid.stringValue;
        }
    }
    
    public func update(state: RoomState) {
        dispatcher.async(flags: .barrier) {
            self.state = state;
            if state != .joined && state != .requested {
                self.occupantsStore.removeAll();
                self._members = nil;
            }
        }
    }
        
    public override func createMessage(text: String, id: String, type: StanzaType) -> Message {
        let msg = super.createMessage(text: text, id: id, type: type);
        msg.isMarkable = true;
        return msg;
    }
    
    public func sendMessage(text: String, correctedMessageOriginId: String?) {
        let encryption = self.features.contains(.omemo) ? self.options.encryption ?? Settings.messageEncryption : .none;
        
        let message = self.createMessage(text: text);
        message.lastMessageCorrectionId = correctedMessageOriginId;


        if encryption == .omemo, let omemoModule = context?.modulesManager.module(.omemo) {
//            guard let members = self.members else {
//                return;
//            }
            let members = self.roomUsers
            omemoModule.encode(message: message, for: members.map({ BareJID($0.stringValue)}), completionHandler: { result in
                switch result {
                case .failure(let error):
                    break;
                case .successMessage(let message, let fingerprint):
                    super.send(message: message, completionHandler: nil);
                    if #available(iOS 15.0, *) {
                        let sender = INPerson(personHandle: INPersonHandle(value: self.account.stringValue, type: .unknown), nameComponents: nil, displayName: self.nickname, image: AvatarManager.instance.avatar(for: self.account, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.account.stringValue, isMe: true, suggestionType: .instantMessageAddress);
                        let recipient = INPerson(personHandle: INPersonHandle(value: self.jid.stringValue, type: .unknown), nameComponents: nil, displayName: self.displayName, image: AvatarManager.instance.avatar(for: self.jid, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.jid.stringValue, isMe: false, suggestionType: .instantMessageAddress);
                        let intent = INSendMessageIntent(recipients: [recipient], outgoingMessageType: .outgoingMessageText, content: nil, speakableGroupName: INSpeakableString(spokenPhrase: self.displayName), conversationIdentifier: "account=\(self.account.stringValue)|sender=\(self.jid.stringValue)", serviceName: "Edyou IM", sender: sender, attachments: nil);
                        let interaction = INInteraction(intent: intent, response: nil);
                        interaction.direction = .outgoing;
                        interaction.donate(completion: nil);
                    }
                    if correctedMessageOriginId == nil {
                        DBChatHistoryStore.instance.appendItem(for: self, state: .outgoing(.sent), sender: .occupant(nickname: self.nickname, jid: nil), type: .message, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: text, options: .init(recipient: .none, encryption: .decrypted(fingerprint: fingerprint), isMarkable: true), linkPreviewAction: .auto, completionHandler: nil);
                    }
                }
            });
        } else {
            super.send(message: message, completionHandler: nil);
            if #available(iOS 15.0, *) {
                let sender = INPerson(personHandle: INPersonHandle(value: self.account.stringValue, type: .unknown), nameComponents: nil, displayName: self.nickname, image: AvatarManager.instance.avatar(for: self.account, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.account.stringValue, isMe: true, suggestionType: .instantMessageAddress);
                let recipient = INPerson(personHandle: INPersonHandle(value: self.jid.stringValue, type: .unknown), nameComponents: nil, displayName: self.displayName, image: AvatarManager.instance.avatar(for: self.jid, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.jid.stringValue, isMe: false, suggestionType: .instantMessageAddress);
                let intent = INSendMessageIntent(recipients: [recipient], outgoingMessageType: .outgoingMessageText, content: nil, speakableGroupName: INSpeakableString(spokenPhrase: self.displayName), conversationIdentifier: "account=\(self.account.stringValue)|sender=\(self.jid.stringValue)", serviceName: "Edyou IM", sender: sender, attachments: nil);
                let interaction = INInteraction(intent: intent, response: nil);
                interaction.direction = .outgoing;
                interaction.donate(completion: nil);
            }
            if correctedMessageOriginId == nil {
                DBChatHistoryStore.instance.appendItem(for: self, state: .outgoing(.sent), sender: .occupant(nickname: self.nickname, jid: nil), type: .message, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: text, options: .init(recipient: .none, encryption: .none, isMarkable: true), linkPreviewAction: .auto, completionHandler: nil);
            }
        }
    }
    
    public func prepareAttachment(url originalURL: URL, completionHandler: @escaping (Result<(URL, Bool, ((URL) -> URL)?), ShareError>) -> Void) {
        let encryption = self.features.contains(.omemo) ? self.options.encryption ?? Settings.messageEncryption : .none;
        switch encryption {
        case .none:
            completionHandler(.success((originalURL, false, nil)));
        case .omemo:
            guard let omemoModule: OMEMOModule = self.context?.module(.omemo), let data = try? Data(contentsOf: originalURL) else {
                completionHandler(.failure(.unknownError));
                return;
            }
            let result = omemoModule.encryptFile(data: data);
            switch result {
            case .success(let (encryptedData, hash)):
                let tmpFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString);
                do {
                    try encryptedData.write(to: tmpFile);
                    completionHandler(.success((tmpFile, true, { url in
                        var parts = URLComponents(url: url, resolvingAgainstBaseURL: true)!;
                        parts.scheme = "aesgcm";
                        parts.fragment = hash;
                        let shareUrl = parts.url!;

                        return shareUrl;
                    })));
                } catch {
                    completionHandler(.failure(.noAccessError));
                }
            case .failure(_):
                completionHandler(.failure(.unknownError));
            }
        }
    }
    
    public func sendAttachment(url uploadedUrl: String, appendix: ChatAttachmentAppendix, originalUrl: URL?, completionHandler: (() -> Void)?) {
        guard ((self.context as? XMPPClient)?.state ?? .disconnected()) == .connected(), self.state == .joined else {
            completionHandler?();
            return;
        }
        
        let encryption = self.features.contains(.omemo) ? self.options.encryption ?? Settings.messageEncryption : .none;
        
        let message = self.createMessage(text: uploadedUrl);
        if encryption == .omemo, let omemoModule = context?.modulesManager.module(.omemo) {
//            guard let members = self.members else {
//                completionHandler?();
//                return;
//            }
            let members = self.roomUsers
            omemoModule.encode(message: message, for: members.map({ $0.bareJid }), completionHandler: { result in
                switch result {
                case .failure(let error):
                    break;
                case .successMessage(let message, let fingerprint):
                    super.send(message: message, completionHandler: nil);
                    if #available(iOS 15.0, *) {
                        let sender = INPerson(personHandle: INPersonHandle(value: self.account.stringValue, type: .unknown), nameComponents: nil, displayName: self.nickname, image: AvatarManager.instance.avatar(for: self.account, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.account.stringValue, isMe: true, suggestionType: .instantMessageAddress);
                        let recipient = INPerson(personHandle: INPersonHandle(value: self.jid.stringValue, type: .unknown), nameComponents: nil, displayName: self.displayName, image: AvatarManager.instance.avatar(for: self.jid, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.jid.stringValue, isMe: false, suggestionType: .instantMessageAddress);
                        let intent = INSendMessageIntent(recipients: [recipient], outgoingMessageType: .outgoingMessageText, content: nil, speakableGroupName: INSpeakableString(spokenPhrase: self.displayName), conversationIdentifier: "account=\(self.account.stringValue)|sender=\(self.jid.stringValue)", serviceName: "Edyou IM", sender: sender, attachments: nil);
                        let interaction = INInteraction(intent: intent, response: nil);
                        interaction.direction = .outgoing;
                        interaction.donate(completion: nil);
                    }
                    DBChatHistoryStore.instance.appendItem(for: self, state: .outgoing(.sent), sender: .occupant(nickname: self.nickname, jid: nil), type: .attachment, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: uploadedUrl, appendix: appendix, options: .init(recipient: .none, encryption: .decrypted(fingerprint: fingerprint), isMarkable: true), linkPreviewAction: .auto, completionHandler: { msgId in
                        if let url = originalUrl {
                            _ = DownloadStore.instance.store(url, filename: appendix.filename ?? url.lastPathComponent, with: "\(msgId)");
                        }
                    });
                }
                completionHandler?();
            });
        } else {
            message.oob = uploadedUrl;
            super.send(message: message, completionHandler: nil);
            if #available(iOS 15.0, *) {
                let sender = INPerson(personHandle: INPersonHandle(value: self.account.stringValue, type: .unknown), nameComponents: nil, displayName: self.nickname, image: AvatarManager.instance.avatar(for: self.account, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.account.stringValue, isMe: true, suggestionType: .instantMessageAddress);
                let recipient = INPerson(personHandle: INPersonHandle(value: self.jid.stringValue, type: .unknown), nameComponents: nil, displayName: self.displayName, image: AvatarManager.instance.avatar(for: self.jid, on: self.account)?.inImage(), contactIdentifier: nil, customIdentifier: self.jid.stringValue, isMe: false, suggestionType: .instantMessageAddress);
                let intent = INSendMessageIntent(recipients: [recipient], outgoingMessageType: .outgoingMessageText, content: nil, speakableGroupName: INSpeakableString(spokenPhrase: self.displayName), conversationIdentifier: "account=\(self.account.stringValue)|sender=\(self.jid.stringValue)", serviceName: "Edyou IM", sender: sender, attachments: nil);
                let interaction = INInteraction(intent: intent, response: nil);
                interaction.direction = .outgoing;
                interaction.donate(completion: nil);
            }
            DBChatHistoryStore.instance.appendItem(for: self, state: .outgoing(.sent), sender: .occupant(nickname: self.nickname, jid: nil), type: .attachment, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: uploadedUrl, appendix: appendix, options: .init(recipient: .none, encryption: .none, isMarkable: true), linkPreviewAction: .auto, completionHandler: { msgId in
                if let url = originalUrl {
                    _ = DownloadStore.instance.store(url, filename: appendix.filename ?? url.lastPathComponent, with: "\(msgId)");
                }
            });
        }
    }
    public func sendPrivateMessage(to occupant: MucOccupant, text: String) {
        let message = self.createPrivateMessage(text, recipientNickname: occupant.nickname);
        let options = ConversationEntry.Options(recipient: .occupant(nickname: occupant.nickname), encryption: .none, isMarkable: false)
        DBChatHistoryStore.instance.appendItem(for: self, state: .outgoing(.sent), sender: .occupant(nickname: self.options.nickname, jid: nil), type: .message, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: text, appendix: nil, options: options, linkPreviewAction: .auto, completionHandler: nil);
        self.send(message: message, completionHandler: nil);
    }
    
    public func moderate(entry: ConversationEntry, completionHandler: @escaping (Result<Void,XMPPError>)->Void) {
        guard roomFeatures.contains(.messageModeration), let stableIds = DBChatHistoryStore.instance.stableIds(forId: entry.id), let remoteId = stableIds.remote else {
            completionHandler(.failure(.feature_not_implemented));
            return;
        }
        moderateMessage(id: remoteId, completionHandler: completionHandler);
    }
    
    public func canSendChatMarker() -> Bool {
        return self.roomFeatures.contains(.membersOnly) && self.roomFeatures.contains(.nonAnonymous);
    }
    
    public func sendChatMarker(_ marker: Message.ChatMarkers, andDeliveryReceipt receipt: Bool) {
        guard Settings.confirmMessages else {
            return;
        }
        
        guard ((self.context as? XMPPClient)?.state ?? .disconnected()) == .connected(), self.state == .joined else {
            return;
        }
        
        if self.options.confirmMessages && canSendChatMarker() {
            let message = self.createMessage();
            message.chatMarkers = marker;
            message.hints = [.store]
            if receipt {
                message.messageDelivery = .received(id: marker.id)
            }
            self.send(message: message, completionHandler: nil);
        } else if case .displayed(_) = marker {
            let message = self.createPrivateMessage(recipientNickname: self.nickname);
            message.chatMarkers = marker;
            message.hints = [.store]
            self.send(message: message, completionHandler: nil);
        }
        
    }
    
    private class RoomDisplayableId: DisplayableIdProtocol {
        
        @Published
        var displayName: String
        var displayNamePublisher: Published<String>.Publisher {
            return $displayName;
        }
        
        @Published
        var status: Presence.Show?
        var statusPublisher: Published<Presence.Show?>.Publisher {
            return $status;
        }
        
        @Published
        var description: String?;
        var descriptionPublisher: Published<String?>.Publisher {
            return $description;
        }
        
        let avatar: Avatar;
        var avatarPublisher: AnyPublisher<UIImage?, Never> {
            return avatar.avatarPublisher.replaceNil(with: AvatarManager.instance.defaultGroupchatAvatar).eraseToAnyPublisher();
        }
        
        init(displayName: String, status: Presence.Show?, avatar: Avatar, description: String?) {
            self.displayName = displayName;
            self.description = description;
            self.status = status;
            self.avatar = avatar;
        }
        
    }
}

public struct XMPPRoomOptions: Codable, ChatOptionsProtocol, Equatable {

    public var name: String?;
    public let nickname: String;
    public var password: String?;

    var encryption: ChatEncryption?;
    public var notifications: ConversationNotification = .mention;
    public var confirmMessages: Bool = true;

    init(nickname: String, password: String?) {
        self.nickname = nickname;
        self.password = password;
    }
    
    init(nickname: String, password: String?,name : String?) {
        self.nickname = nickname;
        self.password = password;
        self.name = name
    }
    
    
    init() {
        nickname = "";
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        encryption = try container.decodeIfPresent(String.self, forKey: .encryption).flatMap(ChatEncryption.init(rawValue: ));
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nick) ?? "";
        password = try container.decodeIfPresent(String.self, forKey: .password)
        notifications = ConversationNotification(rawValue: try container.decodeIfPresent(String.self, forKey: .notifications) ?? "") ?? .mention;
        confirmMessages = try container.decodeIfPresent(Bool.self, forKey: .confirmMessages) ?? true;
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encodeIfPresent(encryption?.rawValue, forKey: .encryption);
        try container.encodeIfPresent(name, forKey: .name);
        try container.encodeIfPresent(nickname, forKey: .nick);
        try container.encodeIfPresent(password, forKey: .password);
        if notifications != .mention {
            try container.encode(notifications.rawValue, forKey: .notifications);
        }
        try container.encode(confirmMessages, forKey: .confirmMessages)
    }
     
    public func equals(_ options: ChatOptionsProtocol) -> Bool {
        guard let options = options as? XMPPRoomOptions else {
            return false;
        }
        return options == self;
    }
    
    enum CodingKeys: String, CodingKey {
        case encryption = "encrypt"
        case name = "name";
        case nick = "nick";
        case password = "password";
        case notifications = "notifications";
        case confirmMessages = "confirmMessages"
    }
}
