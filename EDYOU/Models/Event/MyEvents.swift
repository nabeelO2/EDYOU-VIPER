//
//  MyEvents.swift
//  EDYOU
//
//  Created by Aksa on 29/08/2022.
//

import Foundation
import SwiftyJSON

// MARK: - MyEvents
class MyEvents: Codable {
    var statusCode: Int?
    var success: Bool?
    var detail: String?
    var data: MyEventsDataModel?

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case success, detail, data
    }

    init(statusCode: Int?, success: Bool?, detail: String?, data: MyEventsDataModel?) {
        self.statusCode = statusCode
        self.success = success
        self.detail = detail
        self.data = data
    }
    
    class func build(_ json:JSON) -> MyEvents? {
        let myEvents =  MyEventsDataModel.build(json["data"]) 
    
           return MyEvents(
            statusCode: json["status_code"].intValue,
            success: json["success"].boolValue,
            detail: json["detail"].stringValue,
            data: myEvents)
      }
}
