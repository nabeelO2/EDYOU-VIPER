//
//  Education.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class Education: Object, Codable {
    @objc dynamic var instituteName, degreeName, major, degreeFieldName: String?
    @objc dynamic var degreeStart, degreeEnd: String?
    @objc dynamic var instituteLocation : String?
    @objc dynamic  var educationId: String?
    @objc dynamic var isCurrent: Bool = false
    @objc dynamic  var completeName: String {
       
        var joined: [String] = []
        if !(self.degreeName?.isEmpty ?? true) {
            joined.append(degreeName ?? "")
        }
        if !(self.major?.isEmpty ?? true) {
            joined.append(major ?? "")
        }
        return joined.joined(separator: ", ")
    }
    
    var completeDate: String {
        var joined : [String] = []
        if let startDate = self.degreeStart?.toDate?.stringValue(format: "yyyy") {
            joined.append(startDate)
        }
        if let endDate = self.degreeEnd?.toDate?.stringValue(format: "yyyy") {
            joined.append(endDate)
        }
        return joined.count == 0 ? "--/--" : joined.joined(separator: "-")
    }
    
    var endDateYear: String? {
        return self.degreeEnd?.toDate?.stringValue(format: "yyyy")
    }
    
    
    static var nilProperties: Education {
        return Education(instituteName: nil, degreeName: nil, major: nil, degreeFieldName: nil, degreeStart: nil, degreeEnd: nil, instituteLocation: nil, educationId: nil, isCurrent: nil)
    }
    
    internal init(instituteName: String? = nil, degreeName: String? = nil, major: String? = nil, degreeFieldName: String? = nil, degreeStart: String? = nil, degreeEnd: String? = nil, instituteLocation: String? = nil, educationId: String? = nil, isCurrent: Bool? = nil) {
        self.instituteName = instituteName
        self.degreeName = degreeName
        self.major = major
        self.degreeFieldName = degreeFieldName
        self.degreeStart = degreeStart
        self.degreeEnd = degreeEnd
        self.instituteLocation = instituteLocation
        self.educationId = educationId
        self.isCurrent = isCurrent ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case educationId = "education_id"
        case instituteName = "institute_name"
        case degreeName = "degree_name"
        case major
        case degreeFieldName = "degree_field_name"
        case degreeStart = "degree_start"
        case degreeEnd = "degree_end"
        case instituteLocation = "institute_location"
        case isCurrent = "is_current"
    }
    
    override init() {
        super.init()
    }
    
}
