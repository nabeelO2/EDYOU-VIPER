//
//  CacheManager.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 13/06/2022.
//

import Foundation

class CacheManager {
    
    static var shared = CacheManager()
    
    func write(data: Data?, fileName: String) {
        createFolder()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Cache/\(fileName)")
        do {
            try data?.write(to: path)
        } catch {
            print("[Cache Manager]: write \(error.localizedDescription)")
        }
    }
    
    func read(fileName: String) -> Data? {
        createFolder()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Cache/\(fileName)")
        
        do {
            let data = try Data(contentsOf: path)
            return data
        } catch {
            print("[Cache Manager]: read  \(error.localizedDescription)")
            return nil
        }
    }
    
    func createFolder() {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let DirPath = DocumentDirectory.appendingPathComponent("Cache")
        do {
            try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("[Cache Manager]: create folder  \(error.localizedDescription)")
        }
    }
    
}

