//
// AccountManagerScramSaltedPasswordCache.swift
//
// EdYou
// Copyright (C) 2018 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

open class AccountManagerScramSaltedPasswordCache: ScramSaltedPasswordCacheProtocol {
    
    public init() {
    }
    
    public func getSaltedPassword(for context: Context, id: String) -> [UInt8]? {
        guard let salted = AccountManager.getAccount(for: context.userBareJid)?.saltedPassword else {
            return nil;
        }
        return salted.id == id ? salted.value : nil;
    }
    
    public func store(for context: Context, id: String, saltedPassword: [UInt8]) {
        setSaltedPassword(AccountManager.SaltEntry(id: id, value: saltedPassword), for: context);
    }
    
    public func clearCache(for context: Context) {
        setSaltedPassword(nil, for: context)
    }
    
    fileprivate func setSaltedPassword(_ value: AccountManager.SaltEntry?, for context: Context) {
        guard var account = AccountManager.getAccount(for: context.userBareJid) else {
            return;
        }
        
        account.saltedPassword = value;
        try? AccountManager.save(account: account, reconnect: false);
    }
    
}
