//
//  ChatAssets.swift
//  EDYOU
//
//  Created by KamalNasir-Eddress on 22/12/2022.
//

import Foundation
import RealmSwift

// MARK: - ChatAssets
 class ChatAssets: Object,Codable {
    internal init(images: List<String>? = nil, videos: List<String>? = nil, audios: List<String>? = nil, documents: List<String>? = nil, gifs: List<String>? = nil) {
        self.images = images ?? List<String>()
        self.videos = videos ?? List<String>()
        self.audios = audios ?? List<String>()
        self.documents = documents ?? List<String>()
        self.gifs = gifs ?? List<String>()
    }
    
     @Persisted dynamic var images = List<String>()
     @Persisted dynamic var videos = List<String>()
     @Persisted dynamic var audios = List<String>()
     @Persisted dynamic var documents = List<String>()
     @Persisted dynamic var gifs = List<String>()
    
     override init() {
         super.init()
     }
    
    enum CodingKeys: String, CodingKey {
        case images, videos, audios, documents, gifs
    }
}


