//
//  WorkExperience.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class WorkExperience: Object, Codable {
    @objc dynamic  var companyID, companyImage, companyName, companyWebsite: String?
    @objc dynamic var companyIndustry, jobTitle, jobDescription, jobContractType: String?
    @objc dynamic var jobStart, jobEnd: String?
    @objc dynamic  var isPrimary: Bool = false
    @objc dynamic var companyLocation: String?
    
    @objc dynamic var completeDate: String {
        var joined : [String] = []
        let jobStart = self.jobStart?.toDate?.toYYYYMMDD() ?? ""
        if !jobStart.isEmpty {
            joined.append(jobStart)
        }
        let jobEnd = self.jobEnd?.toDate?.toYYYYMMDD() ?? ""
        if !jobEnd.isEmpty {
            joined.append(jobEnd)
        }
        return joined.count == 0 ? "--/--" : joined.joined(separator: " , ")
    }
    
    internal init(companyID: String? = nil, companyImage: String? = nil, companyName: String? = nil, companyWebsite: String? = nil, companyIndustry: String? = nil, jobTitle: String? = nil, jobDescription: String? = nil, jobContractType: String? = nil, jobStart: String? = nil, jobEnd: String? = nil, isPrimary: Bool? = nil, companyLocation: String? = nil) {
        self.companyID = companyID
        self.companyImage = companyImage
        self.companyName = companyName
        self.companyWebsite = companyWebsite
        self.companyIndustry = companyIndustry
        self.jobTitle = jobTitle
        self.jobDescription = jobDescription
        self.jobContractType = jobContractType
        self.jobStart = jobStart
        self.jobEnd = jobEnd
        self.isPrimary = isPrimary ?? false
        self.companyLocation = companyLocation
    }
    
    static var nilWorkExperince: WorkExperience {
        let e = WorkExperience(companyID: "", companyImage: "", companyName: "", companyWebsite: "", companyIndustry: "", jobTitle: "", jobDescription: "", jobContractType: "", jobStart: "", jobEnd: "", isPrimary: false, companyLocation: "")
        return e
    }
    
    override init() {
        super.init()
    }
    
    
    enum CodingKeys: String,CodingKey {
        case companyID = "company_id"
        case companyImage = "company_image"
        case companyName = "company_name"
        case companyWebsite = "company_website"
        case companyIndustry = "company_industry"
        case jobTitle = "job_title"
        case jobDescription = "job_description"
        case jobContractType = "job_contract_type"
        case jobStart   = "job_start"
        case jobEnd = "job_end"
        case isPrimary = "is_primary"
        case companyLocation = "company_location"
    }
}
