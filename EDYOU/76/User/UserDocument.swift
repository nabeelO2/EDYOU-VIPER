//
//  UserDocument.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - UserDocument
class UserDocument: Object, Codable {
   
    @objc dynamic var documentID, documentTitle, documentDescription, documentURL: String?
   
    internal init(documentID: String, documentTitle: String, documentDescription: String, documentURL: String) {
        self.documentID = documentID
        self.documentTitle = documentTitle
        self.documentDescription = documentDescription
        self.documentURL = documentURL
    }
    
    override init() {
        super.init()
    }
    
    
    enum CodingKeys: String,CodingKey{
        case documentID =  "document_id"
        case documentTitle = "document_title"
        case documentDescription = "document_description"
        case documentURL = "document_url"
    }
}
