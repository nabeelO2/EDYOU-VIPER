//
//  Media.swift
//  Carzly
//
//  Created by Zuhair Hussain on 11/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import UIKit
import Photos

class Media : Codable {
    var key: String
    var filename: String
    var data: Data?
    var mimeType: String
    var image : UIImage? = nil
    var videoURL : URL? = nil
    
    // Implement required initializers for Codable
        enum CodingKeys: String, CodingKey {
            case key, filename, data, mimeType, image, videoURL
        }
    
    init?(withImage image: UIImage, key: String = "",mediaImage: UIImage? = nil) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "image\(arc4random()).jpeg"
        self.image = mediaImage
        
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        self.data = data
        
    }
    init(withAsset asset: PHAsset, key: String = "") {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "image\(arc4random()).jpeg"
        
        
        PHCachingImageManager().requestImageDataAndOrientation(for: asset, options: nil) { d, dateUTI, orientation, info in
            self.update(data: d)
        }
    }
    init(withData data: Data, key: String = "", mimeType: MimeType,thumbnailImage : UIImage? = nil,videoURL: URL? = nil, dimenstion : String = "") {
        self.key = key
        self.mimeType = mimeType.rawValue
        let random = arc4random()
        let randomStr = dimenstion.isEmpty ? "\(random)" : "\(random)_\(dimenstion)"
        self.filename = mimeType == .image ? "image\(randomStr).jpeg" : "video\(randomStr).mp4"
        self.data = data
        self.image = thumbnailImage
        
        self.videoURL = videoURL
    }
    init(withData data: Data, key: String = "", mimeType: MimeType,thumbnailImage : UIImage? = nil,videoURL: URL? = nil, dimenstion : String = "", withFileName : String = "") {
        self.key = key
        self.mimeType = mimeType.rawValue
        self.filename = withFileName
        self.data = data
        self.image = thumbnailImage
        self.videoURL = videoURL
    }

    init(withData data: Data, key: String = "", mimeType: String, ext: String) {
        self.key = key
        self.mimeType = "application/\(ext)"
        self.filename = "file\(arc4random()).\(ext)"
        self.data = data
    }
    init(withData data: Data, key: String = "", ext: String, fileName: String) {
        self.key = key
        self.mimeType = MimeType.audio.rawValue
        self.filename = fileName
        self.data = data
    }
    init() {
         key = ""
         filename = ""
         data = nil
         mimeType = ""
         image  = nil
         videoURL  = nil
    }
    func update(data: Data?) {
        self.data = data
    }
    
    // Implement required init(from:) initializer for decoding
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            key = try container.decode(String.self, forKey: .key)
            filename = try container.decode(String.self, forKey: .filename)
            data = try container.decode(Data.self, forKey: .data)
            mimeType = try container.decode(String.self, forKey: .mimeType)
            image = try container.decodeIfPresent(Data.self, forKey: .image).flatMap { UIImage(data: $0) }
            videoURL = try container.decodeIfPresent(URL.self, forKey: .videoURL)
        }

        // Implement encode(to:) method for encoding
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(key, forKey: .key)
            try container.encode(filename, forKey: .filename)
            try container.encode(data, forKey: .data)
            try container.encode(mimeType, forKey: .mimeType)
            try container.encodeIfPresent(image?.jpegData(compressionQuality: 0.6), forKey: .image)
            try container.encodeIfPresent(videoURL, forKey: .videoURL)
        }
}

enum MimeType: String, CaseIterable {
    case image = "image/jpeg"
    case video = "video/mp4"
    case pdf = "application/pdf"
    case audio = "audio/m4a"
    
    static func create(ext: String) -> MimeType {
        for item in MimeType.allCases {
            if item.rawValue.contains("ext") {
                return item
            }
        }
        return .image
    }
}

