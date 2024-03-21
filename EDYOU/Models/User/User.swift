//
//  User.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import Foundation
import RealmSwift
import Realm
import SwiftyJSON

// MARK: - User
class User: Object, Codable {
    
    internal init(isPrivate: Bool? = nil, isMessageAllowed: Bool? = nil, isCallAllowed: Bool? = nil, hireMe: Bool? = nil, socialLinks: List<SocialLink> =  List<SocialLink>(), workExperiences: List<WorkExperience> = List<WorkExperience>(), userDocuments: List<UserDocument> = List<UserDocument>(), userCertifications: List<UserCertification> = List<UserCertification>(), friends: Int? = nil, followers: Int? = nil, groups: Int? = nil, posts: Int? = nil, about: String? = nil, website: String? = nil, status: String? = nil, hobbies: List<String> = List<String>(), languages: List<String> = List<String>(), skills:  List<String> =  List<String>(), name: Name = Name(), education: List<Education> = List<Education>(), addresses: List<UserAddress> = List<UserAddress>(), phone: List<Phone> = List<Phone> (), gender: String? = nil, dateOfBirth: DateOfBirth? = nil, notificationEnabled: Bool = false, instituteName: String? = nil, profileImage: String? = nil, profileThumbnail: String? = nil, coverPhotos: List<CoverPhoto> = List<CoverPhoto>(), userID: String? = nil, email: String? = nil, requestOrigin: String? = nil, isFavorite: Bool? = nil, isSelected: Bool = false,groupMemberStatus: String? = nil, school: UserSchool = UserSchool(), isUserVerified: Bool? = nil,  college: String? = nil, friendrequeststatus: FriendShipStatus? = nil,major_end_year: String? = nil,major_start_year: String? = nil, schoolID: String? = nil) {
        
     
        self.isPrivate = isPrivate ?? false
        self.isMessageAllowed = isMessageAllowed ?? false
        self.isCallAllowed = isCallAllowed ?? false
        self.hireMe = hireMe ?? false
        self.isUserVerified = isUserVerified ?? false
        self.socialLinks = socialLinks
        self.workExperiences = workExperiences
        self.userDocuments = userDocuments
        self.userCertifications = userCertifications
        self.friends = friends ?? 0
        self.followers = followers ?? 0
        self.groups = groups ?? 0
        self.posts = posts ?? 0
        self.about = about
        self.website = website
        self.status = status
        self.hobbies = hobbies
        self.languages = languages
        self.skills = skills
        self.name = name
        self.education = education
        self.addresses = addresses
        self.phone = phone
        self.gender = gender
        self.dateOfBirth = dateOfBirth ?? DateOfBirth(birthYear: "", birthMonth: "", birthDate: "")
        self.notificationEnabled = notificationEnabled
        self.instituteName = instituteName
        self.profileImage = profileImage
        self.profileThumbnail = profileThumbnail
        self.coverPhotos = coverPhotos
        self.userID = userID
        self.email = email
        self.requestOrigin = requestOrigin
        self.isFavorite = isFavorite ?? false
        self.isSelected = isSelected
        self.groupMemberStatus = groupMemberStatus
        self.college = college
        self.schoolID = schoolID
    }
    
  
    override init() {
        super.init()
    }
    
    
    @objc dynamic var isPrivate:Bool = false
    @objc dynamic var isMessageAllowed:Bool = false
    @objc dynamic var isCallAllowed:Bool = false
    @objc dynamic var hireMe: Bool = false
    @objc dynamic var isUserVerified: Bool = false
    @objc dynamic var major_end_year: String?
    @objc dynamic var major_start_year: String?
    var socialLinks: List<SocialLink> = List<SocialLink>()
    var workExperiences: List<WorkExperience> = List<WorkExperience>()
    var userDocuments: List<UserDocument> = List<UserDocument>()
    var userCertifications: List<UserCertification> =  List<UserCertification>()
    @objc dynamic var friends: Int = 0
    @objc dynamic var followers: Int = 0
    @objc dynamic var groups: Int = 0
    @objc dynamic var posts: Int = 0
    @objc dynamic var about, website, status: String?
    var hobbies: List<String> = List<String>()
    var languages: List<String> = List<String>()
    var skills : List<String> = List<String>()
    @objc dynamic var name: Name?
    var education: List<Education> = List<Education>()
    var addresses: List<UserAddress> = List<UserAddress>()
    var phone: List<Phone> = List<Phone>()
    @objc dynamic var gender: String?
    @objc dynamic var schoolID: String?
    @objc dynamic var dateOfBirth: DateOfBirth?
    @objc dynamic var notificationEnabled: Bool = false
    @objc dynamic var instituteName, profileImage, college, profileThumbnail: String?
    var coverPhotos: List<CoverPhoto> = List<CoverPhoto>()
    @objc dynamic var userID: String?
    @objc dynamic  var email: String?
    @objc dynamic  var requestOrigin: String?
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var isSelected = false
    @objc dynamic var groupMemberStatus : String?
    var friendrequeststatus : FriendShipStatus?

    var coverPhotosArray: [CoverPhoto] {
        return self.coverPhotos.toArray(type: CoverPhoto.self)
    }

    func contains(text: String, caseSensitive: Bool = false) -> Bool {
         if caseSensitive {
             if name?.completeName.contains(text) == true || instituteName?.contains(text) == true || education.first?.instituteName?.contains(text) == true {
                 return true
             }
         } else {
             let t = text.lowercased()
             if name?.completeName.lowercased().contains(t) == true || instituteName?.lowercased().contains(t) == true || education.first?.instituteName?.lowercased().contains(t) == true {
                 return true
             }
         }
         return false
     }
    
    var formattedUserName: String {
        let f = (name?.firstName ?? "").trimmed
        let l = (name?.lastName ?? "").trimmed
        let name = "\(f) \(l)"//.replacingOccurrences(of: " ", with: "_")
        
        return name
    }
    var isMe: Bool {
        return userID == Cache.shared.user?.userID
    }
    static var nilUser: User {
        let u = User(isPrivate:false,isMessageAllowed: false,isCallAllowed: false, hireMe: false, socialLinks: List<SocialLink>(), workExperiences: List<WorkExperience>(), userDocuments: List<UserDocument>(), userCertifications: List<UserCertification>(), friends: 0, followers: 0, groups: 0, posts: 0, about: "", website: "", status: "", hobbies: List<String>(), languages: List<String>(), skills: List<String>(), name: Name(firstName: "", lastName: "", middleName: "", nickName: ""), education: List<Education>(), addresses:  List<UserAddress>(), phone:  List<Phone>(), gender: nil, dateOfBirth: DateOfBirth(birthYear: "", birthMonth: "", birthDate: ""), notificationEnabled: false, instituteName: nil, profileImage: "", profileThumbnail: nil, coverPhotos:  List<CoverPhoto>() , userID: "", email: nil, requestOrigin: "", isFavorite: false, isSelected: false,groupMemberStatus: nil, isUserVerified: false, college: "", friendrequeststatus: FriendShipStatus.none, major_end_year: "",major_start_year:"",schoolID: "")
        return u
    }
    static var me: User {
        if let u = Cache.shared.user {
            return u
        }
        let u = User.nilUser
        return u
    }
    
    enum CodingKeys: String, CodingKey {
        case friends, followers, groups, posts, about, website, status, languages, hobbies, name, education, addresses, phone, gender,skills, college
        case major_end_year = "major_end_year"
        case major_start_year = "major_start_year"
        case groupMemberStatus = "user_group_joined_status"
        case socialLinks = "social_links"
        case userDocuments = "user_documents"
        case userCertifications = "user_certifications"
        case workExperiences = "work_experiences"
        case dateOfBirth = "date_of_birth"
        case notificationEnabled = "notification_enabled"
        case instituteName = "institute_name"
        case profileImage = "profile_image"
        case coverPhotos = "cover_photos"
        case profileThumbnail = "profile_thumbnail"
        case userID = "user_id"
        case email
        case requestOrigin = "request_origin"
        case isFavorite = "is_favourite"
        case hireMe = "hire_me"
        case isPrivate = "is_private"
        case isMessageAllowed =  "is_message_allowed"
        case isCallAllowed = "is_call_allowed"
        case isUserVerified = "is_verified"
        case friendrequeststatus = "friend_request_status"
        case schoolID = "school_id"

    }
    

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        major_end_year = try values.decodeIfPresent(String.self, forKey: .major_end_year) ?? ""
        major_start_year = try values.decodeIfPresent(String.self, forKey: .major_start_year) ?? ""
        isPrivate = try values.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        isMessageAllowed = try values.decodeIfPresent(Bool.self, forKey: .isMessageAllowed) ?? false
        isCallAllowed = try values.decodeIfPresent(Bool.self, forKey: .isCallAllowed) ?? false
        hireMe = try values.decodeIfPresent(Bool.self, forKey: .hireMe) ?? false
        isUserVerified = try values.decodeIfPresent(Bool.self, forKey: .isUserVerified) ?? false
        skills = try values.decodeIfPresent(List<String>.self, forKey: .skills) ?? List<String>()
        socialLinks = try values.decodeIfPresent(List<SocialLink>.self, forKey: .socialLinks) ?? List<SocialLink>()
        workExperiences = try values.decodeIfPresent(List<WorkExperience>.self, forKey: .workExperiences) ?? List<WorkExperience>()
        userDocuments = try values.decodeIfPresent(List<UserDocument>.self, forKey: .userDocuments) ?? List<UserDocument>()
        userCertifications = try values.decodeIfPresent(List<UserCertification>.self, forKey: .userCertifications) ?? List<UserCertification>()
        friends = try values.decodeIfPresent(Int.self, forKey: .friends) ?? 0
        followers = try values.decodeIfPresent(Int.self, forKey: .followers) ?? 0
        groups = try values.decodeIfPresent(Int.self, forKey: .groups) ?? 0
        posts = try values.decodeIfPresent(Int.self, forKey: .posts) ?? 0
        about = try values.decodeIfPresent(String.self, forKey: .about)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        languages = try values.decodeIfPresent(List<String>.self, forKey: .languages) ?? List<String>()
        hobbies = try values.decodeIfPresent(List<String>.self, forKey: .hobbies) ?? List<String>()
        name = try values.decodeIfPresent(Name.self, forKey: .name) ?? Name(firstName: "", lastName: "", middleName: "", nickName: "")
        education = try values.decodeIfPresent(List<Education>.self, forKey: .education) ?? List<Education>()
        addresses = try values.decodeIfPresent(List<UserAddress>.self, forKey: .addresses) ?? List<UserAddress>()
        phone = try values.decodeIfPresent(List<Phone>.self, forKey: .phone) ?? List<Phone>()
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        dateOfBirth = try values.decodeIfPresent(DateOfBirth.self, forKey: .dateOfBirth) ?? DateOfBirth(birthYear: "", birthMonth: "", birthDate: "")
        notificationEnabled = try values.decodeIfPresent(Bool.self, forKey: .notificationEnabled) ?? false
        instituteName = try values.decodeIfPresent(String.self, forKey: .instituteName)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
        coverPhotos = try values.decodeIfPresent(List<CoverPhoto>.self, forKey: .coverPhotos) ?? List<CoverPhoto>()
        profileThumbnail = try values.decodeIfPresent(String.self, forKey: .profileThumbnail)
        userID = try values.decodeIfPresent(String.self, forKey: .userID) ?? ""
        email = try values.decodeIfPresent(String.self, forKey: .email)
        requestOrigin = try values.decodeIfPresent(String.self, forKey: .requestOrigin)
        isFavorite = try values.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        groupMemberStatus = try values.decodeIfPresent(String.self, forKey: .groupMemberStatus)
        friendrequeststatus = try values.decodeIfPresent(FriendShipStatus.self, forKey: .friendrequeststatus)
        college = try values.decodeIfPresent(String.self, forKey: .college)

        schoolID = try values.decodeIfPresent(String.self, forKey: .schoolID)
    }
    
    
    class func build(_ json:JSON) -> User {

        let name = json["name"]
        let fullName = Name(firstName: name["first_name"].stringValue, lastName: name["last_name"].stringValue, middleName: name["middle_name"].stringValue, nickName: name["nick_name"].stringValue)
        
        let user = User(name: fullName, instituteName: json["major"].stringValue, profileImage: json["profile_image"].stringValue, profileThumbnail: json["profile_thumbnail"].stringValue, userID: json["user_id"].stringValue, isUserVerified: json["is_active"].boolValue, major_end_year: json["major_start_year"].stringValue, major_start_year: json["major_start_year"].stringValue)
        
        return user
      }


    
}
extension User {
    func getCurrentEducation() -> Education? {
        return self.education.first(where: {$0.isCurrent ?? false})
    }
}


enum gender
{
    case male,female, preferNotToSay, anotherGenderIdentity
}



