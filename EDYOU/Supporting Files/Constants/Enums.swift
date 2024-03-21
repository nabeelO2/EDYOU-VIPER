//
//  Enums.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import UIKit

enum ValidationStatus {
    case success, failure
}


enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

enum MediaType {
    case image, video, audio, text, all
}

enum UserProfileSections: Int, CaseIterable {
    case profile
    case listing
    var cells : Int {
        switch self {
        case .profile:
            return 1
        case .listing:
            return 0
        }
    }
}

enum JobType: String,CaseIterable{
    case fulltime = "FullTime"
    case parttime = "PartTime"
    case hybrid = "MiniJob"
    case temporary = "Temporary"
    case other  = "Other"
    var description:String {
        switch self{
        case .fulltime: return "Full Time"
        case .parttime: return "Part Time"
        case .hybrid: return "Mini Job"
        case .temporary: return "Temporary"
        case .other: return "Other"
        }
    }
}

enum ProfilePhotosType:Int, CaseIterable{
    case all
    case photos
    case videos
    case albums
    case reels
    
    var type : String{
        switch self {
        case .all:
            return "all"
        case .photos:
            return "photos"
        case .videos:
            return "videos"
        case .albums:
            return "albums"
        case .reels:
            return "reels"
            
        }
    }
}

enum ProfileDetailType: Int , CaseIterable {
    case post = 0
    case about
    case events
    case groups
    case photos
    
    var type : String{
        switch self {
        case .post: return "post"
        case .about: return "about"
        case .events: return "events"
        case .groups: return "groups"
        case .photos: return "photos"
        }
    }
    var selectedImage: UIImage {
        switch self {
        case .post:
            return R.image.feed_select()!
        case .about:
            return R.image.profile_select()!
        case .events:
            return R.image.event_select()!
        case .groups:
            return R.image.group_select()!
        case .photos:
            return R.image.photo_select()!
        }
    }
    var unselectedImage: UIImage {
        switch self {
        case .post:
            return R.image.feed_unselect()!
        case .about:
            return R.image.profile_unselect()!
        case .events:
            return R.image.event_unselect()!
        case .groups:
            return R.image.group_unselect()!
        case .photos:
            return R.image.photo_unselect()!
        }
    }
}

enum SocialLinkNetwork: String, CaseIterable {
    case instagram = "Instagram"
    case facebook = "Facebook"
    case twitter = "Twitter"
    case linkedin = "Linkedin"
    case dribble = "TikTok"
    case youtube = "YouTube"
    case website = "Website"
    case customLink = "CustomLink"
    
    init?(tag: Int) {
        switch tag {
        case 2001:
            self = .instagram
        case 2002:
            self = .facebook
        case 2003:
            self = .twitter
        case 2004:
            self = .linkedin
        case 2005:
            self = .dribble
        case 2006:
            self = .youtube
        case 2007:
            self = .website
        case 2008:
            self = .customLink
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .instagram:
            return "Instagram"
        case .facebook:
            return "Facebook"
        case .twitter:
            return "Twitter"
        case .linkedin:
            return "Linkedin"
        case .dribble:
            return "TikTok"
        case .youtube:
            return "YouTube"
        case .website:
            return "Website"
        case .customLink:
            return "CustomLink"
        }
    }
    var icon: UIImage? {
        switch self {
        case .instagram:
            return R.image.insta()
        case .facebook:
            return R.image.facebook()
        case .twitter:
            return   R.image.twitter()
        case .linkedin:
            return R.image.linkedin()
        case .dribble:
            return R.image.tiktok()
        case .youtube:
            return UIImage(named: "youtube")
        case .website:
            return R.image.sharelink()
        case .customLink:
            return  R.image.sharelink()
        }
    }
    var link: String? {
        switch self {
        case .instagram:
            return "https://www.instagram.com/"
        case .facebook:
            return "https://www.facebook.com/"
        case .twitter:
            return "https://twitter.com/"
        case .linkedin:
            return "https://www.linkedin.com/in/"
        case .dribble:
            return "https://tiktok.com/"
        case .youtube:
            return "https://youtube.com/"
        case .website:
            return ""
        case .customLink:
            return ""
        }
    }
    var tags : Int {
        switch self {
        case .instagram:
            return 2001
        case .facebook:
            return 2002
        case .twitter:
            return 2003
        case .linkedin:
            return 2004
        case .dribble:
            return 2005
        case .youtube:
            return 2006
        case .website:
            return 2007
        case .customLink:
            return 2008
        }
    }
}
enum EditProfileTableViewType: String{
    case profilePhoto = "profilePhoto"
    case socialLinks = "socailLinks"
    
    var name : String{
        switch self {
        case .profilePhoto:
            return "profilePhoto"
        case .socialLinks:
            return "socialLinks"
        }
    }
}
enum ProfileImageType: Int,CaseIterable{
    case displayPhoto = 0
    case coverPhoto
}

enum AboutSections : Int, CaseIterable {
    case about = 1
    case experiences
    case education
    case certificates
    case skills
    case documents
    
    func getCells(user: User , isEditMode: Bool) -> Int {
        switch self {
        case .about:
            return user.about.asStringOrEmpty().isEmpty ? 0 : 1
        case .experiences:
            return user.workExperiences.count 
        case .education:
            return user.education.count 
        case .certificates:
            return user.userCertifications.count 
        case .skills:
            if user.skills.count == 0 {
                return 0
            }
            return isEditMode ? (user.skills.count ) : 1
        case .documents:
            return user.userDocuments.count 
        }
    }
    
    var cells: Int {
        switch self {
        default:
            return 0
        }
    }
    var descrption: String {
        return String(describing: self).capitalized
    }
    
    func getURLWithId(id: String) -> URL?{
        switch self {
        case .about:
            return nil
        case .experiences:
            return Routes.work.url(id)
        case .education:
            return Routes.education.url(id)
        case .certificates:
            return Routes.certifications.url(id)
        case .skills:
            return nil
        case .documents:
            return Routes.docs.url(id)
        }
    }
    
    func getController(data: Any?) -> UIViewController {
        switch self {
        case .about:
            return EditProfileAbout(user: data as! User)
        case .experiences:
            return ExperienceController(userExperience: data == nil ? WorkExperience.nilWorkExperince : data as! WorkExperience )
        case .education:
            return EducationController(userEducation: data == nil ? Education.nilProperties : data as! Education)
        case .certificates:
            return CertificateController(userCertificate: data == nil ? UserCertification.nilCertificate : data as! UserCertification)
        case .skills:
            return SkillController(skill: data == nil ? "" : data as! String)
        case .documents:
            return DocumentController()
        }
    }
    
    static func getAboutController(user: User) -> EditProfileAbout {
        return EditProfileAbout(user: user)
    }
    
    static func getExperienceController( experience: WorkExperience?) -> ExperienceController {
        return ExperienceController(userExperience: experience == nil ? WorkExperience.nilWorkExperince : experience!)
    }
    static func getEducation(education: Education?) -> EducationController {
        return EducationController(userEducation: education == nil ? Education.nilProperties : education!)
    }
    static func getCertificates(certifcates: UserCertification?) -> CertificateController {
        return CertificateController(userCertificate: certifcates == nil ? UserCertification.nilCertificate : certifcates!)
    }
}

enum PostType: String {
    case personal = "personal"
    case groups = "groups"
    case event = "events"
    case trending = "trending"
    case school = "school"
    case favourites = "favourites"
    case friends = "friends"
    case `public` = "public"
    case all = "all"
    case leaderboard = "leaderboard"
    
    var name: String {
        switch self {
        case .personal:
            return "Personal"
        case .groups:
            return "Groups"
        case .event:
            return "Event"
        case .trending:
            return "Trending"
        case .favourites:
            return "Favorites"
        case .friends:
            return "Friends"
        case .public:
            return "Public"
        case .school:
            return "School"
        case .all:
            return "All"
        case .leaderboard:
            return "LeaderBoard"
        }
    }
    
    
    
    var image: UIImage? {
        switch self {
        case .personal:
            return nil
        case .groups:
            return R.image.home_group_icon()
        case .event:
            return nil
        case .trending:
            return R.image.home_fire_icon()
        case .favourites:
            return R.image.home_favourite_icon()
        case .friends:
            return R.image.home_friends_icon()
        case .public:
            return R.image.home_friends_icon()
        case .school:
            return R.image.home_friends_icon()
        case .all:
            return nil
        case .leaderboard:
            return R.image.home_friends_icon()
        }
        
    }
    
    
}

enum FriendShipStatus: String, Codable {
    case unknown = "unknown"
    case none = "none"
    case approved = "approved"
    case pending = "pending"
}
enum FriendRequestOrigin: String, Codable {
    case sent = "sent"
    case received = "received"
}

enum ParameterType {
    case raw, httpUrlEncode
}

enum FriendRequestStatus: String {
    case approved = "approved"
    case pending = "pending"
    case rejected = "rejected"
    case cancel = "cancel"
    
}
enum CommentType: String {
    case parent = "parent"
    case child = "child"
}

enum PostSettings: String {
    case oneDay = "a_day"
    case sevenDays = "seven_days"
    case thirtyDays = "thirty_days"
    case sixtyDays = "sixty_days"
    case never = "never"
    case saveToMyPhone = "save_to_my_phone"
    
    var name: String {
        switch self {
            
        case .oneDay:
            return "24 hours"
        case .sevenDays:
            return "7 days"
        case .thirtyDays:
            return "30 days"
        case .sixtyDays:
            return "60 days"
        case .never:
            return "Never"
        case .saveToMyPhone:
            return "Save to my phone"
        }
    }
    
    
    var description: String {
        switch self {
            
        case .oneDay:
            return "24 hrs post delete"
        case .sevenDays:
            return "7 days post delete"
        case .thirtyDays:
            return "30 days post delete"
        case .sixtyDays:
            return "60 days post delete"
        case .never:
            return "never delete post"
        case .saveToMyPhone:
            return "Save to my phone"
        }
    }
    var valueInDays: Int {
        switch self {
        case .oneDay:           return 1
        case .sevenDays:        return 7
        case .thirtyDays:       return 30
        case .sixtyDays:        return 60
        case .never:            return 0
        case .saveToMyPhone:    return 0
        }
    }
    var valueInHrs: Int {
        switch self {
        case .oneDay:           return 1 * 24
        case .sevenDays:        return 7 * 24
        case .thirtyDays:       return 30 * 24
        case .sixtyDays:        return 60 * 24
        case .never:            return 0
        case .saveToMyPhone:    return 0
        }
    }
    static func from(days: Int) -> PostSettings {
        switch days {
        case 0:   return PostSettings.never
        case 1:   return PostSettings.oneDay
        case 7:   return PostSettings.sevenDays
        case 30:   return PostSettings.thirtyDays
        case 60:   return PostSettings.sixtyDays
        default:   return PostSettings.never
        }
    }
    static func from(hrs: Int) -> PostSettings {
        switch hrs {
        case 0:              return PostSettings.never
        case 24:             return PostSettings.oneDay
        case (7 * 24):       return PostSettings.sevenDays
        case (30 * 24):      return PostSettings.thirtyDays
        case (60 * 24):      return PostSettings.sixtyDays
        default:             return PostSettings.never
        }
    }
    
}


enum PostPrivacy: String {
    case friends = "friends"
    case `public` = "public"
    case mySchoolOnly = "my_school_only"
    case groups = "groups"
    case roommate = "roommate"
    case closeFriends = "close_friends"
    case friendsExcept = "friends_except"
    case specificFriends = "specific_friends"
    
    var name: String {
        switch self {
        case .friends:
            return "Friends"
        case .public:
            return "Public"
        case .mySchoolOnly:
            return "My School Only"
        case .groups:
            return "Groups"
        case .roommate:
            return "Roomate"
        case .closeFriends:
            return "Close Friends"
        case .friendsExcept:
            return "Friends Except"
        case .specificFriends:
            return "Specific Friends"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .friends:
            return UIImage(named: "post_friends_Icon")
        case .public:
            return UIImage(named: "post_public_Icon")
        case .mySchoolOnly:
            return UIImage(named: "post_school_only_Icon")
        case .groups:
            return UIImage(named: "post_group_Icon")
        case .roommate:
            return R.image.school_icon()
        case .closeFriends:
            return UIImage(named: "post_close_friends_Icon")
        case .friendsExcept:
            return UIImage(named: "post_friends_Icon")
        case .specificFriends:
            return UIImage(named: "post_friends_Icon")
        }
    }
}

enum SearchType: String {
    case posts = "posts"
    case people = "people"
    case groups = "groups"
    case events = "events"
    case friends = "friends"
    case friendRequests = "friendRequests"
    case friendsSort = "friendsSort"
//    case trending = "trending"
    
    
    static func with(index: Int) -> SearchType {
        if index == 0 {
            return .posts
        } else if index == 1 {
            return .people
        } else if index == 2 {
            return .groups
        } else if index == 3 {
            return .events
        }
//        else if index == 7 {
//            return .trending
//        }

        return .friends
    }
}




enum GroupAdminAction: String {
    case acceptMemberRequest = "accept_member_request"
    case rejectMemberRequest = "reject_member_request"
    case addGroupAdmin = "add_group_admin"
    case removeGroupAdmin = "remove_group_admin"
    case removeGroupPost = "remove_group_post"
    case acceptGroupPost = "accept_group_post"
    case removeGroupMember = "remove_group_member"
    case deleteGroup = "delete_group"
    case blockMember = "block_member"
    case unblockMember = "unblock_member"
}

enum FavoriteType: String {
    case groups = "groups"
    case events = "events"
    case friends = "friends"
    case posts = "posts"
    case users = "users"
}

enum GroupJoinedStatus: String {
    case joined = "joined"
    case pending = "pending"
    case notJoined = "not_joined"
}

enum GroupFriendsType {
    case joined, notJoined, pending, invited
}



enum GroupUserAction: String {
    case edit = "edit"
    case join = "join"
    case cancel_join = "cancel_join"
    case leave = "leave"
    case invite = "invite"
    case accept_invite = "accept_invite"
    case reject_invite = "reject_invite"
}
enum GroupMemberStatus : String {
    case waiting_for_admin_approval = "waiting_for_admin_approval"
    case waiting_for_my_approval = "waiting_for_my_approval"
    case joined_via_invite = "joined_via_invite"
    case joined_by_me = "joined_by_me"
    case rejected_by_admin = "rejected_by_admin"
    case defaultState = "defaultState"
}

enum EventType: String {
    case online = "online"
    case inPerson =  "in_person"
    
    var name: String {
        switch self {
        case .online: return "Online"
        case .inPerson: return "In Person"
        }
    }
    var color: UIColor {
        switch self {
        case .online: return "FFFFFF".color
        case .inPerson: return "FFFFFF".color
        }
    }
    var joiningTypeImage : UIImage {
        switch self {
        case .online:
            return UIImage(named: "icon_video")!
        case .inPerson:
            return UIImage(named: "icon-map-pin")!
        }
    }
    
    var linkOrAddress : UIImage {
        switch self {
        case .online:
            return UIImage(named: "link")!
        case .inPerson:
            return UIImage(named: "icon-corner-up-right")!
        }
    }
    
}

enum ShowMeAs: String{
    case busy = "busy"
    case available = "available"
}


enum MarketplaceCategory: String {
    case fashion = "fashion"
    case sport = "sport"
    case entertainment = "entertainment"
    case electronics = "electronics"
    case education = "education"
    case vehicles = "vehicles"
    
    var name: String {
        switch self {
        case .fashion:        return "Fashion"
        case .sport:          return "Sport"
        case .entertainment:  return "Entertainment"
        case .electronics:    return "Electronics"
        case .education:      return "Education"
        case .vehicles:       return "Vehicles"
        }
    }
}


enum MenuItem {
    case myProfile, friends, groups, favorites, events, calendar, classes, deals, store, marketplace, contactUs, settings, logout
    
    var title: String {
        switch self {
        case .myProfile:    return "My Profile"
        case .friends:      return "Friends"
        case .groups:       return "Groups"
        case .favorites:    return "Favorites"
        case .events:       return "Events"
        case .calendar:     return "Calendar"
        case .classes:      return "Classes"
        case .deals:        return "Deals"
        case .store:        return "EDYOU Store"
        case .marketplace:  return "Marketplace"
        case .contactUs:    return "Contact Us"
        case .settings:     return "Settings"
        case .logout:       return "Log Out"
        }
    }
    
    
    var image: UIImage? {
        switch self {
        case .myProfile:    return R.image.menu_profile_icon()
        case .friends:      return R.image.menu_friends_icon()
        case .groups:       return R.image.menu_groups_icon()
        case .favorites:    return R.image.menu_favorites_icon()
        case .events:       return R.image.menu_events_icon()
        case .calendar:     return R.image.menu_calendar_icon()
        case .classes:      return R.image.menu_classes_icon()
        case .deals:        return R.image.menu_deals_icon()
        case .store:        return R.image.menu_edyou_store_icon()
        case .marketplace:  return R.image.menu_marketplace_icon()
        case .contactUs:    return R.image.menu_contact_us_icon()
        case .settings:     return R.image.menu_settings_icon()
        case .logout:       return R.image.menu_logout_icon()
        }
    }
    
}

enum SettingItem {
    case notification, location, password, invitefriend, post, block, privacyPolicy, deleteAccount
    
    var title: String {
        switch self {
        case .notification:    return "Notifications"
        case .location:      return "Location"
        case .password:       return "Password"
        case .invitefriend:    return "Invite Friends"
        case .post:       return "Post"
        case .block:     return "Block"
        case .privacyPolicy:      return "Privacy Policy"
        case .deleteAccount:        return "Delete Account"
     
        }
    }
    
    
    var image: UIImage? {
        switch self {
        case .notification:    return R.image.settings_notification_icon()
        case .location:      return R.image.settings_location_icon()
        case .password:       return R.image.settings_password_icon()
        case .invitefriend:    return R.image.settings_share_icon()
        case .post:       return R.image.settings_post_icon()
        case .block:     return R.image.settings_block_icon()
        case .privacyPolicy:      return R.image.settings_privacy_icon()
        case .deleteAccount:        return R.image.setting_icon_delete()
        }
    }
    
}


enum ChatGroupAction: String {
    case add_member =           "add_member"
    case remove_member =        "remove_member"
    case add_admin =            "add_admin"
    case remove_admin =         "remove_admin"
    case delete_group =         "delete_group"
    case leave_group =          "leave_group"
    case change_group_name =    "change_group_name"
    case change_group_avatar =  "change_group_avatar"
}

enum NotificationType: String {
    case chat =             "chat"
    case post =             "post"
    case group =            "group"
    case profile =          "profile"
    case event =            "event"
    case group_Invite =     "group_invite"
    case comment =          "comment"
    case message =          "message"
    case reaction =         "reaction"
    case friend =           "friend"
    case story =           "story"
}


//group = "group"
//    event = "event"
//    post = "post"
//    comment = "comment"
//    friend = "friend"
//    message = "message"
//    reaction = "reaction"
//    user = "user"
//    profile = "profile"
//    chat = "chat"
//    story = "story"
//    call = "call"


enum SuggestionType: String {
    case groups, events, peoples, posts
}

enum EmptyCellConfirguration {
    case posts
    case events
    case group
    case photos
    case lock
    case coverPhoto
    case friends
    
    var image: UIImage {
        switch self {
        case .posts:
            return R.image.emptyPosts()!
        case .events:
            return R.image.emptyEvent()!
        case .group:
            return R.image.emptyGroup()!
        case .photos, .coverPhoto:
            return R.image.emptyPhoto()!
        case .lock:
            return R.image.lockProfile()!
        case .friends:
            return R.image.users_icon()!
        }
    }
    var title: String {
        switch self {
        case .posts:
//            return NetworkMonitor.shared.isInternetAvailable ? "No feed yet!" : "No Connection!"
            return "No feed yet!"
        case .events:
            return "No event yet!"
        case .group:
            return "No group yet!"
        case .photos:
            return "No any photo yet!"
        case .lock:
            return "This account is private!"
        case .coverPhoto:
            return "No cover photos yet!"
        case .friends:
            return "No friends yet!"
        }
    }
    var shortDescription: String {
        switch self {
        case .posts:
//            return NetworkMonitor.shared.isInternetAvailable ? "Add a new feeds for university friends" : "please check your internet connection"
            return "Add a new feeds for university friends"
        case .events:
            return "Time to connect with others :)"
        case .group:
            return "Connect with more people by creating Groups."
        case .photos:
            return "Posting photos is easy, get started today."
        case .lock:
            return "To see friends accounts please request access."
        case .friends:
            return "To see friends add them in favourite."
        case .coverPhoto:
            return "Add your cover photos, get started."
        }
    }
}

enum PostEmojiCollection: String {
    case happy
    case blessed
    case loved
    case sad
    case fantastic
    case sick
    case tired
    case heartbroken
    case fabulous
    case angry
    case down
    case safe
    
    var name : String {
        switch self {
        case .angry: return self.rawValue
        case .blessed: return self.rawValue
        case .down: return self.rawValue
        case .fabulous: return self.rawValue
        case .fantastic: return self.rawValue
        case .happy: return self.rawValue
        case .heartbroken: return self.rawValue
        case .loved: return self.rawValue
        case .sad: return self.rawValue
        case .safe: return self.rawValue
        case .sick: return self.rawValue
        case .tired: return self.rawValue
        }
    }
    
    var fullEmojiString: String {
        switch self {
        case .angry: return "😡  Angry"
        case .blessed: return "😇  Blessed"
        case .down: return "😩  Down"
        case .fabulous: return "😎  Fabulous"
        case .fantastic: return "😘  Fantastic"
        case .happy: return "🤗  Happy"
        case .heartbroken: return "💔  HeartBroken"
        case .loved: return "😘  Loved"
        case .sad: return "😔  Sad"
        case .safe: return "🔒  Safe"
        case .sick: return "🤒  Sick"
        case .tired: return "😴  Tired"
        }
    }
    
    var emojiImage: String {
        switch self {
        case .angry: return "😡"
        case .blessed: return "😇"
        case .down: return "😩"
        case .fabulous: return "😎"
        case .fantastic: return "😘"
        case .happy: return "🤗"
        case .heartbroken: return "💔"
        case .loved: return "😘"
        case .sad: return "😔"
        case .safe: return "🔒"
        case .sick: return "🤒"
        case .tired: return "😴"
        }
    }
}

enum NewPostTagAttachmentType {
    case file, imageOrVideo, post, group, background, none
}

enum ContentType: String {
    case groups, posts, story, real
    
    var type : String {
        switch self {
        case .groups: return "groups"
        case .posts: return "post"
        case .story: return "story"
        case .real: return "real"

        }
    }
}

enum BottamSheetSelectContentType: String {
    case favorite, unfollow, hidePost, report
    
    var type : String {
        switch self {
        case .favorite: return "groups"
        case .unfollow: return "post"
        case .hidePost: return "story"
        case .report: return "real"

        }
    }
}
