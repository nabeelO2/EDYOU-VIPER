//
//  Auth.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import Foundation


// MARK: - OnetimeToken
struct OneTimeToken: Codable {
    let onetimeToken: String

    enum CodingKeys: String, CodingKey {
        case onetimeToken = "onetime_token"
    }
}

// MARK: - EmailVerificationResponse
struct GeneralResponse: Codable {
    let message, id: String?
}

// MARK: -
struct NotificationResponse: Codable {
    var statusCode: Int?
    var success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case success
    }
}

//{
//  "status_code": 0,
//  "success": true,
//  "detail": "string",
//  "data": {
//    "onetime_token": "string"
//  }
//}

// MARK: - AccessToken
struct AccessToken: Codable {
    let accessToken, tokenType, refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }
}

// MARK: - RefreshToken
struct RefreshToken: Codable {
    var accessToken, tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
