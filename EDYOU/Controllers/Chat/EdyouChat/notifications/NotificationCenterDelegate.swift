    //
    // NotificationCenterDelegate.swift
    //
    // EdYou
    // Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
    //

    //

import UIKit
import Shared
import Martin
import UserNotifications
import TigaseLogging

class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationCenterDelegate");

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        switch XMPPNotificationCategory.from(identifier: notification.request.content.categoryIdentifier) {
            case .MESSAGE:
                let account = notification.request.content.userInfo["account"] as? String;
                let sender = notification.request.content.userInfo["sender"] as? String;
                if (XMPPAppDelegateManager.shared.isChatVisible(account: account, with: sender) && XmppService.instance.applicationState == .active) {
                    completionHandler([.sound,.badge,.list,.banner]);
                } else {
                    completionHandler([.sound,.badge,.list,.banner]);
                }
            default:
                completionHandler([.sound,.badge,.list,.banner]);
        }
        completionHandler([.sound,.badge,.list,.banner]);
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content;

        switch XMPPNotificationCategory.from(identifier: response.notification.request.content.categoryIdentifier) {
            case .ERROR:
                didReceive(error: content, withCompletionHandler: completionHandler);
            case .SUBSCRIPTION_REQUEST:
                print("didRECEIVE")
                didReceiveWithOutNotification(subscriptionRequest: content, withCompletionHandler: completionHandler)
            case .MUC_ROOM_INVITATION:
                didReceive(mucInvitation: content, withCompletionHandler: completionHandler);
            case .MESSAGE:
                didReceive(messageResponse: response, withCompletionHandler: completionHandler);
            case .CALL:
                break
            case .UNSENT_MESSAGES:
                completionHandler();
            case .UNKNOWN:
                self.didTapPushNotification(userInfo: content.userInfo)
                self.logger.error("received unknown notification category: \( response.notification.request.content.categoryIdentifier)");
                completionHandler();
        }
    }

    private func didReceive(error content: UNNotificationContent, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = content.userInfo;
        if userInfo["cert-name"] != nil {
            let accountJid = BareJID(userInfo["account"] as! String);
            let alert = CertificateErrorAlert.create(domain: accountJid.domain, certName: userInfo["cert-name"] as! String, certHash: userInfo["cert-hash-sha1"] as! String, issuerName: userInfo["issuer-name"] as? String, issuerHash: userInfo["issuer-hash-sha1"] as? String, onAccept: {
                guard var account = AccountManager.getAccount(for: accountJid) else {
                    return;
                }
                let certInfo = account.serverCertificate;
                certInfo?.accepted = true;
                account.serverCertificate = certInfo;
                account.active = true;
                AccountSettings.lastError(for: accountJid, value: nil);
                do {
                    try AccountManager.save(account: account);
                } catch {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("It was not possible to save account details: %@ Please try again later.", comment: "alert title body"), error.localizedDescription), preferredStyle: .alert);
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button lable"), style: .cancel, handler: nil));
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil);
                }
            }, onDeny: nil);

            UIApplication.topViewController()?.present(alert, animated: true, completion: nil);
        }
        if let authError = userInfo["auth-error-type"] {
            let accountJid = BareJID(userInfo["account"] as! String);

            let alert = UIAlertController(title: NSLocalizedString("Authentication issue", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("Authentication for account %@ failed: %@\nVerify provided account password.", comment: "alert title body"), accountJid.stringValue, String(describing: authError)), preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .cancel, handler: nil));

            UIApplication.topViewController()?.present(alert, animated: true, completion: nil);
        } else {
            let alert = UIAlertController(title: content.title, message: content.body, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .cancel, handler: nil));

            UIApplication.topViewController()?.present(alert, animated: true, completion: nil);
        }
        completionHandler();
    }

    private func didReceiveWithOutNotification(subscriptionRequest content: UNNotificationContent, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = content.userInfo;
        let senderJid = BareJID(userInfo["sender"] as! String);
        let accountJid = BareJID(userInfo["account"] as! String);
        var senderName = userInfo["senderName"] as! String;
        guard let client = XmppService.instance.getClient(for: accountJid) else {
            return;
        }
        let presenceModule = client.module(.presence);
        presenceModule.subscribed(by: JID(senderJid));
        let subscription = DBRosterStore.instance.item(for: client.context, jid: JID(senderJid))?.subscription ?? .none;
        guard !subscription.isTo else {
            return;
        }
        presenceModule.subscribe(to: JID(senderJid));
        presenceModule.subscribed(by: JID(senderJid))
        completionHandler();
    }

    private func didReceive(subscriptionRequest content: UNNotificationContent, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = content.userInfo;
        let senderJid = BareJID(userInfo["sender"] as! String);
        let accountJid = BareJID(userInfo["account"] as! String);
        var senderName = userInfo["senderName"] as! String;
        if senderName != senderJid.stringValue {
            senderName = "\(senderName) (\(senderJid.stringValue))";
        }
        let alert = UIAlertController(title: NSLocalizedString("Subscription request", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("Received presence subscription request from\n%@\non account %@", comment: "alert title body"), senderName, accountJid.stringValue), preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: NSLocalizedString("Accept", comment: "button label"), style: .default, handler: {(action) in
            guard let client = XmppService.instance.getClient(for: accountJid) else {
                return;
            }
            let presenceModule = client.module(.presence);
            presenceModule.subscribed(by: JID(senderJid));
            let subscription = DBRosterStore.instance.item(for: client.context, jid: JID(senderJid))?.subscription ?? .none;
            guard !subscription.isTo else {
                return;
            }
            if Settings.autoSubscribeOnAcceptedSubscriptionRequest {
                presenceModule.subscribe(to: JID(senderJid));
            } else {
                let alert2 = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Subscribe to %@", comment: "alert title"), senderName), message: String.localizedStringWithFormat(NSLocalizedString("Do you wish to subscribe to \n%@\non account %@", comment: "alert body"), senderName, accountJid.stringValue), preferredStyle: .alert);
                alert2.addAction(UIAlertAction(title: NSLocalizedString("Accept", comment: "button label"), style: .default, handler: {(action) in
                    presenceModule.subscribe(to: JID(senderJid));
                }));
                alert2.addAction(UIAlertAction(title: NSLocalizedString("Reject", comment: "button label"), style: .destructive, handler: nil));

                UIApplication.topViewController()?.present(alert2, animated: true, completion: nil);
            }
        }));
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reject", comment: "button label"), style: .destructive, handler: {(action) in
            guard let client = XmppService.instance.getClient(for: accountJid) else {
                return;
            }
            client.module(.presence).unsubscribed(by: JID(senderJid));
        }));
        if let blockingCommandModule = XmppService.instance.getClient(for: accountJid)?.module(.blockingCommand), blockingCommandModule.isAvailable {
            guard let client = XmppService.instance.getClient(for: accountJid) else {
                return;
            }
            if blockingCommandModule.isReportingSupported {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Block and report", comment: "button label"), style: .destructive, handler: { action in
                    let alert2 = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Block and report", comment: "report user title"), senderJid.stringValue), message: String.localizedStringWithFormat(NSLocalizedString("The user %@ will be blocked. Should it be reported as well?", comment: "report user message"), senderJid.stringValue), preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: NSLocalizedString("Report spam", comment: "report spam action"), style: .default, handler: { _ in
                        client.module(.presence).unsubscribed(by: JID(senderJid))
                        blockingCommandModule.block(jid: JID(senderJid), report: .init(cause: .spam), completionHandler: { result in });
                    }))
                    alert2.addAction(UIAlertAction(title: NSLocalizedString("Report abuse", comment: "report abuse action"), style: .default, handler: { _ in
                        client.module(.presence).unsubscribed(by: JID(senderJid))
                        blockingCommandModule.block(jid: JID(senderJid), report: .init(cause: .abuse), completionHandler: { result in });
                    }))
                    alert2.addAction(UIAlertAction(title: NSLocalizedString("Just block", comment: "report spam action"), style: .default, handler: { _ in
                        client.module(.presence).unsubscribed(by: JID(senderJid))
                        blockingCommandModule.block(jid: JID(senderJid), completionHandler: { result in });
                    }))
                    UIApplication.topViewController()?.present(alert2, animated: true, completion: nil);
                }))
            } else {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Block", comment: "button label"), style: .destructive, handler: { action in
                    client.module(.presence).unsubscribed(by: JID(senderJid))
                    blockingCommandModule.block(jids: [JID(senderJid)], completionHandler: { result in });
                }));
            }
        }

        UIApplication.topViewController()?.present(alert, animated: true, completion: nil);
        completionHandler();
    }

    private func didReceive(mucInvitation content: UNNotificationContent, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let roomJid: BareJID = BareJID(content.userInfo["roomJid"] as? String) else {
            completionHandler()
            return;
        }
        openChatView(on:AccountManager.getAccounts().first!,with:roomJid,completionHandler: completionHandler)
    }

    private func didReceive(messageResponse response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo;
        DBChatStore.instance.refreshConversationsList()
        guard let accountJid = BareJID(userInfo["account"] as? String) else {
            completionHandler();
            return;
        }

        guard let senderJid = BareJID(userInfo["sender"] as? String) else {
            NotificationManager.instance.updateApplicationIconBadgeNumber(completionHandler: completionHandler);
            return;
        }

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            NotificationManager.instance.updateApplicationIconBadgeNumber(completionHandler: completionHandler);
        } else {
            openChatView(on: accountJid, with: senderJid, completionHandler: completionHandler);
        }
    }

    private func didTapPushNotification(userInfo: [AnyHashable : Any]) {
        let id = (userInfo as NSDictionary).string(for: "action_id")
        let action = NotificationType(rawValue: (userInfo as NSDictionary).string(for: "action_name"))
        let type = (userInfo as NSDictionary).string(for: "action_name")
        print("[Notification] action: \(action?.rawValue ?? "Nil") id: \(id)")
        if let action = action {
            switch action {
                case .chat:
                        //TODO: handle Chat Notification
                    break
                case .post,.comment,.reaction:
                    Application.shared.openPostDetails(postId: id, actionType: type)
                    break
                case .group:
                    Application.shared.openGroupDetails(groupId: id)
                    break
                case .group_Invite:
                    Application.shared.openGroupDetails(groupId: id, shouldCallInvite: true)
                    break
                case .profile:
                    Application.shared.openProfile(userId: id)
                    break
                case .event:
                    Application.shared.openEventDetails(eventId: id)
                    break
                case .message:
                    break
                case .friend:
                    Application.shared.openProfile(userId: id)
                    break
                case .story:
                    Application.shared.openPostDetails(postId: id, actionType: type)//show story
                    break
            }
        }
    }

    private func openChatView(on account: BareJID, with jid: BareJID, completionHandler: @escaping ()->Void) {
        if let topController = UIApplication.topViewController() {
            guard let conversation = DBChatStore.instance.conversation(for: account, with: jid), let controller = viewController(for: conversation) else {
                completionHandler();
                return;
            }
            if let baseChatViewController = controller as? BaseChatViewController {
                baseChatViewController.conversation = conversation;
            }

            controller.hidesBottomBarWhenPushed = true;

            if  let navController = topController.navigationController {
                navController.pushViewController(controller, animated: true);
            } else {
                let navController =  UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .fullScreen
                topController.present(navController, animated: true)
            }
        } else {
            self.logger.error("No top controller!");
        }
    }

    private func viewController(for item: Conversation) -> UIViewController? {
        switch item {
            case is XMPPRoom:
                return UIStoryboard(name: "Groupchat", bundle: nil).instantiateViewController(withIdentifier: "MucChatViewController");
            case is Chat:
                return UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
            case is Channel:
                return UIStoryboard(name: "MIX", bundle: nil).instantiateViewController(withIdentifier: "ChannelViewController")
            default:
                return nil;
        }
    }
}
