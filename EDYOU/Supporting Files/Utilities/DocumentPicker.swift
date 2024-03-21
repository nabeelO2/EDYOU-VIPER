//
//  DocumentPicker.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 13/03/2022.
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
import UIKit

class DocumentPicker: NSObject {
    static let shared = DocumentPicker()
    
    var completion: ((_ fileUrl: URL) -> Void)?
    
    func open(from controller: UIViewController, completion: @escaping (_ fileUrl: URL) -> Void) {
        var type = [UTType.pdf, UTType.text, UTType.rtf, UTType.spreadsheet, UTType.zip]
        if let doc = UTType.doc {
            type.append(doc)
        }
        self.completion = completion
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: type)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        controller.present(documentPicker, animated: true, completion: nil)
        
    }
    
    func openPDF(from controller: UIViewController, completion: @escaping (_ fileUrl: URL) -> Void) {
        var type = [UTType.pdf]
        self.completion = completion
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: type)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        controller.present(documentPicker, animated: true, completion: nil)
        
    }
    
}

extension DocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            completion?(url)
        }
    }
}

extension UTType {
    static var doc:UTType? {
        return UTType("org.openxmlformats.wordprocessingml.document")
    }
}
