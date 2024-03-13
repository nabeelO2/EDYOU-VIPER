//
//  CodableExtension.swift
//  EDYOU
//
//  Created by Masroor Elahi on 06/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation


struct json {
    static let encoder = JSONEncoder()
}
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: json.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
