//
//  GroupMedia.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class GroupMedia: Codable {

    var images: [String]?
    var videos: [String]?
    var gifs: [String]?
    var documents: [String]?

    internal init(images: [String]? = nil, videos: [String]? = nil, gifs: [String]? = nil, documents: [String]? = nil) {
        self.images = images
        self.videos = videos
        self.gifs = gifs
        self.documents = documents
    }
    
    enum CodingKeys: String, CodingKey {
        case images, videos, gifs, documents
    }
    
}
