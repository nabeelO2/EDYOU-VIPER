//
//  Marketplace.swift
//  EDYOU
//
//  Created by  Mac on 03/11/2021.
//

import Foundation

// MARK: - MarketProductAd
class MarketProductAd: Codable {
    
    var userID, country, countryCode: String?
    var latitude: Double?
    var locatedIn: String?
    var longitude: Double?
    var locationName, region, state, city: String?
    var street, zipCode, id, title: String?
    var category, description, price, currency: String?
    var placeName: String?
    var assets: AdAssets?
    var likes: [String]?
    var isActive: Bool?
    var user: User?
    var likesUser: [User]?

    internal init(userID: String? = nil, country: String? = nil, countryCode: String? = nil, latitude: Double? = nil, locatedIn: String? = nil, longitude: Double? = nil, locationName: String? = nil, region: String? = nil, state: String? = nil, city: String? = nil, street: String? = nil, zipCode: String? = nil, id: String? = nil, title: String? = nil, category: String? = nil, description: String? = nil, price: String? = nil, currency: String? = nil, placeName: String? = nil, assets: AdAssets? = nil, likes: [String]? = nil, isActive: Bool? = nil, user: User? = nil, likesUser: [User]? = nil) {
        self.userID = userID
        self.country = country
        self.countryCode = countryCode
        self.latitude = latitude
        self.locatedIn = locatedIn
        self.longitude = longitude
        self.locationName = locationName
        self.region = region
        self.state = state
        self.city = city
        self.street = street
        self.zipCode = zipCode
        self.id = id
        self.title = title
        self.category = category
        self.description = description
        self.price = price
        self.currency = currency
        self.placeName = placeName
        self.assets = assets
        self.likes = likes
        self.isActive = isActive
        self.user = user
        self.likesUser = likesUser
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case country
        case countryCode = "country_code"
        case latitude
        case locatedIn = "located_in"
        case longitude
        case locationName = "location_name"
        case region, state, city, street
        case zipCode = "zip_code"
        case id, title, category
        case description = "description"
        case price, currency
        case placeName = "place_name"
        case assets, likes
        case isActive = "is_active"
        case user
        case likesUser = "likes_user"
    }
}

// MARK: - Assets

