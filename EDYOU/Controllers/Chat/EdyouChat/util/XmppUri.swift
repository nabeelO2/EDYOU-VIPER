//
//  XmppUri.swift
//  Edyou IM
//
//  Created by Suleman Ali on 09/01/2024.
//  Copyright © 2024 Tigase, Inc. All rights reserved.
//

import Foundation
import Martin
struct XmppUri {
    let jid: JID;
    let action: Action?;
    let dict: [String: String]?;

    init?(url: URL?) {
        guard url != nil else {
            return nil;
        }

        guard let components = URLComponents(url: url!, resolvingAgainstBaseURL: false) else {
            return nil;
        }

        guard components.host == nil else {
            return nil;
        }
        self.jid = JID(components.path);

        if var pairs = components.query?.split(separator: ";").map({ (it: Substring) -> [Substring] in it.split(separator: "=") }) {
            if let first = pairs.first, first.count == 1 {
                action = Action(rawValue: String(first.first!));
                pairs = Array(pairs.dropFirst());
            } else {
                action = nil;
            }
            var dict: [String: String] = [:];
            for pair in pairs {
                dict[String(pair[0])] = pair.count == 1 ? "" : String(pair[1]);
            }
            self.dict = dict;
        } else {
            self.action = nil;
            self.dict = nil;
        }
    }

    init(jid: JID, action: Action?, dict: [String:String]?) {
        self.jid = jid;
        self.action = action;
        self.dict = dict;
    }

    func toURL() -> URL? {
        var parts = URLComponents();
        parts.scheme = "xmpp";
        parts.path = jid.stringValue;
        if action != nil {
            parts.query = action!.rawValue + (dict?.map({ (k,v) -> String in ";\(k)=\(v)"}).joined() ?? "");
        } else {
            parts.query = dict?.map({ (k,v) -> String in ";\(k)=\(v)"}).joined();
        }
        return parts.url;
    }

    enum Action: String {
        case message
        case join
        case roster
        case register
    }
}
