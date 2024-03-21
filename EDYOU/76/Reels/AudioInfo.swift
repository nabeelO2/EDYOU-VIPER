/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
class AudioInfo : Codable {
	let createdAt : String?
	let updatedAt : String?
	let audioId : String?
	let title : String?
	let description : String?
	let genre : String?
	let artist : String?
	let album : String?
	let duration : Int?
	let url : String?
	let privacy : String?
	let coverImage : String?
	let uploaderId : String?

    var toURL: URL? {
        URL(string: self.url ?? "")
    }
    
	enum CodingKeys: String, CodingKey {

		case createdAt = "created_at"
		case updatedAt = "updated_at"
		case audioId = "audio_id"
		case title = "title"
		case description = "description"
		case genre = "genre"
		case artist = "artist"
		case album = "album"
		case duration = "duration"
		case url = "url"
		case privacy = "privacy"
		case coverImage = "cover_image"
		case uploaderId = "uploader_id"
	}

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
		audioId = try values.decodeIfPresent(String.self, forKey: .audioId)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		genre = try values.decodeIfPresent(String.self, forKey: .genre)
		artist = try values.decodeIfPresent(String.self, forKey: .artist)
		album = try values.decodeIfPresent(String.self, forKey: .album)
		duration = try values.decodeIfPresent(Int.self, forKey: .duration)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		privacy = try values.decodeIfPresent(String.self, forKey: .privacy)
		coverImage = try values.decodeIfPresent(String.self, forKey: .coverImage)
		uploaderId = try values.decodeIfPresent(String.self, forKey: .uploaderId)
	}

}
