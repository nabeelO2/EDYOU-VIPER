/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
class Reels : Codable {
    
	let createdAt : String?
	let updatedAt : String?
	let videoId : String?
	let uploaderId : String?
	let title : String?
	let description : String?
	let duration : Int
	let url : String?
	let coverImage : String?
	let privacy : String?
	var likes : [String]?
	let dislikes : [String]?
	let views : Int
	var comments : [Comment]?
	let uploaderPublicProfile : User?
    let audioId: String?
    let audioInfo: AudioInfo?
    
   
    
    internal init(createdAt: String? = nil, updatedAt: String? = nil, videoId: String? = nil, uploaderId: String? = nil, title: String? = nil, description: String? = nil, duration: Int = 0, url: String? = nil, coverImage: String? = nil, privacy: String? = nil , likes: [String]? = nil, dislikes: [String]? = nil, views: Int = 0, comments: [Comment]? = nil, uploaderPublicProfile: User? = nil, audioId: String? = nil, audioInfo: AudioInfo? = nil) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.videoId = videoId
        self.uploaderId = uploaderId
        self.title = title
        self.description = description
        self.duration = duration
        self.url = url
        self.coverImage = coverImage
        self.privacy = privacy
        self.likes = likes
        self.dislikes = dislikes
        self.views = views
        self.comments = comments
        self.uploaderPublicProfile = uploaderPublicProfile
        self.audioId = audioId
        self.audioInfo = audioInfo
    }
    
   
    
    var isLikedByMe: Bool {
        return self.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
    }
    
	enum CodingKeys: String, CodingKey {

		case createdAt = "created_at"
		case updatedAt = "updated_at"
		case videoId = "video_id"
		case uploaderId = "uploader_id"
		case title = "title"
		case description = "description"
		case duration = "duration"
		case url = "url"
		case coverImage = "cover_image"
		case privacy = "privacy"
		case likes = "likes"
		case dislikes = "dislikes"
		case views = "views"
		case comments = "comments"
		case uploaderPublicProfile = "uploader_public_profile"
        case audioInfo = "audio_info"
        case audioId = "audio_id"
	}

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
		videoId = try values.decodeIfPresent(String.self, forKey: .videoId)
		uploaderId = try values.decodeIfPresent(String.self, forKey: .uploaderId)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration) ?? 0
		url = try values.decodeIfPresent(String.self, forKey: .url)
		coverImage = try values.decodeIfPresent(String.self, forKey: .coverImage)
		privacy = try values.decodeIfPresent(String.self, forKey: .privacy)
		likes = try values.decodeIfPresent([String].self, forKey: .likes)
		dislikes = try values.decodeIfPresent([String].self, forKey: .dislikes)
		views = try values.decodeIfPresent(Int.self, forKey: .views) ?? 0
		comments = try values.decodeIfPresent([Comment].self, forKey: .comments)
		uploaderPublicProfile = try values.decodeIfPresent(User.self, forKey: .uploaderPublicProfile)
        audioId = try values.decodeIfPresent(String.self, forKey: .audioId)
        audioInfo = try values.decodeIfPresent(AudioInfo.self, forKey: .audioInfo)
	}
    
}
// MARK: - Helpers
extension Reels {
    func manageLikeDislike(userId: String, like: Bool) {
        if like {
            self.likes?.append(userId)
        } else if let index = self.likes?.firstIndex(of: userId) {
            self.likes?.remove(at: index)
        }
    }
}
