//
//  ChatMedia.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

 class ChatMedia: Object, MediaAsset {
   
     internal init(url: String = "", localUrl: String = "", type: MediaType = MediaType.image, fileName: String) {
        self.url = url
        self.localUrl = localUrl
        self.fileName = fileName
        self.type = type
    }
    
  
    
    @objc dynamic var url = ""
    @objc dynamic var fileName = ""
    @objc dynamic var localUrl = ""
    var type = MediaType.image
  
    
     override init() {
         super.init()
     }
  
    static func from(urls: [ChatAssetDetail], type: MediaType) -> [ChatMedia] {
        var medias = [ChatMedia]()
        for url in urls {
            medias.append(ChatMedia(url: url.url ?? "",localUrl: url.localUrl ?? "" , type: type, fileName: url.name ?? ""))
        }
        return medias
    }
}

