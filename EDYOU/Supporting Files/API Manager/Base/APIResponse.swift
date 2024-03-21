//
//  ErrorModel.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation

// MARK: - ErrorResponse
struct ErrorResponse: Codable {
    let detail: [ErrorResponseDetail]
    
    
    var message: String {
        return detail.count > 0 ? (detail.first?.msg ?? "Invalid response") : "Unexpected error"
    }
    
    static var parsingFailed: ErrorResponse {
        let response = ErrorResponse(detail: [ErrorResponseDetail(msg: "Something went wrong", type: "", loc: [])])
        return response
    }
    static var emptyResponse: ErrorResponse {
        let response = ErrorResponse(detail: [ErrorResponseDetail(msg: "Empty response", type: "", loc: [])])
        return response
    }
    static var noInternet: ErrorResponse{
        let response = ErrorResponse(detail: [ErrorResponseDetail(msg: "No Internet Connection", type:  "", loc: [])])
        return response
    }
    
    
    
}

// MARK: - Detail
struct ErrorResponseDetail: Codable {
    let msg, type: String
    let loc: [String]
}


struct SuccessResponse<T: Codable>: Codable {
    var data: T
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
}

struct EmptySuccessResponse: Codable {
    var success: Bool?
    var detail: String?
    
    enum CodingKeys: String, CodingKey {
        case success, detail
    }
    
}

struct ChatSuccessResponse: Codable {
    var success: Bool?
    var detail: String?
    
    enum CodingKeys: String, CodingKey {
        case success, detail
    }
    
}
