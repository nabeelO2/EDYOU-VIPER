//
//  Media_HX.swift
//  ustories
//
//  Created by imac3 on 27/06/2023.
//

import Foundation
import UIKit
import Photos

class MediaHX {
    
    let key: String
    let filename: String
    var data: Data?
    let mimeType: String
    var image : UIImage? = nil
    var videoURL : URL? = nil
    
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
    init(withData data: Data, key: String = "", mimeType: MimeTypeHX,thumbnailImage : UIImage? = nil,videoURL: URL? = nil) {
        self.key = key
        self.mimeType = mimeType.rawValue
        self.filename = mimeType == .image ? "image\(arc4random()).jpeg" : "video\(arc4random()).mp4"
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
        self.mimeType = MimeTypeHX.audio.rawValue
        self.filename = fileName
        self.data = data
    }
    func update(data: Data?) {
        self.data = data
    }
}

enum MimeTypeHX: String, CaseIterable {
    case image = "image/jpeg"
    case video = "video/mp4"
    case pdf = "application/pdf"
    case audio = "audio/m4a"
    
    static func create(ext: String) -> MimeTypeHX {
        for item in MimeTypeHX.allCases {
            if item.rawValue.contains("ext") {
                return item
            }
        }
        return .image
    }
}
