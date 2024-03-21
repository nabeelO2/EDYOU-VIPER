//
//  Database.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//

import Foundation
import TigaseSQLite3
import Martin

extension Database {
    
    public static func mainDatabaseUrl() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.edyou.shared")!.appendingPathComponent("edyou_main.db");
    }
    
}

extension JID: DatabaseConvertibleStringValue {
    
    public func encode() -> String {
        return self.stringValue;
    }
    
}

extension BareJID: DatabaseConvertibleStringValue {
    
    public func encode() -> String {
        return self.stringValue;
    }
    
}

extension Element: DatabaseConvertibleStringValue {
    public func encode() -> String {
        return self.stringValue;
    }
}

extension Cursor {
    
    public func jid(for column: String) -> JID? {
        return JID(string(for: column));
    }
    
    public func jid(at column: Int) -> JID? {
        return JID(string(at: column));
    }
    
    public subscript(index: Int) -> JID? {
        return JID(string(at: index));
    }
    
    public subscript(column: String) -> JID? {
        return JID(string(for: column));
    }
}

extension Cursor {
    
    public func bareJid(for column: String) -> BareJID? {
        return BareJID(string(for: column));
    }
    
    public func bareJid(at column: Int) -> BareJID? {
        return BareJID(string(at: column));
    }
    
    public subscript(index: Int) -> BareJID? {
        return BareJID(string(at: index));
    }
    
    public subscript(column: String) -> BareJID? {
        return BareJID(string(for: column));
    }
}

