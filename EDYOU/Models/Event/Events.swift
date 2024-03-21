//
//  Eventd.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import SwiftyJSON

class Events: Codable {
    var statusCode: Int?
    var success: Bool?
    var detail: String?
    var data: [EventBasic]?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case success, detail, data
    }
    
    init(statusCode: Int?, success: Bool?, detail: String?, data: [EventBasic]?) {
        self.statusCode = statusCode
        self.success = success
        self.detail = detail
        self.data = data
    }
    
    
    class func build(json:JSON) -> Events? {
        let eventBasics = json["data"].array?.map { return EventBasic.build($0) }
    
           return Events(
            statusCode: json["status_code"].intValue,
            success: json["success"].boolValue,
            detail: json["detail"].stringValue,
            data: eventBasics)
      }
    
}
