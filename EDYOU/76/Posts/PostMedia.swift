//
//  PostMedia.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

protocol MediaAsset {
    var url: String { get set }
    var type: MediaType { get set }
}

class PostMedia: MediaAsset {
    var url = ""
    var type = MediaType.image
    
    init(url: String, type: MediaType) {
        self.url = url
        self.type = type
    }
    static func from(urls: [String], type: MediaType) -> [PostMedia] {
        var medias = [PostMedia]()
        for url in urls {
            medias.append(PostMedia(url: url, type: type))
        }
        return medias
    }
}
