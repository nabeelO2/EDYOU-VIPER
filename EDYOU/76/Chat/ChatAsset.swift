//
//  ChatAsset.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/22/22.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift


// MARK: - PostAsset
 class ChatAsset: Object, Codable {
   
     internal init(images: List<ChatAssetDetail>, audios:  List<ChatAssetDetail>, videos:  List<ChatAssetDetail>, gifs:  List<ChatAssetDetail>, documents:  List<ChatAssetDetail>) {
        self.images = images
        self.audios = audios
        self.videos = videos
        self.gifs = gifs
        self.documents = documents
    }
    
 
 
    
      var images: List<ChatAssetDetail> = List<ChatAssetDetail>()
     var audios: List<ChatAssetDetail> = List<ChatAssetDetail>()
     var videos: List<ChatAssetDetail> = List<ChatAssetDetail>()
     var gifs: List<ChatAssetDetail> = List<ChatAssetDetail>()
    var documents: List<ChatAssetDetail> = List<ChatAssetDetail>()
   
     override init() {
         super.init()
     }
     
}

class ChatAssetDetail : Object, Codable
{
    
    
    internal init(assetsID: String? = nil, name: String? = nil, url: String? = nil, localUrl: String? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.assetsID = assetsID
        self.name = name
        self.url = url
        self.localUrl = localUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
  
    
    
    @objc dynamic var assetsID : String?
    @objc dynamic  var name : String?
    @objc dynamic  var url : String?
    @objc dynamic  var localUrl : String?
    @objc dynamic var createdAt : String?
    @objc dynamic var updatedAt : String?
   
   
    override init() {
        super.init()
    }
    enum CodingKeys: String, CodingKey {
      
        case url = "asset_url"
        case name = "asset_name"
        case assetsID = "asset_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    override static func primaryKey() -> String? {
           return "name"
       }
   
    
}



extension KeyedDecodingContainer {
    // This will be called when any @Persisted List<> is decoded
    func decode<T: Decodable>(_ type: Persisted<List<T>>.Type, forKey key: Key) throws -> Persisted<List<T>> {
        // Use decode if present, falling back to an empty list
        try decodeIfPresent(type, forKey: key) ?? Persisted<List<T>>(wrappedValue: List<T>())
    }
}
