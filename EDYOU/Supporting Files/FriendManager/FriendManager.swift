//
//  FriendManager.swift
//  EDYOU
//
//  Created by imac3 on 27/02/2024.
//

import Foundation
import RealmSwift


class FriendManager: NSObject
{
    
    static var shared = FriendManager()
    var realmDB: Realm!
    
    var friends : [MyFriends] = []
    
    
    override init() {
        super.init()
        
        realmDB = try! Realm()
        
    }
    
    
    //MARK:  Methods Realm
    func fetchChatRoomsFromRealm(completion: @escaping (([MyFriends]) -> Void))
    {
        completion([])
//        RealmContextManager.shared._realmQueue.async {
//            RealmContextManager.shared.fetch(MyFriends.self, predicate: nil, completion: { friends in
//                let list = friends.detached()
//                //print(list.first?.messages)
//                self.friends = list
//                completion(list)
//            })
//        }
        
    }
    
    func savefriendInRealm(friend: MyFriends, completion: ((Bool) -> Void))
    {
        completion(false)
        
//        if !friends.contains(where: { obj in
//            obj.userId?.lowercased() == friend.userId?.lowercased()
//        }){
//            friends.append(friend)
//            try! self.realmDB.write {
//                self.realmDB.add(friends)
//            }
//        }else{
//            print("Already Added")
//        }
        
        
    }
    
    func savefriendLocally( searchfriends: SearchFriends)
    {
//        let pendingFriends = searchfriends.pendingFriends
//        let blockedusers = searchfriends.blockedusers
//        let friends = searchfriends.friends
//        let rejected = searchfriends.rejectedFriends
//
//        var newUsers : [MyFriends] = []
//        pendingFriends?.forEach({ user in
//            if !self.friends.contains(where: { obj in
//                obj.userId?.lowercased() == user.userID?.lowercased()
//            }){
//                newUsers.append(MyFriends(userId: user.userID, name: user.name?.completeName, school: user.college, profile: user.profileImage, status: "2"))
//            }
//        })
//        blockedusers?.forEach({ user in
//            if !self.friends.contains(where: { obj in
//                obj.userId?.lowercased() == user.userID?.lowercased()
//            }){
//                newUsers.append(MyFriends(userId: user.userID, name: user.name?.completeName, school: user.college, profile: user.profileImage, status: "5"))
//            }
//        })
//        friends?.forEach({ user in
//            if !self.friends.contains(where: { obj in
//                obj.userId?.lowercased() == user.userID?.lowercased()
//            }){
//                newUsers.append(MyFriends(userId: user.userID, name: user.name?.completeName, school: user.college, profile: user.profileImage, status: "3"))
//            }
//        })
//        rejected?.forEach({ user in
//            if !self.friends.contains(where: { obj in
//                obj.userId?.lowercased() == user.userID?.lowercased()
//            }){
//                newUsers.append(MyFriends(userId: user.userID, name: user.name?.completeName, school: user.college, profile: user.profileImage, status: "4"))
//            }
//        })
//
//        self.friends.append(contentsOf: newUsers)
//        try! self.realmDB.write {
//            self.realmDB.add(self.friends)
//
//        }
        
    }
}
