//
//  SocialManager+Reels.swift
//  EDYOU
//
//  Created by Masroor Elahi on 17/08/2022.
//

import Foundation

extension SocialManager {
    func getReelsData(skip: Int, limit: Int, completion: @escaping (_ reels: [Reels]?, _ error: ErrorResponse? , _ skip: Int) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let parameters: [String: Any] = [
                    "skip": skip,
                    "limit": limit
                ]
                let url = Routes.reels.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[Reels]>.self) { response, error in
                    completion(response?.data, error, skip)
                }
            } else {
                completion(nil, error, skip)
            }
        }
    }
    
    func likeDislikeVideo(videoId: String, like: Bool, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.reelsVideo.url(addPath: "/\(videoId)/like/\(like)")!
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
    
    func addReelsComment(videoId: String, commentId: String?, type: CommentType, tagFriends: [String] ,  message: String, completion: @escaping (_ result: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                var queryParameters: [String: Any] = [
                    "comment_type": type.rawValue,
                    
                ]
                if let id = commentId {
                    queryParameters["comment_id"] = id
                }
                let url = Routes.reelsVideo.url(addPath: "/\(videoId)/comment", parameters: queryParameters)!
                var params : [String:Any] = ["message" : message]
                if tagFriends.count > 0 {
                    params["tag_friends"] = tagFriends
                }
                var headers = APIManager.shared.header
//                headers["Content-Type"] = "application/x-www-form-urlencoded"
                self.manager.postRequest(url: url, header: headers, parameters: params, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                    completion(result?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func getReelsComments(videoId: String,completion: @escaping (_ comments: [Comment]?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.reelsVideo.url(addPath: "/\(videoId)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[Comment]>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getAllMusic(completion: @escaping (_ audios: [AudioInfo]?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.reelsAudio.url()!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<[AudioInfo]>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}
