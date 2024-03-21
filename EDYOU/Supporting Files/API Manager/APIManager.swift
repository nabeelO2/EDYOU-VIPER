//
//  APIManager.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import JWTDecode

final class APIManager {
    
    static let shared = APIManager()
    static let auth = AuthManager()
    static let social = SocialManager()
    static let fileUploader = FileUploader()
    static let reportContentManager = ReportContentManager()

    static let loginRetryLimit = 3
    
    
    private init() {}
    
    var loginRetryCount = 0
    
    var isTokenExpired: Bool {
        if let token = Keychain.shared.accessToken {
            let jwt = try! decode(jwt: token)
            return jwt.expired
        }
        return true
    }
    
    var header:  [String: String] {
        if let token = Keychain.shared.accessToken {
            let str = "Bearer " + token
            return ["Authorization": str]
        }
        return ["Content-Type":"application/json"]
    }
    
    var oneTimeTokenHeader:  [String: String] {
        if let token = Keychain.shared.oneTimeToken {
            let str = "Bearer " + token
            return ["Authorization": str]
        }
        return ["Content-Type":"application/json"]
    }
    
    var refreshTokenHeader:  [String: String] {
        if let token = Keychain.shared.refreshToken {
            let str = "Bearer " + token
            return ["Authorization": str]
        }
        return ["Content-Type":"application/json"]
    }
    
    
    func refreshTokenIfRequired(completion: @escaping (_ error: ErrorResponse?) -> Void) {
        if isTokenExpired {
            APIManager.auth.refreshToken { (error) in
                completion(error)
            }
        } else {
            completion(nil)
        }
    }
    
}
