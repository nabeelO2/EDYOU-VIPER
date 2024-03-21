//
// AvatarManager.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import Martin
import Combine
import TigaseLogging

struct AvatarWeakRef {
    weak var avatar: Avatar?;
}

public class Avatar {

    private enum AvatarResult: Equatable {
        case notReady
        case ready(UIImage?)
    }
    
    private let key: Key;

    public var hash: String? {
        didSet {
            if let hash = hash {
                AvatarManager.instance.avatar(withHash: hash, completionHandler: { result in
                    guard hash == self.hash else {
                        return;
                    }
                    switch result {
                    case .success(let avatar):
                        self.avatarSubject.send(.ready(avatar));
                    case .failure(_):
                        self.avatarSubject.send(.ready(nil));
                    }

                });
            } else {
                self.avatarSubject.send(.ready(nil));
            }
        }
    }
    
    private let avatarSubject = CurrentValueSubject<AvatarResult,Never>(.notReady);
    public let avatarPublisher: AnyPublisher<UIImage?,Never>;
    
    init(key: Key) {
        self.key = key;
        self.avatarPublisher = avatarSubject.filter({ .notReady != $0 }).map({
            switch $0 {
            case .notReady:
                return nil;
            case .ready(let image):
                return image;
            }
        }).removeDuplicates().eraseToAnyPublisher();
    }

    deinit {
        AvatarManager.instance.releasePublisher(for: key);
    }
    
    struct Key: Hashable, CustomStringConvertible {
        let account: BareJID;
        let jid: BareJID;
        let mucNickname: String?;
        
        var description: String {
            return "Key(account: \(account), jid: \(jid), nick: \(mucNickname ?? ""))";
        }
    }

}

class AvatarManager {

    public static let AVATAR_CHANGED = Notification.Name("avatarChanged");
    public static let AVATAR_FOR_HASH_CHANGED = Notification.Name("avatarForHashChanged");
    public static let instance = AvatarManager();

    fileprivate let store = AvatarStore();
    public var defaultAvatar: UIImage {
        return UIImage(named: "defaultAvatar")!;
    }
    public var defaultGroupchatAvatar: UIImage {
        return UIImage(named: "defaultGroupchatAvatar")!;
    }
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AvatarManager");
    
    fileprivate var dispatcher = QueueDispatcher(label: "avatar_manager", attributes: .concurrent);

    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(vcardUpdated), name: DBVCardStore.VCARD_UPDATED, object: nil);
    }

    private var avatars: [Avatar.Key: AvatarWeakRef] = [:];
    open func avatarPublisher(for key: Avatar.Key) -> Avatar {
        return dispatcher.sync(flags: .barrier) {
            guard let avatar = avatars[key]?.avatar else {
                let avatar = Avatar(key: key);
                DispatchQueue.global(qos: .userInitiated).async {
                    avatar.hash = self.avatarHash(for: key.jid, on: key.account, withNickname: key.mucNickname);
                }
                avatars[key] = AvatarWeakRef(avatar: avatar);
                return avatar;
            }
            return avatar;
        }
    }
    
    open func existingAvatarPublisher(for key: Avatar.Key) -> Avatar? {
        return dispatcher.sync {
            return avatars[key]?.avatar;
        }
    }
    
    open func releasePublisher(for key: Avatar.Key) {
        dispatcher.async(flags: .barrier) {
            self.avatars.removeValue(forKey: key);
        }
    }
    
    private func avatarHash(for jid: BareJID, on account: BareJID, withNickname nickname: String?) -> String? {
        if let nickname = nickname {
            guard let room = DBChatStore.instance.conversation(for: account, with: jid) as? XMPPRoom else {
                return nil;
            }
            
            guard let occupant = room.occupant(nickname: nickname) else {
                return nil;
            }
            
            guard let hash = occupant.presence.vcardTempPhoto else {
                guard let occuapntJid = occupant.jid?.bareJid else {
                    return nil;
                }
                
                return store.avatarHash(for: occuapntJid, on: account).first?.hash;
            }
            
            return hash;
        } else {
            return store.avatarHash(for: jid, on: account).first?.hash;//avatars(on: account).avatarHash(for: jid);
        }
    }
    
    open func avatar(for jid: BareJID, on account: BareJID) -> UIImage? {
        guard let hash = store.avatarHash(for: jid, on: account).first?.hash else {
            return nil;
        }
        return store.avatar(for: hash);
    }
    
    open func hasAvatar(withHash hash: String) -> Bool {
        return store.hasAvatarFor(hash: hash);
    }
    
    open func avatar(withHash hash: String) -> UIImage? {
        return store.avatar(for: hash);
    }
    
    open func avatar(withHash hash: String, completionHandler: @escaping (Result<UIImage,ErrorCondition>)->Void) {
        store.avatar(for: hash, completionHandler: completionHandler);
    }
    
    open func storeAvatar(data: Data) -> String {
        let hash = Digest.sha1.digest(toHex: data)!;
        self.store.storeAvatar(data: data, for: hash);
        NotificationCenter.default.post(name: AvatarManager.AVATAR_FOR_HASH_CHANGED, object: hash);
        return hash;
    }
    
    open func updateAvatar(hash: String, forType type: AvatarType, forJid jid: BareJID, on account: BareJID) {
        self.store.updateAvatarHash(for: jid, on: account, hash: .init(type: type, hash: hash), completionHandler: { result in
            switch result {
            case .notChanged:
                break;
            case .noAvatar:
                self.avatarUpdated(hash: nil, for: jid, on: account, withNickname: nil);
            case .newAvatar(let hash):
                self.avatarUpdated(hash: hash, for: jid, on: account, withNickname: nil);
            }
        })
    }
    
    public func avatarUpdated(hash: String?, for jid: BareJID, on account: BareJID, withNickname nickname: String?) {
        if let avatar = self.existingAvatarPublisher(for: .init(account: account, jid: jid, mucNickname: nickname)) {
            if hash == nil, let nickname = nickname {
                if let room = DBChatStore.instance.conversation(for: account, with: jid) as? XMPPRoom, let occupantJid = room.occupant(nickname: nickname)?.jid?.bareJid {
                    avatar.hash = store.avatarHash(for: occupantJid, on: account).first?.hash;
                } else {
                    avatar.hash = hash;
                }
            } else {
                avatar.hash = hash;
            }
        }
    }
    
    open func avatarHashChanged(for jid: BareJID, on account: BareJID, type: AvatarType, hash: String) {
        if hasAvatar(withHash: hash) {
            updateAvatar(hash: hash, forType: type, forJid: jid, on: account);
        } else {
            switch type {
            case .vcardTemp:
                VCardManager.instance.refreshVCard(for: jid, on: account, completionHandler: nil);
            case .pepUserAvatar:
                self.retrievePepUserAvatar(for: jid, on: account, hash: hash);
            }
        }
    }

    
    @objc func vcardUpdated(_ notification: Notification) {
        guard let vcardItem = notification.object as? DBVCardStore.VCardItem else {
            return;
        }

        DispatchQueue.global().async {
            guard let photo = vcardItem.vcard.photos.first else {
                return;
            }

            AvatarManager.fetchData(photo: photo) { data in
                guard data != nil else {
                    return;
                }

                let hash = self.storeAvatar(data: data!);
                self.updateAvatar(hash: hash, forType: .vcardTemp, forJid: vcardItem.jid, on: vcardItem.account);
            }
        }
    }

    func retrievePepUserAvatar(for jid: BareJID, on account: BareJID, hash: String) {
        guard let pepModule = XmppService.instance.getClient(for: account)?.module(.pepUserAvatar) else {
            return;
        }

        pepModule.retrieveAvatar(from: jid, itemId: hash, completionHandler: { result in
            switch result {
            case .success((let hash, let data)):
                self.store.storeAvatar(data: data, for: hash);
                self.updateAvatar(hash: hash, forType: .pepUserAvatar, forJid: jid, on: account);
            case .failure(let error):
                self.logger.error("could not retrieve avatar from: \(jid), item id: \(hash), got error: \(error.description, privacy: .public)");
            }
        });
    }

    static func fetchData(photo: VCard.Photo, completionHandler: @escaping (Data?)->Void) {
        if let data = photo.binval {
            completionHandler(Data(base64Encoded: data, options: Data.Base64DecodingOptions.ignoreUnknownCharacters));
        } else if let uri = photo.uri {
            if uri.hasPrefix("data:image") && uri.contains(";base64,") {
                let idx = uri.index(uri.firstIndex(of: ",")!, offsetBy: 1);
                let data = String(uri[idx...]);
                completionHandler(Data(base64Encoded: data, options: Data.Base64DecodingOptions.ignoreUnknownCharacters));
            } else if let url = URL(string: uri) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
                    completionHandler(data);
                }
                task.resume();
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }
    
    public func clearCache() {
        store.clearCache();
    }

}

enum AvatarResult {
    case some(AvatarType, String)
    case none
}
