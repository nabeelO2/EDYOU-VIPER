//
//  Post+Extensions.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

extension Array where Element == Post {
    mutating func updateRecord(with posts: [Post]) {
        
        var newPosts = posts
        for (index, post) in self.enumerated() {
            let i = newPosts.firstIndex { $0.postID == post.postID }
            
            if let indx = i, indx >= 0  {
                self[index] = newPosts[indx]
                newPosts.remove(at: indx)
            }
        }
        self.append(contentsOf: newPosts)
        
    }
}



extension Array where Element == Post {
    
    mutating func setIsReacted() {
        guard let myId = Cache.shared.user?.userID else { return }
        
        for (index, post) in self.enumerated() {
            
            let i = post.reactions?.first(where: { $0.userId == myId })
            self[index].myReaction = i
        }
    }
    mutating func updateMediaArray() {
        
        for (index, _) in self.enumerated() {
            self[index].updateMediaArray()
//            var videos = PostMedia.from(urls: post.postAsset?.videos ?? [], type: .video)
//            let images = PostMedia.from(urls: post.postAsset?.images ?? [], type: .image)
//            videos.append(contentsOf: images)
//            self[index].medias = videos
        }
    }
    
}


extension Post {
    
    mutating func setIsReacted() {
        guard let myId = Cache.shared.user?.userID else { return }
        
        let i = self.reactions?.first(where: { $0.userId == myId })
        self.myReaction = i
        
    }
    
    func setCommentsIsLiked() {
        guard let myId = Cache.shared.user?.userID else { return }
        
        for (cIndex, c) in (self.comments ?? []).enumerated() {
            let i = c.commentLikes?.contains(where: { $0.userID == myId })
            self.comments?[cIndex].isLiked = i == true
        }
        
    }
    mutating func updateMediaArray() {
        var videos = PostMedia.from(urls: self.postAsset?.videos ?? [], type: .video)
        let images = PostMedia.from(urls: self.postAsset?.images ?? [], type: .image)
        videos.append(contentsOf: images)
        self.medias = videos
    }
    
}

extension Array where Element == PostLike {
    var users: [User] {
        var u = [User]()
        for like in self {
            if let user = like.user {
                u.append(user)
            }
        }
        return u
    }
}

extension Array where Element == Post {
    var users: [User] {  
        var u = [User]()
        for post in self {
            if let user = post.user {
                let contains = u.contains { $0.userID == user.userID }
                if !contains {
                    u.append(user)
                }
                
            }
        }
        return u
    }
    func stories() -> [Story] {
        let users = self.users
        var s = [Story]()
        
        for user in users {
            let usersPosts = self.filter { $0.user?.userID == user.userID }
            if usersPosts.count > 0 {
                s.append(Story(user: user, stories: usersPosts))
            }
        }
        
        return s
    }
}
