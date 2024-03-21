//
// InvitationsManager.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Combine
import Martin
import UserNotifications
import UIKit

class InvitationManager {
 
    static let instance = InvitationManager();
    
    func addPresenceSubscribe(for account: BareJID, from jid: JID) {
        guard let client = XmppService.instance.getClient(for: account) else {
            return;
        }
        let presenceModule = client.module(.presence);
        presenceModule.subscribed(by: JID(jid));
        presenceModule.subscribe(to: JID(jid));
    }
    
    func addMucInvitation(for account: BareJID, roomJid: BareJID, invitation: MucModule.Invitation) {
        let content = UNMutableNotificationContent();
        let x = invitation.message.findChild(name: "x", xmlns: "http://jabber.org/protocol/muc#user")
        let invite = x?.findChild(name: "invite");
        let reason = invite?.getChildren(name: "reason", xmlns: nil).first?.value
        content.body = reason ?? String.localizedStringWithFormat(NSLocalizedString("Invitation to groupchat %@", comment: "muc invitation notification"), roomJid.stringValue);
        if let from = invitation.inviter, let name = DBRosterStore.instance.item(for: account, jid: from.withoutResource)?.name {
            content.body = "\(content.body) from \(name)";
        }
        DBChatStore.instance.joinXMPGroup(roomJID: JID(roomJid), didFinish: {
            result in
            
        })
        content.threadIdentifier = "mucRoomInvitation=\(account.stringValue)|room=\(roomJid.stringValue)";
        content.categoryIdentifier = "MUC_ROOM_INVITATION";
        content.userInfo = ["account": account.stringValue, "roomJid": roomJid.stringValue, "password": invitation.password as Any];
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil), withCompletionHandler: nil);
    }
    
    func rejectPresenceSubscription(for account: BareJID, from jid: JID) {
        let threadId = "account=\(account.stringValue)|sender=\(jid.stringValue)";
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { notifications in
            let subscriptionReqNotifications = notifications.filter({ $0.request.content.categoryIdentifier == "SUBSCRIPTION_REQUEST" && $0.request.content.threadIdentifier == threadId });
            guard !subscriptionReqNotifications.isEmpty else {
                return;
            }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: subscriptionReqNotifications.map({ $0.request.identifier }));
            XmppService.instance.getClient(for: account)?.module(.presence).subscribed(by: jid);
        })
    }
}
