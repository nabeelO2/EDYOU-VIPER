//
//  URL.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 14/03/2022.
//

import Foundation
import UniformTypeIdentifiers
import AVFoundation
import UIKit

extension NSURL {
    public func mimeType() -> String {
        if let pathExt = self.pathExtension,
            let mimeType = UTType(filenameExtension: pathExt)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
    
    var attributes: [FileAttributeKey : Any]? {
         do {
             return try FileManager.default.attributesOfItem(atPath: path)
         } catch let error as NSError {
             print("FileAttribute error: \(error)")
         }
         return nil
     }

     var fileSize: UInt64 {
         return attributes?[.size] as? UInt64 ?? UInt64(0)
     }

     var fileSizeString: String {
         return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
     }

     var creationDate: Date? {
         return attributes?[.creationDate] as? Date
     }
    
    
}

extension NSString {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}

extension String {
    public func mimeType() -> String {
        return (self as NSString).mimeType()
    }
}

extension URL {
    
    func getThumbnailImage() -> UIImage? {
        let asset: AVAsset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func getVideoDuration() -> Int {
        let asset = AVURLAsset(url: self)
        let durationInSeconds = asset.duration.seconds
        return Int(durationInSeconds)
    }
}

extension String {
    public func getDimenstions()->(Int,Int){
        let strDimenstion = self.components(separatedBy: "_").last
        let seprate = strDimenstion?.components(separatedBy: "x") ?? []
        let width = seprate.count > 0 ? seprate[0] : "0"
        let height = (seprate.count > 1 ? (seprate[1]).components(separatedBy: ".").first : "0") ?? "0"
//        let path = strDimenstion

        let cgW = Int(width) ?? 0
        let cgH = Int(height) ?? 0
        print("Dimenstion : \(cgW),\(cgH) url : \(self)")
        return (cgW,cgH)
    }
}
