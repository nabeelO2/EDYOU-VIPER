//
//  NotificationsManagerHelper.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//


import Foundation
import Martin
import UserNotifications
import os
import Intents
import UIKit

public struct ConversationNotificationDetails {
    public let name: String;
    public let notifications: ConversationNotification;
    public let type: ConversationType;
    public let nick: String?;
    
    public init(name: String, notifications: ConversationNotification, type: ConversationType, nick: String?) {
        self.name = name;
        self.notifications = notifications;
        self.type = type;
        self.nick = nick;
    }
}

public class NotificationsManagerHelper {
    
    public static func unreadChatsThreadIds(completionHandler: @escaping (Set<String>)->Void) {
        unreadThreadIds(for: [.MESSAGE], completionHandler: completionHandler);
    }
    
    public static func unreadThreadIds(for categories: [XMPPNotificationCategory], completionHandler: @escaping (Set<String>)->Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            let unreadChats = Set(notifications.filter({(notification) in
                let category = XMPPNotificationCategory.from(identifier: notification.request.content.categoryIdentifier);
                return categories.contains(category);
            }).map({ (notification) in
                return notification.request.content.threadIdentifier;
            }));
            
            completionHandler(unreadChats);
        }
    }
    
    public static func generateMessageUID(account: BareJID, sender: BareJID?, body: String?) -> String? {
        if let sender = sender, let body = body {
            return Digest.sha256.digest(toHex: "\(account)|\(sender)|\(body)".data(using: .utf8));
        }
        return nil;
    }
        
    public static func prepareNewMessageNotification(content: UNMutableNotificationContent, account: BareJID, sender jid: BareJID?, nickname: String?, body msg: String?, provider: NotificationManagerProvider, completionHandler: @escaping (UNNotificationContent)->Void) {
        let timestamp = Date();
        content.sound = .default;
        content.categoryIdentifier = XMPPNotificationCategory.MESSAGE.rawValue;
        if let sender = jid, let body = msg {
            let uid = generateMessageUID(account: account, sender: sender, body: body)!;
            content.threadIdentifier = "account=\(account.stringValue)|sender=\(sender.stringValue)";
            provider.conversationNotificationDetails(for: account, with: sender, completionHandler: { details in
                os_log("%{public}@", log: OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "EdyouPush"), "Found: name: \(details.name), type: \(String(describing: details.type.rawValue))");

                var senderId: String = sender.stringValue;
                var group: INSpeakableString?;
                switch details.type {
                case .chat:
                    content.title = details.name + " send a message";
                    if body.starts(with: "/me ") {
                        content.body = String(body.dropFirst(4));
                    } else {
                        content.body = body;
                    }
                case .channel, .room:
                    content.title = details.name
                    group = INSpeakableString(spokenPhrase: details.name);
                    if body.starts(with: "/me ") {
                        if let nickname = nickname {
                            content.body = "\(nickname) \(body.dropFirst(4))";
                        } else {
                            content.body = String(body.dropFirst(4));
                        }
                    } else {
                        content.body = body;
                        if let nickname = nickname {
                            content.subtitle = nickname;
                            senderId = sender.with(resource: nickname).stringValue;
                        }
                    }
                }
                
                content.userInfo = ["account": account.stringValue, "sender": sender.stringValue, "uid": uid, "timestamp": timestamp];
                provider.countBadge(withThreadId: content.threadIdentifier, completionHandler: { count in
                    content.badge = count as NSNumber;
                    if #available(iOS 15.0, *) {
                        do {
                            let recipient = INPerson(personHandle: INPersonHandle(value: account.stringValue, type: .unknown), nameComponents: nil, displayName: nil, image: nil, contactIdentifier: nil, customIdentifier: nil, isMe: true, suggestionType: .none);
                            let avatar = provider.avatar(on: account, for: sender);
                            let sender = INPerson(personHandle: INPersonHandle(value: senderId, type: .unknown), nameComponents: nil, displayName: group == nil ? details.name : nickname, image: avatar, contactIdentifier: nil, customIdentifier: senderId, isMe: false, suggestionType: .instantMessageAddress);
                            let intent = INSendMessageIntent(recipients: group == nil ? [recipient] : [recipient, sender], outgoingMessageType: .outgoingMessageText, content: nil, speakableGroupName: group, conversationIdentifier: content.threadIdentifier, serviceName: "Edyou IM", sender: sender, attachments: nil);
                            if details.type == .chat {
                                intent.setImage(avatar, forParameterNamed: \.sender);
                            } else {
                                intent.setImage(avatar, forParameterNamed: \.speakableGroupName);
                            }
                            let interaction = INInteraction(intent: intent, response: nil);
                            interaction.direction = .incoming;
                            interaction.donate(completion: nil);
                            completionHandler(try content.updating(from: intent));
                        } catch {
                            // some error happened
                            completionHandler(content);
                        }
                    } else {
                        completionHandler(content);
                    }
                });
            })
        } else {
            content.threadIdentifier = "account=\(account.stringValue)";
            content.body = NSLocalizedString("New message!", comment: "new message without content notification");
            provider.countBadge(withThreadId: content.threadIdentifier, completionHandler: { count in
                content.badge = count as NSNumber;
                completionHandler(content);
            });
        }
    }
}

public protocol NotificationManagerProvider {
    
    func conversationNotificationDetails(for account: BareJID, with jid: BareJID, completionHandler: @escaping (ConversationNotificationDetails)->Void);
 
    func countBadge(withThreadId: String?, completionHandler: @escaping (Int)->Void);
    
    func shouldShowNotification(account: BareJID, sender: BareJID?, body: String?, completionHandler: @escaping (Bool)->Void);
    
    func avatar(on account: BareJID, for sender: BareJID) -> INImage?;
    
}

public class Payload: Decodable {
    public var unread: Int;
    public var sender: JID;
    public var type: Kind;
    public var nickname: String?;
    public var message: String?;
    public var sid: String?;
    public var media: [String]?;
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        unread = try container.decode(Int.self, forKey: .unread);
        sender = try container.decode(JID.self, forKey: .sender);
        type = Kind(rawValue: (try container.decodeIfPresent(String.self, forKey: .type)) ?? Kind.unknown.rawValue)!;
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname);
        message = try container.decodeIfPresent(String.self, forKey: .message);
        sid = try container.decodeIfPresent(String.self, forKey: .sid)
        media = try container.decodeIfPresent([String].self, forKey: .media);
        // -- and so on...
    }
    
    public enum Kind: String {
        case unknown
        case groupchat
        case chat
        case call
    }
    
    public enum CodingKeys: String, CodingKey {
        case unread
        case sender
        case type
        case nickname
        case message
        case sid
        case media
    }
}
