//
// StreamFeaturesCache.swift
//
// EdYou
// Copyright (C) 2018 "O2Geeks." <admin@o2geeks.com>
//
 
//
import Foundation
import Martin

class StreamFeaturesCache: StreamFeaturesModuleWithPipeliningCacheProtocol {
    
    fileprivate static let CACHED_STREAM_FEATURES = "cachedStreamFeatures";
    
    fileprivate let fileManager: FileManager;
    fileprivate let path: String;
    
    public init(cacheDirectoryName: String = "stream-features-cache") {
        fileManager = FileManager.default;
        let url = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true);
        path = url.appendingPathComponent(cacheDirectoryName, isDirectory: true).path;
        createDirectory();
    }
        
    fileprivate func createDirectory() {
        guard !fileManager.fileExists(atPath: path) else {
            return;
        }
        
        try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil);
    }
    
    func getFeatures(for context: Context, embeddedStreamNo: Int) -> Element? {
        // TODO: Add caching if needed
//        if let cached: [Element] = sessionObject.getProperty(StreamFeaturesCache.CACHED_STREAM_FEATURES) {
//            if cached.count > embeddedStreamNo {
//                return cached[embeddedStreamNo];
//            } else {
//                return nil;
//            }
//        }
        
        guard embeddedStreamNo == 0 else {
            return nil;
        }
        
        let filePath = path + "/" + context.userBareJid.domain;
        guard fileManager.fileExists(atPath: filePath) else {
            return nil;
        }

        let fileUrl = URL(fileURLWithPath: filePath);
        
        guard let data = try? String(contentsOf: fileUrl, encoding: .utf8) else {
            return nil;
        }
        if let cached = Element.from(string: data)?.getChildren() {
//            sessionObject.setProperty(StreamFeaturesCache.CACHED_STREAM_FEATURES, value: cached);
            if cached.count > embeddedStreamNo {
                return cached[embeddedStreamNo];
            } else {
                return nil;
            }
        }
        return nil;
    }
    
    func set(for context: Context, features: [Element]?) {
        let filePath = path + "/" + context.userBareJid.domain;
        if features == nil {
            try? fileManager.removeItem(atPath: filePath);
        } else {
            try? Element(name: "cache", children: features!).stringValue.write(toFile: filePath, atomically: false, encoding: .utf8);
        }
    }
    
}

