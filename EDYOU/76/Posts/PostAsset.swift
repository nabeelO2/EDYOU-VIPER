//
//  PostAsset.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

struct PostAsset: Codable {
    var images, videos, gifs, documents: [String]?
}
