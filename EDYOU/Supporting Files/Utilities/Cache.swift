//
//  Cashe.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import Foundation


final class Cache {
    static let shared = Cache()
    
    private init() {
        let u = User.nilUser
        u.userID = Keychain.shared.userId ?? ""
        u.name = Name(firstName: AppDefaults.shared.firstName, lastName: AppDefaults.shared.lastName, middleName: "", nickName: "")
        u.profileImage = AppDefaults.shared.profileImage
        user = u
    }
    
    var friends: SearchFriends?
    var frinedDict:[String:[String]] = [:] {
        didSet {
            UserDefaults.standard.setValue(frinedDict, forKey: "frinedDict")
        }
    }

    var institutes = [Institute]()
    var states: [String] = []
    var user: User? {
        didSet {
            if let id = user?.userID {
                Keychain.shared.userId = id
            }
            if let name = user?.name?.firstName {
                AppDefaults.shared.firstName = name
            }
            if let name = user?.name?.lastName {
                AppDefaults.shared.lastName = name
            }
            if let pic = user?.profileImage {
                AppDefaults.shared.profileImage = pic
            }
        }
    }
    
    func clear() {
        institutes = []
        user = nil
        AppDefaults.shared.clearAllonLogout()
    }
    
    func getOtherUser(jid:String)-> (String?,String?)? {
        guard let other = Cache.shared.frinedDict[jid] else {return nil}
        return (other.first,other.last)
    }

}
