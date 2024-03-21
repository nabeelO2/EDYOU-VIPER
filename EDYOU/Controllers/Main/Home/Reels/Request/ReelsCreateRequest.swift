//
//  ReelsCreateRequest.swift
//  EDYOU
//
//  Created by Masroor Elahi on 13/09/2022.
//

import Foundation

class ReelsCreateRequest: Codable {
    
    var title: String = ""
    var duration: Int = 0
    var privacy : String = ReelsPrivacy.public.serverValue
    var category: String?
    var location: String?
    var saveToGallery: Bool = false
    var allowComments: Bool = false
    
    internal init(title: String = "", duration: Int = 0, privacy: String = ReelsPrivacy.public.serverValue, location: String? = nil, saveToGallery: Bool = false, allowComments: Bool = false) {
        self.title = title
        self.duration = duration
        self.privacy = privacy
        self.location = location
        self.saveToGallery = saveToGallery
        self.allowComments = allowComments
    }
}
