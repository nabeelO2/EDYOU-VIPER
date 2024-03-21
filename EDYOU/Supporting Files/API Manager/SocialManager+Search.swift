//
//  SocialManager+Search.swift
//  EDYOU
//
//  Created by Masroor Elahi on 06/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

// MARK: - Search
extension SocialManager {
    
    func search(query: String, searchType: SearchType,parameters:[String:Any], completion: @escaping (_ posts: SearchResults?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                let url = Routes.search.url(parameters)!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchResults>.self) { response, error in
                    let data = response?.data
                    data?.posts?.setIsReacted()
                    completion(data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func suggestion(type: SuggestionType, completion: @escaping (_ posts: SearchResults?, _ error: ErrorResponse?) -> Void) {
        APIManager.shared.refreshTokenIfRequired { error in
            if error == nil {
                
                let url = Routes.suggest.url(addPath: "?suggest_type=\(type.rawValue)")!
                self.manager.getRequest(url: url, header: APIManager.shared.header, resultType: SuccessResponse<SearchResults>.self) { response, error in
                    let data = response?.data
                    data?.posts?.setIsReacted()
                    completion(data, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}
