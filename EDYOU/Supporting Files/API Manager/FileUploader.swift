//
//  FileUploader.swift
//  EDYOU
//
//  Created by  Mac on 08/09/2021.
//

import UIKit

class FileUploader {
    
    private let manager = APIBaseManager()
    
    
    func uploadMedia(media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: FileUploadResponseNew?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.fileUpload.url()!
        manager.upload(url: url, requestType: .post, headers: APIManager.shared.header, parameters: [:], media: media, resultType: FileUploadResponseNew.self, progress: progress) { response, error in
            completion(response, error)
        }
    }
    
    func uploadProfileImage(media: Media, progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.profilePhoto.url()!
        
        var updatedParam : [String : Any] = [:]
        
            uploadMedia(media: [media], progress: progress) { user, error in

                let url = user?.results?.first?.url ?? ""
                
                
                updatedParam["profile_image"] = url
               upload(parameters: updatedParam)
                
            }


        
        func upload(parameters: [String: Any]){
            manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                completion(result?.data, error)
            }
        }
        
        
        
        
        
//        manager.upload(url: url, requestType: .put, headers: APIManager.shared.header, parameters: [:], media: [media], resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
//            completion(response?.data, error)
//        }
        
    }
    func uploadCoverImage(media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.coverPhoto.url()!
        
        
        var updatedParam : [String : Any] = [:]
        
        if media.count > 0 {//upload media first
            uploadMedia(media: media, progress: progress) { user, error in
//                print(user)
               
                var photoURLs = [String]()
                
                
                    user?.results?.forEach({ obj in
                        if let url = obj.url{
                            photoURLs.append(url)
                        }
                        
                    })
                    updatedParam["photos"] = photoURLs
                
                upload(parameters: updatedParam)
            }
        }
        
        
        func upload(parameters: [String: Any]){
            manager.putRequest(url: url, header: APIManager.shared.header, parameters: parameters, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                completion(result?.data, error)
            }
            
            
        }
        
        

        
//        manager.upload(url: url, requestType: .put, headers: APIManager.shared.header, parameters: [:], media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
//            completion(response?.data, error)
//        }
    }
    
    func createPost(parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        
        let url = Routes.post.url()!
        var updatedParam = parameters
        if media.count > 0 {//upload media first
            uploadMedia(media: media, progress: progress) { files, error in
//                print(user)
                var videoURLs = [String]()
                var photoURLs = [String]()
                
                files?.results?.forEach({ file in
                    let name = file.name ?? ""
                    if name.contains("thumbnail"){
                        
                    }
                    if name.contains("image"){
                        if let url = file.url{
                            photoURLs.append(url)
                        }
                    }
                    else if name.contains("video"){
                        if let url = file.url{
                            videoURLs.append(url)
                        }
                    }
                    
                })
                
                updatedParam["images"] = photoURLs
                updatedParam["videos"] = videoURLs
                upload(parameters: updatedParam)
                
//                if let type = media.first?.mimeType, type.contains("image") {//is Image
//                    user?.results?.forEach({ obj in
//                        if let url = obj.url{
//                            photoURLs.append(url)
//                        }
//
//                    })
//
//                }
//                else{
//                    user?.results?.forEach({ obj in
//                        if let url = obj.url{
//                            videoURLs.append(url)
//                        }
//
//                    })
//                    updatedParam["videos"] = videoURLs
//                }
                
                
                
//                upload(parameters: updatedParam)
            }


        }
        else{
            upload(parameters: updatedParam)
        }
        
        
        func upload(parameters: [String: Any]){
            manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                completion(result?.data, error)
            }
        }
        
        
        
    }

    func createReels(parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.reelsVideo.url()!
        
        manager.upload(url: url, requestType: .post, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
            completion(response?.data, error)
        }
        
    }
    
    func addCertificate(parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.certifications.url()!
        
        manager.upload(url: url, requestType: .put, headers: APIManager.shared.header, parameters: parameters, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
            completion(response?.data, error)
        }
        
    }
    func userSocialLinks(parameters: [[String: Any]], completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.social.url()!
        let data = try! JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
        manager.requestData(url: url, method: .put, header: APIManager.shared.header, parameters: data, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
            completion(result?.data, error)
        }
//        manager.upload(url: url, requestType: .post, headers: APIManager.shared.header, parameters: data, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
//        }
    }
    func addDocument(parameters: [String: Any], media: [Media], progress: ((_ progress: Float) -> Void)?, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        
        let url = Routes.docs.url()!
        var headers = APIManager.shared.header
        
        var updatedParam = parameters
        if media.count > 0 {//upload media first
            uploadMedia(media: media, progress: progress) { user, error in
//                print(user)
                let url = user?.results?.first?.url ?? ""
                
                
                updatedParam["document_url"] = url
               upload(parameters: updatedParam)
            }


        }
        else{
            upload(parameters: updatedParam)
        }
        
        
        func upload(parameters: [String: Any]){
            manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters,parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                completion(result?.data, error)
            }
        }
        
        
//        headers["Content-Type"] = "multipart/form-data"
//        manager.upload(url: url, requestType: .post, headers: headers, parameters: parameters, media: media, resultType: SuccessResponse<GeneralResponse>.self, progress: progress) { response, error in
//            completion(response?.data, error)
//        }
    }
    
    func deleteDocument(documentId: String, completion: @escaping (_ user: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        let url = Routes.docs.url(addPath: "/" + documentId)!
        let headers = APIManager.shared.header
        manager.deleteRequest(url: url, header: headers, parameters: [:], resultType: SuccessResponse<GeneralResponse>.self) { response, error in
            completion(response?.data, error)
        }
    }
}
