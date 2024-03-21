//
//  ProfileNetwork.swift
//  EDYOU
//
//  Created by Masroor Elahi on 04/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

typealias UpdateProfileCompletion = (ErrorResponse?) -> Void

class ProfileNetworkHelper {
    static var shared = ProfileNetworkHelper()
    private var completionBlock: ()
    func updateAbout(about: String, completion:@escaping UpdateProfileCompletion) {
        let parameters: [String: Any] = [
            "about": about]
        self.updateProfileRequest(params: parameters, completion: completion)
    }
    func updateEducation(education: Education, completion:@escaping UpdateProfileCompletion) {
        let educationDictionary = education.dictionary
        let parameters: [String: Any] = [
            "education": [ educationDictionary ] ]
        self.updateProfileRequest(params: parameters, completion: completion)
    }
    
    func deleteFromProfile(id: String, type: AboutSections, completion:@escaping UpdateProfileCompletion) {
        if type == .skills {
            APIManager.social.updateSkill(skill: id, isAdd: false, completion: completion)
        } else {
            guard let url = type.getURLWithId(id: id) else { return }
            APIManager.social.socialDeleteRequest(url: url, completion: completion)
        }
    }
    
    private func updateProfileRequest(params: [String:Any],completion:@escaping UpdateProfileCompletion) {
        APIManager.social.updateProfile(params) {[] user, error in
            completion(error)
        }
    }
}
