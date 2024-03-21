//
//  InviteOnly.swift
//  EDYOU
//
//  Created by imac3 on 20/04/2023.
//
import Foundation

struct InvitedUsers: Codable {
    
    var inviterUserId: String?
    var invitedUsers: [Invite]?
    var maximumLimit : Int?
    enum CodingKeys: String, CodingKey {
        case inviterUserId = "inviter_user_id"
        case invitedUsers = "invited_users"
        case maximumLimit = "max_invite_limit"
    }
}


class InvitedUserResponse: Codable {
    
   
    var sourceType: String?
    var address: String?
    var userID: String?
    var referralCode: String?
    var inviteStatus: String?
    


    internal init(sourceType: String? = nil, address: String? = nil, userID: String? = nil, referralCode: String? = nil, inviteStatus: String? = nil) {
        
        self.sourceType = sourceType
        self.address = address
        self.userID = userID
        self.referralCode = referralCode
        self.inviteStatus = inviteStatus
       
    }

    enum CodingKeys: String, CodingKey {
        case sourceType = "invite_source_type"
        case address = "invite_address"
        case userID = "user_id"
        case referralCode = "referral_code"
        case inviteStatus = "invite_status"
    }
}
