//
// MucEventHandler.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import UserNotifications
import Combine

class MucEventHandler: XmppServiceExtension {
        
    static let instance = MucEventHandler();

    func register(for client: XMPPClient, cancellables: inout Set<AnyCancellable>) {
        client.$state.combineLatest(XmppService.instance.$isFetch).sink(receiveValue: { [weak client] state, isFetch in
            guard let client = client, case .connected(let resumed) = state, !resumed, !isFetch else {
                return;
            }
            client.module(.muc).roomManager.rooms(for: client).forEach { (room) in
                // first we need to check if room supports MAM
                DBChatMarkersStore.instance.awaitingSync(for: room as! XMPPRoom);
                client.module(.disco).getInfo(for: JID(room.jid), completionHandler: { result in
                    var mamVersions: [MessageArchiveManagementModule.Version] = [];
                    switch result {
                    case .success(let info):
                        mamVersions = info.features.compactMap({ MessageArchiveManagementModule.Version(rawValue: $0) });
                            (room as! XMPPRoom).roomFeatures = Set(info.features.compactMap({ XMPPRoom.Feature(rawValue: $0) }));
                    default:
                        break;
                    }
                    if let timestamp = (room as? XMPPRoom)?.timestamp {
                        if !mamVersions.isEmpty {
                            room.rejoin(fetchHistory: .skip).handle({ result in
                                guard case .success(let r) = result else {
                                    return;
                                }
                                switch r {
                                case .created(let room), .joined(let room):
                                    guard let client = room.context as? XMPPClient else {
                                        return;
                                    }
                                    MessageEventHandler.syncMessages(for: client, version: mamVersions.contains(.MAM2) ? .MAM2 : .MAM1, componentJID: JID(room.jid), since: timestamp);
                                }
                            });
                        } else {
                            DBChatMarkersStore.instance.syncCompleted(forAccount: room.account, with: room.jid);
                            _ = room.rejoin(fetchHistory: .from(timestamp));
                        }
                    } else {
                        DBChatMarkersStore.instance.syncCompleted(forAccount: room.account, with: room.jid);
                        _ = room.rejoin(fetchHistory: .initial);
                    }
                });
            }
        }).store(in: &cancellables);
        client.module(.muc).messagesPublisher.sink(receiveValue: { e in
            let room = e.room as! XMPPRoom;
            if let subject = e.message.subject {
                // how can we find room from here?
                room.subject = subject;
            }
            if let xUser = XMucUserElement.extract(from: e.message) {
                if xUser.statuses.contains(104) {
                    self.updateRoomName(room: room);
                    VCardManager.instance.refreshVCard(for: room.roomJid, on: room.account, completionHandler: nil);
                }
            }
            DBChatHistoryStore.instance.append(for: room, message: e.message, source: .stream);
        }).store(in: &cancellables);
        client.module(.muc).inivitationsPublisher.sink(receiveValue: { [weak client] invitation in
            guard let client = client, invitation.roomJid.localPart != nil else {
                return;
            }
                
            let mucModule = client.module(.muc);
            guard mucModule.roomManager.room(for: client, with: invitation.roomJid) == nil else {
                mucModule.decline(invitation: invitation, reason: nil);
                return;
            }
            InvitationManager.instance.addMucInvitation(for: client.userBareJid, roomJid: invitation.roomJid, invitation: invitation);
        }).store(in: &cancellables);
        client.module(.pepBookmarks).$currentBookmarks.drop(while: { it in !Settings.enableBookmarksSync }).sink(receiveValue: { [weak client] bookmarks in
            guard let client = client else {
                return;
            }
            let mucModule = client.module(.muc);
            bookmarks.items.compactMap({ $0 as? Bookmarks.Conference }).filter({ $0.autojoin }).filter { bookmark in
                return DBChatStore.instance.conversation(for: client.userBareJid, with: bookmark.jid.bareJid) == nil;
            }.forEach({ (bookmark) in
                guard let nick = bookmark.nick else {
                        return;
                    }
                    _ = mucModule.join(roomName: bookmark.jid.localPart!, mucServer: bookmark.jid.domain, nickname: nick, password: bookmark.password);
                });
        }).store(in: &cancellables);
    }
        
    static func showJoinError(_ err: XMPPError, for room: XMPPRoom) {
        guard let error = MucModule.RoomError.from(error: err), let context = room.context else {
            return;
        }
            
        let content = UNMutableNotificationContent();
        content.title = String.localizedStringWithFormat(NSLocalizedString("Room %@", comment: "alert title"), room.roomJid.stringValue);
        content.body = String.localizedStringWithFormat(NSLocalizedString("Could not join room. Reason:\n%@", comment: "alert body"), error.reason);
        content.sound = .default;
        if error != .banned && error != .registrationRequired {
            content.userInfo = ["account": context.userBareJid.stringValue, "roomJid": room.roomJid.stringValue, "nickname": room.nickname, "id": "room-join-error"];
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil);
        UNUserNotificationCenter.current().add(request) { (error) in
        }
        
        context.module(.muc).leave(room: room);
    }
            
    public func updateRoomName(room: XMPPRoom) {
        room.context?.module(.disco).getInfo(for: JID(room.jid), completionHandler: { result in
            switch result {
            case .success(let info):
                let newName = info.identities.first(where: { (identity) -> Bool in
                    return identity.category == "conference";
                })?.name?.trimmingCharacters(in: .whitespacesAndNewlines);
                
                room.updateRoom(name: newName);
            case .failure(_):
                break;
            }
        });
    }
}

class CustomMucModule: MucModule {
    
    override func join(room: RoomProtocol, fetchHistory: RoomHistoryFetch) -> Future<RoomJoinResult, XMPPError> {
        return Future({ promise in
            super.join(room: room, fetchHistory: fetchHistory).handle({ result in
                switch result {
                case .success(_):
                    MucEventHandler.instance.updateRoomName(room: room as! XMPPRoom);
                case .failure(_):
                    break;
                }
                promise(result);
            })
        });
    }
    
}

extension MucModule.RoomError {
    
    var reason: String {
        switch self {
        case .banned:
            return NSLocalizedString("User is banned", comment: "muc error reason");
        case .invalidPassword:
            return NSLocalizedString("Invalid password", comment: "muc error reason");
        case .maxUsersExceeded:
            return NSLocalizedString("Maximum number of users exceeded", comment: "muc error reason");
        case .nicknameConflict:
            return NSLocalizedString("Nickname already in use", comment: "muc error reason");
        case .nicknameLockedDown:
            return NSLocalizedString("Nickname is locked down", comment: "muc error reason");
        case .registrationRequired:
            return NSLocalizedString("Membership is required to access the room", comment: "muc error reason");
        case .roomLocked:
            return NSLocalizedString("Room is locked", comment: "muc error reason");
        }
    }
    
}
