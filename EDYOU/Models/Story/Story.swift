//
//  Story.swift
//  EDYOU
//
//  Created by  Mac on 05/10/2021.
//

import Foundation

class Story {
    var user: User
    var stories: [Post]
    internal init(user: User, stories: [Post]) {
        self.user = user
        self.stories = stories
    }
}

struct StoriesData: Codable {
    var userID: String?
    var posts: [Post]?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case posts
    }
}
class USCitiesData: Codable {
    var msg: String?
    var data: [String]?

    enum CodingKeys: String, CodingKey {
        case msg
        case data
    }
}


extension Array where Element == StoriesData {
    func stories() -> [Story] {
        var strs = [Story]()
        var resultedPosts = [Post]()
        for s in self {
            resultedPosts.removeAll()
            let p = s.posts?.first(where: { $0.user != nil })
            if let user = p?.user {
                for post in s.posts! {
                    var singlePost = post
                    if post.postAsset?.images?.count ?? 0 > 0 {
                    for image in post.postAsset!.images! {
                        singlePost.mediaUrl = image
                        singlePost.mediaType = .image
                        resultedPosts.append(singlePost)
                    }
                    }
                    if post.postAsset?.videos?.count ?? 0 > 0 {
                        for video in post.postAsset!.videos! {
                            singlePost.mediaUrl = video
                            singlePost.mediaType = .video
                            resultedPosts.append(singlePost)
                        }
                    }
                    if post.postAsset?.images?.isEmpty ?? true && post.postAsset?.videos?.isEmpty ?? true {
                        resultedPosts.append(singlePost)
                    }
                }
                strs.append(Story(user: user, stories: resultedPosts ))
            }
        }

        return strs
    } 
}
