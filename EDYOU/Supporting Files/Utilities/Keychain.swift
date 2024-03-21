//
//  Keychain.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import KeychainSwift

final class Keychain {
    static let shared = Keychain()
    private let keychain = KeychainSwift()
    
    private struct Keys {
        static let oneTimeToken = "EDYOUOneTimeToken"
        static let accessToken = "EDYOUAccessToken"
        static let refreshToken = "EDYOURefreshToken"
        
        static let userId = "UserId"
    }
    
    private init() {}
    

    func clear() {
        oneTimeToken = nil
        accessToken = nil
        refreshToken = nil
        userId = nil
    }
    
    var userId: String? {
        set {
            if let value = newValue {
                keychain.set(value, forKey: Keys.userId)
            } else {
                keychain.delete(Keys.userId)
            }
        }
        get {
            return keychain.get(Keys.userId)
        }
    }
    var oneTimeToken: String? {
        set {
            if let value = newValue {
                keychain.set(value, forKey: Keys.oneTimeToken)
            } else {
                keychain.delete(Keys.oneTimeToken)
            }
        }
        get {
            return keychain.get(Keys.oneTimeToken)
        }
    }
    var accessToken: String? {
        set {
            if let value = newValue {
                keychain.set(value, forKey: Keys.accessToken)
            } else {
                keychain.delete(Keys.accessToken)
            }
        }
        get {
            return keychain.get(Keys.accessToken)
        }
    }
    var refreshToken: String? {
        set {
            if let value = newValue {
                keychain.set(value, forKey: Keys.refreshToken)
            } else {
                keychain.delete(Keys.refreshToken)
            }
        }
        get {
            return keychain.get(Keys.refreshToken)
        }
    }
    
    func reset() {
        
    }
    
}


