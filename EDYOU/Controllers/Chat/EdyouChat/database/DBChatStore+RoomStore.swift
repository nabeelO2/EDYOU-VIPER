//
// DBChatStore+RoomStore.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import UIKit
extension DBChatStore: RoomStore {

    public typealias Room = XMPPRoom

    public func rooms(for context: Context) -> [Room] {
        return convert(items: self.conversations(for: context.userBareJid));
    }
    
    public func room(for context: Context, with jid: BareJID) -> Room? {
        return conversation(for: context.userBareJid, with: jid) as? Room;
    }
    
    public func createRoom(for context: Context, with jid: BareJID, nickname: String, password: String?) -> ConversationCreateResult<Room> {
        self.conversationsLifecycleQueue.sync {
            if let room = room(for: context, with: jid) {
                return .found(room);
            }
            
            let account = context.userBareJid;
            var name = "Unknow Group Name"
            if let opti = XMPPAppDelegateManager.shared.createdGroups[JID(jid)] {
                name = opti.name ?? "Unknow Group Name"
            }
            guard let room: Room = createConversation(for: account, with: jid, execute: {
                let timestamp = Date();
                let options = XMPPRoomOptions(nickname: nickname, password: password, name: name);
                let id = try! self.openConversation(account: account, jid: jid, type: .room, timestamp: timestamp, options: options);
                let room = Room(dispatcher: self.conversationDispatcher, context: context, jid: jid, id: id, timestamp: timestamp, lastActivity: lastActivity(for: account, jid: jid), unread: 0, options: options);
                self.updateOptionsWhileCreating(roomJID:JID(jid))
                return room;
            }) else {
                if let room = self.room(for: context, with: jid) {
                    return .found(room);
                }
                return .none;
            }
            return .created(room);
        }
    }
    
    public func close(room: Room) -> Bool {
        return close(conversation: room);
    }

   private func updateOptionsWhileCreating(roomJID:JID) {
        if let account = AccountManager.getActiveAccounts().first?.name ,let client = XmppService.instance.getClient(for: account) {
            client.module(.disco).getInfo(for: roomJID, completionHandler: { infoResult in
                switch infoResult {
                    case .success(let info):
                        XMPPAppDelegateManager.shared.createdGroups[roomJID]?.name = info.identities.first?.name
                        self.room(for: client.context, with: BareJID(roomJID.stringValue))?.updateRoom(name: info.identities.first?.name)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            })
        }
    }

    static func getRoomInfoFrom(jid:BareJID,isRoom:Bool) -> Conversation? {
        if let account =  AccountManager.getAccounts().first, let clint = XmppService.instance.getClient(for: account){
            if !isRoom {
                return DBChatStore.instance.chat(for: clint.context, with: jid)
            } else {
                return DBChatStore.instance.room(for: clint.context, with: jid)
            }
        }
        return nil
    }

    func createXMPGroup(groupID:String,roomName:String,description:String,groupMembers:[User], didFinish: @escaping ((Result<Conversation,XMPPError>)->Void)) {
        if let account = AccountManager.getActiveAccounts().first?.name ,let client = XmppService.instance.getClient(for: account) {
            let members = groupMembers.compactMap{JID("\($0.userID ?? "")@ejabberd.edyou.io")}
            let callGroup:((BareJID)->Void) = { groupJid in
                let mucModule = client.module(.muc);
                let form = JabberDataElement(type: .submit);
                form.addField(HiddenField(name: "FORM_TYPE")).value = "http://jabber.org/protocol/muc#roomconfig";
                form.addField(TextSingleField(name: "muc#roomconfig_roomname", value: roomName))
                form.addField(TextSingleField(name: "muc#roomconfig_whois", value: "anyone"))
                form.addField(BooleanField(name: "muc#roomconfig_membersonly", value: true))
                form.addField(BooleanField(name: "muc#roomconfig_publicroom", value: false))
                form.addField(BooleanField(name: "muc#roomconfig_persistentroom", value: true))
                form.addField(TextSingleField(name: "muc#roomconfig_roomdesc", value: description ?? ""))
                form.addField(BooleanField(name: "muc#roomconfig_allowinvites", value: true))
//                form.addField(TextSingleField(name: "muc#roomconfig_lang", value: "en"))
//                form.addField(BooleanField(name: "muc#roomconfig_enablelogging", value: true))
//                form.addField(BooleanField(name: "muc#roomconfig_passwordprotectedroom", value: false))
//                form.addField(BooleanField(name: "muc#roomconfig_moderatedroom", value: true))
//                form.addField(BooleanField(name: "muc#roomconfig_changesubject", value: true))
                let mucServer = groupJid.domain;
                mucModule.join(roomName: groupID, mucServer: mucServer, nickname: Cache.shared.user?.name?.completeName ?? roomName).handle({ [weak self] joinResult in
                    switch joinResult {
                        case .success(let r):
                            switch r {
                                case .created(let room), .joined(let room):

                                    client.module(.pepBookmarks).addOrUpdate(bookmark: Bookmarks.Conference(name: roomName, jid: JID(room.jid), autojoin: true, nick: Cache.shared.user?.name?.completeName ?? roomName, password: nil));

                                    var features = Set<XMPPRoom.Feature>();
                                    features.insert(.nonAnonymous);
                                    features.insert(.membersOnly);
                                    (room as! XMPPRoom).roomFeatures = features;
                                    (room as! XMPPRoom).update(features: (room as! XMPPRoom).features + [.omemo])
                                    (room as! XMPPRoom).updateOptions({ (options) in
                                        options.encryption = .omemo;
                                    }, completionHandler: nil);
                                    mucModule.setRoomSubject(roomJid: room.jid, newSubject: description);
                                    mucModule.setRoomConfiguration(roomJid: JID(BareJID(localPart: groupID, domain: mucServer)), configuration: form, completionHandler: { [weak self] configResult in
                                        switch configResult {
                                            case .success(_):
                                                members.forEach {
                                                    room.invite($0, reason: String.localizedStringWithFormat(NSLocalizedString("You are invied to join conversation at %@", comment: "error label"),roomName));
                                                }
                                                let aff  = groupMembers.map{ MucModule.RoomAffiliation(jid: JID("\($0.userID ?? "")@ejabberd.edyou.io"), affiliation: MucAffiliation.member,nickname: $0.name?.completeName ?? $0.formattedUserName, role:MucRole.participant)}
                                                mucModule.setRoomAffiliations(to: room, changedAffiliations: aff, completionHandler: { res in
                                                    switch res {
                                                        case .success(let ok):
                                                            print(ok)
                                                        case .failure(let error):
                                                            print(error.localizedDescription)
                                                    }
                                                })

                                                didFinish(.success(room as! XMPPRoom))
                                            case .failure(let error):
                                                mucModule.destroy(room: room)
                                                didFinish(.failure(error))
                                        }
                                    })
                            }
                        case .failure(let error):
                            didFinish(.failure(error))
                    }
                })
            };
            ChannelsHelper.findComponents(for: client, at: account.domain, completionHandler: { components in
                let barJid = BareJID(localPart:groupID,domain:components.first(where:{$0.type == .muc})!.jid.domain)
                XMPPAppDelegateManager.shared.createdGroups[JID(barJid)] = XMPPRoomOptions(nickname: roomName, password: nil, name: roomName)
                callGroup(barJid)
            })
        }
    }

    func joinXMPGroup(roomJID:JID, didFinish: @escaping ((Result<Conversation,XMPPError>)->Void)) {
        if let account = AccountManager.getActiveAccounts().first?.name ,let client = XmppService.instance.getClient(for: account) {
            client.module(.disco).getInfo(for: roomJID, completionHandler: { infoResult in
                switch infoResult {
                    case .success(let info):
                        let  roomName:String = info.identities.first!.name ?? roomJID.localPart ?? "Chat Group"
                        XMPPAppDelegateManager.shared.createdGroups[roomJID] = XMPPRoomOptions(nickname: Cache.shared.user?.name?.completeName ?? roomName, password: nil, name: roomName)
                        client.module(.muc).join(roomName: roomJID.localPart!, mucServer: roomJID.domain, nickname: Cache.shared.user?.name?.completeName ?? roomName, password: nil).handle({ result in
                            switch result {
                                case .success(let joinResult):
                                    var room:XMPPRoom!
                                    switch joinResult {
                                        case .created(let joined),.joined(let joined):
                                            room = joined as! XMPPRoom
                                    }
                                    room.roomFeatures =  Set(info.features.compactMap({ XMPPRoom.Feature(rawValue: $0) }));
                                    if !room.features.contains(.omemo){
                                        room.update(features:room.features + [ConversationFeature.omemo])
                                    }
                                    if room.options.encryption == nil || room.options.encryption == .none {
                                        room.updateOptions({opt in
                                            opt.encryption = .omemo
                                        })
                                    }
                                    client.module(.pepBookmarks).addOrUpdate(bookmark: Bookmarks.Conference(name: roomName.isEmpty ? room.jid.localPart : roomName, jid: JID(room.jid), autojoin: true, nick: Cache.shared.user?.name?.completeName ?? roomName, password: nil));
                                    room.registerForTigasePushNotification(true, completionHandler: { (result) in
                                        print("automatically enabled push for: \(room.jid), result: \(result)");
                                    })
                                    didFinish(.success(room as Conversation))
                                case .failure(let error):
                                    didFinish(.failure(error))
                                    print(error.localizedDescription)
                            }
                        });

                    case .failure(let error):
                        didFinish(.failure(error))
                }
            })
        }
    }

}
