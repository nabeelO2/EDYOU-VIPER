//
//  AuthManager.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import UIKit

class AuthManager {
    
    private let manager = APIBaseManager()
    
    func login(email: String, password: String, completion: @escaping (_ response: VerifyTokenResponse?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.login.url()!
        //isdev added
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "is_dev" : true
        ]
        
        manager.postRequest(url: url, header: [:], parameters: parameters, parameterType: .raw, resultType: VerifyTokenResponse.self) { response, error in
            if error == nil {
                Keychain.shared.accessToken = response?.accessToken
                Keychain.shared.refreshToken = response?.refreshToken
            }
            completion(response, error)
        }
    }
    func getInstitutes(completion: @escaping (_ institutions: [Institute], _ error: ErrorResponse?) -> Void) {
        let url = Routes.institutes.url()!
        manager.getRequest(url: url, header: [:], resultType: SuccessResponse<[Institute]>.self) { response, error in
            if (response?.data ?? []).count > 0 {
                Cache.shared.institutes = response?.data ?? []
            }
            completion(response?.data ?? [], error)
        }
    }
    
    func getStates(completion: @escaping (_ states: [String]?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.states.url()!
        manager.getRequest(url: url, header: [:], resultType: [String].self) { response, error in
            Cache.shared.states = response ?? []
            completion(response ?? [], error)
        }
    }
    
    func getSchools(state :String, completion: @escaping (_ states: [School]?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.schools.url(addPath: "?state=\(state)")!
        manager.getRequest(url: url, header: [:], resultType: [School].self) { response, error in
            completion(response ?? [], error)
        }
    }
    
    func getMajorSubjects(completion: @escaping (_ subjects: [String], _ error: ErrorResponse?) -> Void) {
        let url = Routes.majorList.url()!
        manager.getRequest(url: url, header: [:], resultType: SuccessResponse<[String]>.self) { response, error in
            completion(response?.data ?? [], error)
        }
    }
    func signup(parameters: [String: Any], completion: @escaping (_ token: OneTimeToken?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.signup.url()!
        manager.postRequest(url: url, header: [:], parameters: parameters, parameterType: .raw , resultType: SuccessResponse<OneTimeToken>.self) { response, error in
            if error == nil {
                Keychain.shared.oneTimeToken = response?.data.onetimeToken
            }
            completion(response?.data, error)
        }
    }
    func verify(code: String, completion: @escaping (_ response: VerifyTokenResponse?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.verify.url()!
        manager.postRequest(url: url, header: APIManager.shared.oneTimeTokenHeader, parameters: ["verification_code": code], parameterType: .raw,resultType: SuccessResponse<VerifyTokenResponse>.self) { response, error in
            if error == nil {
                Keychain.shared.accessToken = response?.data.accessToken
                Keychain.shared.refreshToken = response?.data.refreshToken
                UserDefaults.standard.set(true, forKey: "loggedIn")
            }
            completion(response?.data, error)
        }
    }
    func set(password: String, verificationCode: String, completion: @escaping (_ response: AccessToken?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.password.url()!
        let parameters: [String: Any] = [
            "verification_code": verificationCode,
            "new_password": password,
            "confirm_new_password": password
        ]
        manager.postRequest(url: url, header: APIManager.shared.oneTimeTokenHeader, parameters: parameters, resultType: SuccessResponse<AccessToken>.self) { response, error in
            if error == nil {
                Keychain.shared.accessToken = response?.data.accessToken
                Keychain.shared.refreshToken = response?.data.refreshToken
            }
            completion(response?.data, error)
        }
    }
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        let url = Routes.changePassword.url()!
        let parameters: [String: Any] = [
            "old_password": oldPassword,
            "new_password": newPassword,
            "confirm_new_password": newPassword
        ]
        var header = APIManager.shared.header
//        header["Content-Type"] = "application/x-www-form-urlencoded"
        
        manager.putRequest(url: url, header: header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
            completion(error)
        }
    }
    
    func register(pushToken token: String, voipToken: String?) {
        let url = Routes.deviceInfo.url()!
        var parameters: [String: Any]
        
        if voipToken?.count ?? 0 > 0
        {
            var deviceToken = ""
            if (UserDefaults.standard.string(forKey: "deviceToken") != nil)
            {
                deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
            }
            parameters = [
               
                "type": "ios",
                "device_name": UIDevice.current.model,
                "os_version": UIDevice.current.systemVersion,
                "device_model": UIDevice.current.model,
                "voip_token": voipToken ?? "",
                "device_token": deviceToken
            ]
        }
        else
        {
            
            parameters = [
                "device_token": token,
                "voip_token" : "",
                "type": "ios",
                "device_name": UIDevice.current.model,
                "os_version": UIDevice.current.systemVersion,
                "device_model": UIDevice.current.model,
               
            ]
        }
      
       
        manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: NotificationResponse.self) { response, error in
            if let error = error {
                print("[Notifications]: Register Token Error: \(error.message)")
            }
        }
    }
    func logout(completion: @escaping (_ response: EmptySuccessResponse?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.logout.url()!
        manager.getRequest(url: url, header: APIManager.shared.header, resultType: EmptySuccessResponse.self) { response, error in
            completion(response, error)
        }
    }
    
    
}

// MARK: - Forgot Password
extension AuthManager {
    
    func forgotPassword(email: String, completion: @escaping (_ token: OneTimeToken?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.forgotPassword.url()!
        manager.postRequest(url: url, header: [:], parameters: ["email": email],parameterType: .raw, resultType: SuccessResponse<OneTimeToken>.self) { response, error in
            if error == nil {
                Keychain.shared.oneTimeToken = response?.data.onetimeToken
            }
            completion(response?.data, error)
        }
    }
    func forgotPasswordVerify(code: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        let url = Routes.forgotPasswordVerify.url()!
        manager.postRequest(url: url, header: APIManager.shared.oneTimeTokenHeader, parameters: ["verification_code": code], parameterType: .raw, resultType: EmptySuccessResponse.self) { response, error in
            completion(error)
        }
    }
    func forgotPasswordChange(code: String, newPassword: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        let url = Routes.forgotPasswordChange.url()!
        manager.postRequest(url: url, header: APIManager.shared.oneTimeTokenHeader, parameters: ["verification_code": code, "new_password": newPassword],parameterType: .raw , resultType: EmptySuccessResponse.self) { response, error in
            completion(error)
        }
    }

    func saveGraduteInfo(parameters: [String: Any], completion: @escaping (_ response: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {

                let url = Routes.graduateInfo.url()!
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Forgot Password
extension AuthManager {
    func refreshToken(completion: @escaping (_ error: ErrorResponse?) -> Void) {
        let url = Routes.refreshToken.url()!
        manager.getRequest(url: url, header: APIManager.shared.refreshTokenHeader, resultType: RefreshToken.self) { (results, error) in
            if let accessToken = results?.accessToken {
                Keychain.shared.accessToken = accessToken
                if  let jid = AccountManager.getAccounts().first?.stringValue {
                    XMPPAppDelegateManager.shared.loginToExistingAccount(id: jid, pass: accessToken)
                } else if let id = Cache.shared.user?.userID  {
                    XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io", pass: accessToken)
                }
                APIManager.shared.loginRetryCount = 0
            }
            completion(error)
        }
        
    }
}

// MARK: - Support
extension AuthManager {

    func contactUS(parameters: [String: Any], completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.support.url()!

               
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<FriendRequestSent>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}
