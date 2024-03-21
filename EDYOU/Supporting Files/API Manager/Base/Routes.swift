//
//  Routes.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation


enum Routes: String {
    
    // MARK: - Auth
    case institutes = "/auth/v1/signup/institutes"
    case states = "/auth/v1/states"
    case schools = "/auth/v1/schools"
    case signup = "/auth/v1/signup"
    case verify = "/auth/v1/signup/verify"
    case password = "/auth/v1/signup/password"
    case login = "/auth/v1/login"
    case changePassword = "/auth/v1/user/password"
    case deviceInfo = "/auth/v1/user/device_info"
    case forgotPassword = "/auth/v1/user/forgot_password"
    case forgotPasswordVerify = "/auth/v1/user/forgot_password/verify"
    case forgotPasswordChange = "/auth/v1/user/forgot_password/change"
    case refreshToken = "/auth/v1/refresh_token"
    case majorList = "/auth/v1/signup/major_list"
    case logout = "/auth/v1/logout"
    case graduateInfo = "/social/v1/profile/graduate_info"

    // MARK: - Searh
    case search = "/social/v1/search"
    case suggest = "/social/v1/suggest"
    
    // MARK: - Profile
    case me = "/social/v1/profile/me"
    case profile = "/social/v1/profile"
    case profiles = "/social/v1/profiles"
    case work = "/social/v1/profile/work"
    case education = "/social/v1/profile/education"
    case certifications = "/social/v1/profile/certifications"
    case skills = "/social/v1/profile/skills"
    case docs = "/social/v1/profile/docs"
    case hireMe = "/social/v1/profile/hire_me"
    case privateAccount = "/social/v1/profile/account/private"
    case messageMe = "/social/v1/profile/account/message"
    case callMe = "/social/v1/profile/account/call"
    case social = "/social/v1/profile/social"
    case deleteUser = "/auth/v1/user/delete"

    // MARK: - Friends
    case friends = "/social/v1/friends"
    case status = "/social/v1/friend/status"
    case friendRequest = "/social/v1/friend/request"
    case updateFriendRequest = "/social/v1/friend/request-status"
    case unfriend = "/social/v1/friend"
    
    // MARK: - Leader
    case leader = "/social/v1/leader"
    
    
    // MARK: - Posts
    case post = "/social/v1/post"
    case posts = "/social/v1/posts"
    case stories = "/social/v1/post/stories"
    
    // MARK: - Reels
    case reels = "/social/v1/reels"
    case reelsVideo = "/social/v1/reels/video"
    case reelsAudio = "/social/v1/reels/audios"

    
    // MARK: - Files Upload
    case coverPhoto = "/social/v1/profile/cover_photos"
    case profilePhoto = "/social/v1/profile/profile_photo"
    
    // MARK: - File Upload URL
    case fileUpload = "/file/v1/upload"
    
    // MARK: - Groups
    case group = "/social/v1/group"
    case groups = "/social/v1/groups"
    
    // MARK: - Favorite
    case favourites = "/social/v1/favourites"
    
    
    // MARK: - Events
    case event = "/social/v1/event"
    case events = "/social/v1/events"
    case eventsSocial = "/events/get_events_social_v1_events_get"
    
    // MARK: - Marketplace
    case marketplaceAd = "/social/v1/marketplace/ad"
    case marketplaceAds = "/social/v1/marketplace/ads"
    case marketplaceLikedAds = "/social/v1/marketplace/ads/me/liked"
    
    
    // MARK: - Calendar
    case calenderEvents = "/social/v1/calender/events"
    case calenderEvent = "/social/v1/calender/event"
    
    
    // MARK: - Chat
    case chatRoom = "/chat/v1/room"
    case chatRooms = "/chat/v1/rooms"
    case chatRoomCall = "/chat/v1/call"
    
    // MARK: - Notifications
    case notifications = "/social/v1/notifications"
    case notificationsSettings = "/social/v1/notifications/user/settings"
    
    // MARK: - Report
    case reportContent = "/social/v1/user/report"
    case profileSaveSettings = "/social/v1/profile/saved_settings"
    
    // MARK: - Others
    case blockedUser = "/social/v1/user/blocked"
    case unFollowUser = "/social/v1/user/unfollow"
    case support = "/apanel/v1/support"

    // MARK: - InviteOnly
    case inviteUser = "/social/v1/invite"
    

    
    func url(addPath path: String, parameters: [String: Any] = [:]) -> URL? {
        var queryParameters = ""
        for (key, value) in parameters {
            if queryParameters.isEmpty {
                queryParameters += "?\(key.trimmed)=\(value)".trimmed
            } else {
                queryParameters += "&\(key.trimmed)=\(value)".trimmed
            }
        }
        guard let urlString = (Constants.baseURL + self.rawValue + path + queryParameters).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlString)
    }
    func url(_ parameters: [String: Any] = [:]) -> URL? {
        var queryParameters = ""
        for (key, value) in parameters {
            if queryParameters.isEmpty {
                queryParameters += "?\(key.trimmed)=\(value)".trimmed
            } else {
                queryParameters += "&\(key.trimmed)=\(value)".trimmed
            }
        }
        guard let urlString = (Constants.baseURL + self.rawValue + queryParameters).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlString)
    }
    
    func url(_ path: String) -> URL? {
        guard let urlString = (Constants.baseURL + self.rawValue + "/" + path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlString)
    }
    
}
