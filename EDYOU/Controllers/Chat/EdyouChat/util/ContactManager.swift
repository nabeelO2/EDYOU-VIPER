//
// ContactManager.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import UIKit
import Combine

public class Contact: DisplayableIdWithKeyProtocol {

    public let key: Key;
    
    public var account: BareJID {
        return key.account;
    }
    public var jid: BareJID {
        return key.jid;
    }
    
    @Published
    public var displayName: String;
    public var displayNamePublisher: Published<String>.Publisher {
        return $displayName;
    }
    
    @Published
    public var status: Presence.Show?;
    public var statusPublisher: Published<Presence.Show?>.Publisher {
        return $status;
    }
    
    @Published
    public var description: String?;
    public var descriptionPublisher: Published<String?>.Publisher {
        return $description;
    }
    
    public let avatar: Avatar;
    public var avatarPublisher: AnyPublisher<UIImage?, Never> {
        return avatar.avatarPublisher;
    }

    public init(key: Key, displayName: String, status: Presence.Show?) {
        self.key = key;
        self.displayName = displayName;
        self.status = status;
        self.avatar = AvatarManager.instance.avatarPublisher(for: .init(account: key.account, jid: key.jid, mucNickname: nil));
    }
    
    deinit {
        ContactManager.instance.release(key);
    }
    
    public struct Key: Hashable, Equatable {
        public let account: BareJID;
        public let jid: BareJID;
        public let type: KeyType
    }

    public enum KeyType: Hashable, Equatable {
        case buddy
        case occupant(nickname: String)
        case participant(id: String)
    }
    
    public struct Weak {
        weak var contact: Contact?;
    }
    
}

public class ContactManager {
    
    public let dispatcher = QueueDispatcher(label: "contactManager");
    public static let instance = ContactManager();
    
    private var items: [Contact.Key: Contact.Weak] = [:];
    private var cancellables: Set<AnyCancellable> = [];
    
    public init() {
        PresenceStore.instance.bestPresenceEvents.receive(on: dispatcher.queue).sink(receiveValue: { [weak self] event in
            self?.update(presence: event.presence, for: .init(account: event.account, jid: event.jid, type: .buddy));
        }).store(in: &cancellables);
    }
    
    public func contact(for key: Contact.Key) -> Contact {
        return dispatcher.sync(execute: {
            if let contact = self.items[key]?.contact {
                return contact;
            } else {
                let contact = Contact(key: key, displayName: self.name(for: key), status: self.status(for: key));
                self.items[key] = Contact.Weak(contact: contact);
                return contact;
            }
        });
    }
    
    public func existingContact(for key: Contact.Key) -> Contact? {
        return dispatcher.sync(execute: {
            return self.items[key]?.contact;
        })
    }
    
    public func update(name: String?, for key: Contact.Key) {
        dispatcher.async {
            guard let contact = self.items[key]?.contact else {
                return;
            }
            DispatchQueue.main.async {
                contact.displayName = name ?? key.jid.stringValue;
            }
        }
    }
    
    public func update(presence: Presence?, for key: Contact.Key) {
        dispatcher.async {
            guard let contact = self.items[key]?.contact else {
                return;
            }
            DispatchQueue.main.async {
                contact.status = presence?.show;
                contact.description = presence?.status;
            }
        }
    }
    
    private func status(for key: Contact.Key) -> Presence.Show? {
        switch key.type {
        case .buddy:
            return PresenceStore.instance.bestPresence(for: key.jid, on: key.account)?.show;
        case .participant(let id):
            return PresenceStore.instance.bestPresence(for: BareJID(localPart: "\(id)#\(key.jid.localPart ?? "")", domain: key.jid.domain), on: key.account)?.show;
        case .occupant(let nickname):
            return (DBChatStore.instance.conversation(for: key.account, with: key.jid) as? XMPPRoom)?.occupant(nickname: nickname)?.presence.show;
        }
    }

    private func name(for key: Contact.Key) -> String {
        switch key.type {
        case .buddy:
            return DBRosterStore.instance.item(for: key.account, jid: JID(key.jid))?.name ?? key.jid.stringValue;
        case .participant(let id):
            return (DBChatStore.instance.conversation(for: key.account, with: key.jid) as? Channel)?.participant(withId: id)?.nickname ?? id;
        case .occupant(let nickname):
            return nickname;
        }
    }
    
    fileprivate func release(_ key: Contact.Key) {
        dispatcher.async {
            if let weak = self.items[key], weak.contact == nil {
                self.items.removeValue(forKey: key);
            }
        }
    }
    
}
