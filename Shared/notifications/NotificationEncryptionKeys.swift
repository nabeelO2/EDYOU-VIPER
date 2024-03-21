//
//  NotificationEncryptionKeys.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//

import Foundation
import Martin

public class NotificationEncryptionKeys {
    
    private static let storage = UserDefaults(suiteName: "group.edyou.notifications")!;
    
    public static func key(for account: BareJID) -> Data? {
        storage.data(forKey: account.stringValue)
    }
    
    public static func set(key: Data?, for account: BareJID) {
        storage.setValue(key, forKey: account.stringValue);
    }
}



