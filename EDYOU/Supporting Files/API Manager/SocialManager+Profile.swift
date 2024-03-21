//
//  SocialManager+Profile.swift
//  EDYOU
//
//  Created by Masroor Elahi on 06/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import Martin

// MARK: - Profile Get
extension SocialManager {
    func getUserInfo(userId: String? = nil, completion: @escaping (_ user: User?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var url = Routes.me.url()!
                var clientID = ""
                if let id = userId {
                    clientID = id
                    url = Routes.profile.url(addPath: "?user_id=\(id)")!
                } else if let id = Cache.shared.user?.userID, id.count > 0 {
                    clientID = id
                    url = Routes.profile.url(addPath: "?user_id=\(id)")!
                }
                XMPPAppDelegateManager.shared.updatePassword(clientID)
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<User>.self) { response, error in
                    if let user = response?.data, userId == nil {
                        Cache.shared.user = user
                    }
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getProfileMedia(userId: String, completion: @escaping (_ user: GroupMedia?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.profile.url(addPath: "/gallery?user_id=\(userId)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<GroupMedia>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
  
}

// MARK: - Profile - Add / Update Certificates, Experience
extension SocialManager {
    
    /// This Will Send Request to Add and Update Certificate, Experience and Education
    /// - Parameters:
    ///   - url: URL to Certificate, Expericene and Education
    ///   - paramter: paramters
    ///   - id: id to append for put
    ///   - completion: Completion Response
    func addUpdateUserProfile(url: URL,paramter: [String:Any], id: String?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        var url = url
        var method = HTTPMethod.post
        if let id = id , !id.isEmpty {
            url.appendPathComponent(id)
            method = .put
        }
        self.updateUserProfile(url: url, params: paramter, method: method, completion: completion)
    }
    
    func addUpdateEducation(url: URL,paramter: [String:Any], id: String?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        var url = url
        var method = HTTPMethod.post
        if let id = id , !id.isEmpty {
            url.appendPathComponent(id)
            method = .put
        }
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                if method == .post {
                    self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: paramter, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, err in
                        
                        completion(response?.data, error
                        )
                    }
                } else {
                    self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: paramter, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, err in
                        completion(response?.data, error)
                    }
                }
                
            } else {
                completion(nil,error)
            }
        }
    }
    
    private func updateUserProfile(url: URL, params: [String:Any], method: HTTPMethod, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: params,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
//                self.manager.upload(url: url, requestType: method, headers: APIManager.shared.header, parameters: params, media: [], resultType: SuccessResponse<GeneralResponse>.self, progress: nil) { response, error in
//                    completion(response?.data, error)
//                }

            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Profile - Update
extension SocialManager {
    
    func updateHireMe(status: Bool, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.hireMe.url(addPath: "/\(status)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func updatePrivateAccount(status: Bool, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.privateAccount.url(addPath: "/\(status)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func updateMessageMe(status: Bool, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.messageMe.url(addPath: "/\(status)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func updateCallMe(status: Bool, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.callMe.url(addPath: "/\(status)")!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: [:], parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func updateProfile(_ parameters: [String: Any], completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.profile.url()!
                self.manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

// MARK: - Profile - Delete
extension SocialManager {
  
    func deleteUserAccount(url: URL, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func socialDeleteRequest(url: URL, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func deleteSocialLink(socialId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.social.url(addPath: "/\(socialId)")!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func updateSkill(skill: String, isAdd: Bool,completion: @escaping (_ error: ErrorResponse?) -> Void) {
        let parameters: [String: Any] = [
            "skill": skill,
            "is_add": isAdd
        ]
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.skills.url()!
                var headers = APIManager.shared.header
//                headers["Content-Type"] = "application/x-www-form-urlencoded"
                self.manager.putRequest(url: url, header: headers, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}

// MARK: - Delete Cover Photos
extension SocialManager {
    
    func deleteCoverPhoto(coverId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.coverPhoto.url(coverId)!
                self.manager.deleteRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}
