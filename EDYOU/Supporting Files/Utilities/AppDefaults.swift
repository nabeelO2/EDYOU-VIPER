//
//  AppDefaults.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation

final class AppDefaults {
    static let shared = AppDefaults()
    
    private struct Keys {
        static let termsAndConditionsAccepted = "TermsAndConditionsAccepted"
        static let postSettings = "PostSettings"
        static let userFirstName = "UserFirstName"
        static let userLastName = "UserLastName"
        static let userProfilePicture = "UserProfilePicture"
        static let savedChatRooms = "SavedChatRooms"
        static let eventsCategoryFilter = "EventsCategoryFilter"
        static let eventTypeFilter = "EventsTypeFilter"
        static let eventGoOutFilter = "EventGoOutFilter"
        static let eventFilterCustomDate = "EventFilterCustomDate"
        static let groupFilterOption = "GroupFilterOption"
        static let firstLaunch = "FirstLaunch"
        static let hidePostIDs = "hidePostIDs"

    }
    
    private init() {}
    
    var firstName: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userFirstName)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.userFirstName) ?? ""
        }
    }
    var lastName: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userLastName)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.userLastName) ?? ""
        }
    }
    var profileImage: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userProfilePicture)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.userProfilePicture) ?? ""
        }
    }
    var termsAndConditionsAccepted: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.termsAndConditionsAccepted)
        }
        get {
            UserDefaults.standard.bool(forKey: Keys.termsAndConditionsAccepted)
        }
    }
    var postSettings: PostSettings {
        
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Keys.postSettings)
        }
        get {
            let v = UserDefaults.standard.string(forKey: Keys.postSettings) ?? ""
            return PostSettings(rawValue: v) ?? PostSettings.oneDay
        }
        
    }
    
    var savedRooms: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.savedChatRooms)
        }
        get {
            return (UserDefaults.standard.array(forKey: Keys.savedChatRooms) as? [String]) ?? []
        }
    }
    
    var savedHidePosts: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hidePostIDs)
        }
        get {
            return (UserDefaults.standard.array(forKey: Keys.hidePostIDs) as? [String]) ?? []
        }
    }
    
    var eventsCategoryFilter: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.eventsCategoryFilter)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.eventsCategoryFilter) ?? ""
        }
    }
    
    
    var eventTypeFilter: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.eventTypeFilter)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.eventTypeFilter) ?? ""
        }
    }
    
    var eventFilterCustomDate: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.eventFilterCustomDate)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.eventFilterCustomDate) ?? ""
        }
    }
    
    var selectedEventGoOutTypeFilter: EventGoOutType {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.eventTypeFilter)
        }
        get {
            UserDefaults.standard.value(forKey: Keys.eventTypeFilter) as? EventGoOutType ?? .anyTime
        }
    }
    
    var groupFilterOption: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.groupFilterOption)
        }
        get {
            UserDefaults.standard.string(forKey: Keys.groupFilterOption) ?? ""
        }
    }
    
    var firstLaunch: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.firstLaunch)
        }
        get {
            !UserDefaults.standard.bool(forKey: Keys.firstLaunch)
        }
    }
    
    func clearAllonLogout(){
        UserDefaults.standard.removeObject(forKey: Keys.termsAndConditionsAccepted)
        UserDefaults.standard.removeObject(forKey: Keys.postSettings)
        UserDefaults.standard.removeObject(forKey: Keys.userFirstName)
        UserDefaults.standard.removeObject(forKey: Keys.userLastName)
        UserDefaults.standard.removeObject(forKey: Keys.userProfilePicture)
        UserDefaults.standard.removeObject(forKey: Keys.savedChatRooms)
        UserDefaults.standard.removeObject(forKey: Keys.eventsCategoryFilter)
        UserDefaults.standard.removeObject(forKey: Keys.eventTypeFilter)
        UserDefaults.standard.removeObject(forKey: Keys.eventGoOutFilter)
        UserDefaults.standard.removeObject(forKey: Keys.eventFilterCustomDate)
        UserDefaults.standard.removeObject(forKey: Keys.groupFilterOption)
        UserDefaults.standard.removeObject(forKey: Keys.hidePostIDs)

    }
}
