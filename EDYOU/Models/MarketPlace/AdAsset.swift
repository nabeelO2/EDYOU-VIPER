//
//  AdAsset.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

class AdAssets: Codable {
    var images, videos, gifs, documents: [String]?
    internal init(images: [String]? = nil, videos: [String]? = nil, gifs: [String]? = nil, documents: [String]? = nil) {
        self.images = images
        self.videos = videos
        self.gifs = gifs
        self.documents = documents
    }
}
