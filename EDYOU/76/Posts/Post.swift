//
//  Post.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import Foundation


// MARK: - Post
struct Post: Codable {
    var comments: [Comment]?
    var totalLikes: Int?
    var eventID, groupID: String?
    var userID, postID: String
    var reactions: [PostLike]?
    var profileImage, coverPhoto, profileThumbnail, instituteName: String?
    var name: Name?
    var postName: String?
    var isBackground: Bool?
    var withTags: [String]?
    var postType, privacy, postDeletionSettings: String?
    var tagFriends: [String]?
    var statusType, feelings, cityID, city: String?
    var country, countryCode: String?
    var latitude: Double?
    var locatedIn: String?
    var longitude: Double?
    var locationName, region, regionID, state: String?
    var street, zipCode, placeID, placeName: String?
    var overallRating: Double?
    var postAsset: PostAsset?
    var postActive: Bool?
    var status: String?
    var user: User?
//    var isReacted: Bool?
    var myReaction: PostLike?
    var backgroundColors, backgroundColorsPosition: String?
    var tagFriendsProfile: [User?]?
    var updatedAt: String?
    var createdAt: String?
    var mediaUrl: String?
    var mediaType : MediaType?
    var medias = [PostMedia]()
    var groupInfo: GroupInfo?
    var isFavourite: Bool?
    
    internal init(comments: [Comment]? = nil, totalLikes: Int? = nil, eventID: String? = nil, groupID: String? = nil, userID: String, postID: String, reactions: [PostLike]? = nil, profileImage: String? = nil, coverPhoto: String? = nil, profileThumbnail: String? = nil, instituteName: String? = nil, name: Name? = nil, postName: String? = nil, isBackground: Bool? = nil, withTags: [String]? = nil, postType: String? = nil, privacy: String? = nil, postDeletionSettings: String? = nil, tagFriends: [String]? = nil, statusType: String? = nil, feelings: String? = nil, cityID: String? = nil, city: String? = nil, country: String? = nil, countryCode: String? = nil, latitude: Double? = nil, locatedIn: String? = nil, longitude: Double? = nil, locationName: String? = nil, region: String? = nil, regionID: String? = nil, state: String? = nil, street: String? = nil, zipCode: String? = nil, placeID: String? = nil, placeName: String? = nil, overallRating: Double? = nil, postAsset: PostAsset? = nil, postActive: Bool? = nil, status: String? = nil, user: User? = nil, myReaction: PostLike? = nil, backgroundColors: String? = nil, backgroundColorsPosition: String? = nil, tagFriendsProfile: [User?]? = nil, updatedAt: String? = nil, createdAt: String? = nil, medias: [PostMedia] = [PostMedia](), groupInfo: GroupInfo? = nil, isFavourite: Bool? = nil) {
        self.comments = comments
        self.totalLikes = totalLikes
        self.eventID = eventID
        self.groupID = groupID
        self.userID = userID
        self.postID = postID
        self.reactions = reactions
        self.profileImage = profileImage
        self.coverPhoto = coverPhoto
        self.profileThumbnail = profileThumbnail
        self.instituteName = instituteName
        self.name = name
        self.postName = postName
        self.isBackground = isBackground
        self.withTags = withTags
        self.postType = postType
        self.privacy = privacy
        self.postDeletionSettings = postDeletionSettings
        self.tagFriends = tagFriends
        self.statusType = statusType
        self.feelings = feelings
        self.cityID = cityID
        self.city = city
        self.country = country
        self.countryCode = countryCode
        self.latitude = latitude
        self.locatedIn = locatedIn
        self.longitude = longitude
        self.locationName = locationName
        self.region = region
        self.regionID = regionID
        self.state = state
        self.street = street
        self.zipCode = zipCode
        self.placeID = placeID
        self.placeName = placeName
        self.overallRating = overallRating
        self.postAsset = postAsset
        self.postActive = postActive
        self.status = status
        self.user = user
        self.myReaction = myReaction
        self.backgroundColors = backgroundColors
        self.backgroundColorsPosition = backgroundColorsPosition
        self.tagFriendsProfile = tagFriendsProfile
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.medias = medias
        self.groupInfo = groupInfo
        self.isFavourite = isFavourite
    }

    enum CodingKeys: String, CodingKey {
        case comments
        case totalLikes = "total_likes"
        case userID = "user_id"
        case eventID = "event_id"
        case groupID = "group_id"
        case reactions = "post_likes"
        case profileImage = "profile_image"
        case coverPhoto = "cover_photo"
        case profileThumbnail = "profile_thumbnail"
        case instituteName = "institute_name"
        case name
        case postID = "post_id"
        case postName = "post_name"
        case isBackground = "is_background"
        case withTags = "with_tags"
        case postType = "post_type"
        case privacy
        case postDeletionSettings = "post_deletion_settings"
        case tagFriends = "tag_friends"
        case statusType = "status_type"
        case feelings
        case cityID = "city_id"
        case city, country
        case countryCode = "country_code"
        case latitude
        case locatedIn = "located_in"
        case longitude
        case locationName = "location_name"
        case region
        case regionID = "region_id"
        case state, street
        case zipCode = "zip_code"
        case placeID = "place_id"
        case placeName = "place_name"
        case overallRating = "overall_rating"
        case postAsset = "post_asset"
        case postActive = "post_active"
        case status, user
        case backgroundColors = "background_colors"
        case backgroundColorsPosition = "background_colors_position"
        case tagFriendsProfile = "tag_friends_profile"
//        case isReacted = "is_liked"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case groupInfo = "group_info"
        case isFavourite = "is_favourite"
        case myReaction = "my_reaction"
    }
}

// MARK: - Helper functions

extension Post {
    mutating func addReaction(_ reaction: String) {
        let react = PostLike(likeEmotion: reaction, userId: Cache.shared.user?.userID, user: Cache.shared.user)
        reactions?.append(react)
        myReaction = react
        totalLikes = totalLikes == nil ? 1 : totalLikes! + 1
    }
    mutating func removeReaction(_ reaction: String) {
        let myId = Cache.shared.user?.userID
        let index = reactions?.firstIndex(where: { $0.likeEmotion == reaction && ($0.user?.userID == myId || Cache.shared.user?.userID == myId) })
        if let index = index {
            reactions?.remove(at: index)
        }
        myReaction = nil
        totalLikes = (totalLikes ?? 0) > 0 ? totalLikes! - 1 : 0
    }
    
    var formattedText: String {
        var text = postName
        for u in (tagFriendsProfile ?? []) {
            if let user = u , let userId = user.userID {
                text = text?.replacingOccurrences(of: "id{\(userId)}", with: " @\(user.formattedUserName)").replacingOccurrences(of: "  @", with: " @").replacingOccurrences(of: "\n @", with: "\n@")
            }
            
        }
        return text ?? ""
    }
    var timeOfPost: String {
        if let d = updatedAt?.toDate {
            if d.stringValue(format: "dd-MM-yyyy", timeZone: .current) == Date().stringValue(format: "dd-MM-yyyy", timeZone: .current) {
                return d.stringValue(format: "hh:mm a", timeZone: .current)
            } else if d.stringValue(format: "yyyy", timeZone: .current) == Date().stringValue(format: "yyyy", timeZone: .current) {
                return d.stringValue(format: "MMM dd, hh:mm a", timeZone: .current)
            }
            return d.stringValue(format: "MMM dd yyyy, hh:mm a", timeZone: .current)
        }
        return ""
    }
}
