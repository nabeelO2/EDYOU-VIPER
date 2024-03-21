//
// AvatarEventHandler.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import Combine
import os

class AvatarEventHandler: XmppServiceExtension {
    
    static let instance = AvatarEventHandler();
    
    private let queue = DispatchQueue(label: "AvatarEventHandler");

    private init() {
    }
        
    func register(for client: XMPPClient, cancellables: inout Set<AnyCancellable>) {
        client.module(.presence).presencePublisher.filter({ $0.presence.type != .error }).sink(receiveValue: { [weak client] e in
            guard let photoId = e.presence.vcardTempPhoto, let to = e.presence.to?.bareJid else {
                return;
            }
            self.queue.async {
                if e.presence.findChild(name: "x", xmlns: "http://jabber.org/protocol/muc#user") == nil {
                    AvatarManager.instance.avatarHashChanged(for: e.jid.bareJid, on: to, type: .vcardTemp, hash: photoId);
                } else {
                    os_log(OSLogType.debug, log: .avatar, "received presence from %s with avaar hash: %{public}s", e.presence.from!.stringValue, photoId);
                    guard let client = client else {
                        return;
                    }
                    if !AvatarManager.instance.hasAvatar(withHash: photoId) {
                        os_log(OSLogType.debug, log: .avatar, "querying %s for VCard for avaar hash: %{public}s", e.presence.from!.stringValue, photoId);
                        client.module(.vcardTemp).retrieveVCard(from: e.jid, completionHandler: { result in
                            switch result {
                            case .success(let vcard):
                                os_log(OSLogType.debug, log: .avatar, "got result %s with %d photos from %s VCard for avaar hash: %{public}s", String(describing: type(of: vcard).self), vcard.photos.count, e.presence.from!.stringValue, photoId);
                                vcard.photos.forEach({ photo in
                                    os_log(OSLogType.debug, log: .avatar, "got photo from %s VCard for avaar hash: %{public}s", e.presence.from!.stringValue, photoId);
                                    self.queue.async {
                                        AvatarManager.fetchData(photo: photo, completionHandler: { result in
                                            if let data = result {
                                                _ = AvatarManager.instance.storeAvatar(data: data);
                                                AvatarManager.instance.avatarUpdated(hash: photoId, for: e.jid.bareJid, on: to, withNickname: e.jid.resource);
                                            }
                                        })
                                    }
                                })
                            case .failure(let error):
                                os_log(OSLogType.debug, log: .avatar, "got error %{public}s from %s VCard for avaar hash: %{public}s", error.description, e.presence.from!.stringValue, photoId);
                                break;
                            }
                        })
                    } else {
                        AvatarManager.instance.avatarUpdated(hash: photoId, for: e.jid.bareJid, on: to, withNickname: e.jid.resource);
                    }
                }
            }
        }).store(in: &cancellables);
        client.module(.pepUserAvatar).avatarChangePublisher.sink(receiveValue: { [weak client] e in
            guard let account = client?.userBareJid else {
                return;
            }
            guard let item = e.info.first(where: { info -> Bool in
                return info.url == nil;
            }) else {
                return;
            }
            self.queue.async {
                AvatarManager.instance.avatarHashChanged(for: e.jid.bareJid, on: account, type: .pepUserAvatar, hash: item.id);
            }
        }).store(in: &cancellables);
    }
    
}
