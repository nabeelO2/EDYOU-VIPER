//
//  SocialLinks.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import RealmSwift

class SocialLink:  Object,Codable {
    @objc dynamic var socialID: String?
    @objc dynamic var socialNetworkName, socialNetworkURL: String?
    internal init(socialID: String, socialNetworkName: String, socialNetworkURL: String) {
        self.socialID = socialID
        self.socialNetworkName = socialNetworkName
        self.socialNetworkURL = socialNetworkURL
    }
    
    static var nilSocialLink: SocialLink {
        let s = SocialLink(socialID: "", socialNetworkName: "", socialNetworkURL: "")
        return s
    }
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String,CodingKey {
        case socialID = "social_id"
        case socialNetworkName = "social_network_name"
        case socialNetworkURL = "social_network_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        socialID = try container.decodeIfPresent(String.self, forKey: .socialID) ?? ""
        socialNetworkName = try container.decodeIfPresent(String.self, forKey: .socialNetworkName) ?? ""
        socialNetworkURL = try container.decodeIfPresent(String.self, forKey: .socialNetworkURL) ?? ""
    }
}
