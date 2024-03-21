//
//  ReportContent.swift
//  EDYOU
//
//  Created by Jamil Macbook on 30/12/22.
//

import Foundation
import UIKit

class ReportContentManager {
    private let manager = APIBaseManager()
}
    

extension ReportContentManager {

    func profileSaveSettings(contentID: String, contentKey: String ,completion: @escaping (_ error: ErrorResponse?) -> Void) {
        
        let parameters: [String: Any] = [
            "saved_settings": [contentKey: contentID]
        ]
        
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.profileSaveSettings.url()!
                let headers = APIManager.shared.header
               // headers["Content-Type"] = "application/x-www-form-urlencoded"
                self.manager.putRequest(url: url, header: headers, parameters: parameters,parameterType: .httpUrlEncode, resultType: SuccessResponse<GeneralResponse>.self) { result, error in
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
        
    }
    
    
    func reportContent(reportObject: ReportContent, completion: @escaping (_ response: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.reportContent.url()!
                
                let parameters: [String: Any] = [
                    "report_message": reportObject.reportMessage ?? "test",
                    "report_content_id": reportObject.contentID ?? "",
                    "report_content_type": reportObject.contentType ?? "",
                    "report_type": reportObject.reportType ?? ""
                ]
               
                
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func unfollowUser(userID: String, completion: @escaping (_ response: GeneralResponse?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.unFollowUser.url()!
                
                let parameters: [String: Any] = [
                    "user_id": userID
                ]
               
                
                self.manager.postRequest(url: url, header: APIManager.shared.header, parameters: parameters, parameterType: .raw, resultType: SuccessResponse<GeneralResponse>.self) { response, error in
                    completion(response?.data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }

}
