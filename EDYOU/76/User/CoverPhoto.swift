//
//  CoverPhoto.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class CoverPhoto: Object,Codable {
    @objc dynamic   var coverPhotoID: String?
    @objc dynamic   var coverPhotoURL: String?
    @objc dynamic    var createdAt: String?
    @objc dynamic    var thumbnailURL: String?
    @objc dynamic   var updatedAt: String?
    @objc dynamic   var localImage: Data? = nil
    
    var coverImageURL: URL? {
        return URL(string: coverPhotoURL ?? "")
    }
    
    internal init(coverPhotoID: String? = nil, coverPhotoURL: String? = nil, createdAt: String? = nil, thumbnailURL: String? = nil, updatedAt: String? = nil, localImage: Data? = nil) {
        self.coverPhotoID = coverPhotoID
        self.coverPhotoURL = coverPhotoURL
        self.createdAt = createdAt
        self.thumbnailURL = thumbnailURL
        self.updatedAt = updatedAt
        self.localImage = localImage
    }
    
    
    override init() {
        super.init()
    }
    
    
    static var nilCoverPhoto: CoverPhoto {
        let c = CoverPhoto(coverPhotoID: "", coverPhotoURL: "", createdAt: "", thumbnailURL: "", updatedAt: "")
        return c
    }
    
    enum CodingKeys: String, CodingKey {
        
        case created_at = "created_at"
        case updated_at = "updated_at"
        case cover_photo_id = "cover_photo_id"
        case cover_photo_url = "cover_photo_url"
        case thumbnail_url = "thumbnail_url"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coverPhotoID = try values.decodeIfPresent(String.self, forKey: .cover_photo_id)
        coverPhotoURL = try values.decodeIfPresent(String.self, forKey: .cover_photo_url)
        createdAt = try values.decodeIfPresent(String.self, forKey: .created_at)
        thumbnailURL = try values.decodeIfPresent(String.self, forKey: .thumbnail_url)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coverPhotoID, forKey: .cover_photo_id)
        try container.encode(coverPhotoURL, forKey: .cover_photo_url)
        try container.encode(createdAt, forKey: .created_at)
        try container.encode(thumbnailURL, forKey: .thumbnail_url)
        try container.encode(updatedAt, forKey: .updated_at)
    }
}
