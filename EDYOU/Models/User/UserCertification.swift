//
//  UserCertification.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class UserCertification: Object,Codable {
    @objc dynamic  var certificationID, certificationTitle, certificationDescription, certificationImage: String?
    @objc dynamic var issuingOrganization, issuingDate, expiryDate, credentialURL: String?
    
    internal init(certificationID: String? = nil, certificationTitle: String? = nil, certificationDescription: String? = nil, certificationImage: String? = nil, issuingOrganization: String? = nil, issuingDate: String? = nil, expiryDate: String? = nil, credentialURL: String? = nil) {
        self.certificationID = certificationID
        self.certificationTitle = certificationTitle
        self.certificationDescription = certificationDescription
        self.certificationImage = certificationImage
        self.issuingOrganization = issuingOrganization
        self.issuingDate = issuingDate
        self.expiryDate = expiryDate
        self.credentialURL = credentialURL
    }
    
    override init() {
        super.init()
    }
    
    
    static var nilCertificate : UserCertification {
        let c = UserCertification(certificationID: "", certificationTitle: "", certificationDescription: "", certificationImage: "", issuingOrganization: "", issuingDate: "", expiryDate: "", credentialURL: "")
        return c
    }
    
    enum CodingKeys: String,CodingKey {
        case certificationID = "certification_id"
        case certificationTitle = "certification_title"
        case certificationDescription = "certification_description"
        case certificationImage = "certification_image"
        case issuingOrganization = "issuing_organization"
        case issuingDate = "issuing_date"
        case expiryDate = "expiry_date"
        case credentialURL = "credential_url"
    }
}
