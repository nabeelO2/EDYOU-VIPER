//
//  Util.swift
//  EDYOU
//
//  Created by Masroor on 16/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

public class Document {
    var name: String
    var description: String
    var fileType: String
    var url: URL
//    var mimeType: String {
//        if fileType == "pdf" {
//            return "application/pdf"
//        } else if fileType == "doc" || fileType == "docx" {
//            return "application/msword"
//        }
//        else if fileType == "xls" {
//            return "application/vnd.ms-excel"
//        }
//        else if fileType == "xlsx" {
//            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
//        }
//        else {
//            return "text/plain"
//        }
//    }
    init(url: URL) {
        self.name = url.lastPathComponent
        self.fileType = url.lastPathComponent.components(separatedBy: ".")[1]
        self.url = url
        self.description = self.fileType.capitalized
        do {
            let resources = try url.resourceValues(forKeys:[.fileSizeKey])
            var result = Float(resources.fileSize!) / 100000
            result = result.rounded() / 10
            self.description += " . \(result)MB"
        } catch {
            print("Error: \(error)")
        }
            
    }
}

protocol DocumentViewOutputDelegate {
    func didRemoveFile(document: Document, view: DocumentView)
}

enum DocumentViewState: Int {
    case pending
    case uploading
    case uploaded
    
    static func create(percentage: Int) -> DocumentViewState {
        switch percentage {
        case 0:
            return .pending
        case 100:
            return .uploaded
        default:
            return .uploading
        }
    }
}
