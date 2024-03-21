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
    var thumbnailURL = ""
    init(url: String, type: MediaType) {
        self.url = url
        self.type = type
    }
    init(url: String, type: MediaType, thumbnail : String) {
        self.url = url
        self.type = type
        self.thumbnailURL = thumbnail
    }
    static func from(urls: [String], type: MediaType) -> [PostMedia] {
        var medias = [PostMedia]()
        for url in urls {
            medias.append(PostMedia(url: url, type: type))
        }
        return medias
    }
    
    static func from(urls: [String]) -> [PostMedia] {
        
        var medias = [PostMedia]()
        let thumbnailUrl = urls.filter({$0.contains("_thumbnail")})
        
        for url in urls {
            if url.contains("thumbnail"){
                
            }
            else if url.contains("image"){
                //images
                medias.append(PostMedia(url: url, type: .image))
            }
            else{
                //video
                medias.append(PostMedia(url: url, type: .video))
            }
            
        }
        thumbnailUrl.forEach { url in
            if url.contains("thumbnail"){
                let id = getId(from: url)
                print(id)
                if let searchIndex = medias.firstIndex(where: { obj in
                    obj.url.contains(id)
                }){
                    medias[searchIndex].thumbnailURL = url
                }
                
            }
            
        }
        
        return medias
    }
    
    static func getId(from url : String)->String{
        
        let withoutEdyou = url.components(separatedBy: "_edyou_").last ?? ""
        //202816625.mp4
        //202816625_thumbnail_dimenstion_886x1920"
        if withoutEdyou.contains("_"){
            let id = withoutEdyou.components(separatedBy: "_").first ?? ""
            return id
            
        }else if withoutEdyou.contains("."){
            let id = withoutEdyou.components(separatedBy: ".").first ?? ""
            return id
        }
        else{
            return withoutEdyou
        }
    }
}
