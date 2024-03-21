//
//  DataPickerItem.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit

class DataPickerItem<T: Any> {
    var title: String
    var image: UIImage?
    var imageURL: String?
    var isSelected = false
    var data: T?
    
    init(title: String, image: UIImage? = nil, imageURL: String? = nil, isSelected: Bool = false, data: T? = nil) {
        self.title = title
        self.image = image
        self.imageURL = imageURL
        self.isSelected = isSelected
        self.data = data
    }
    
    static func from(strings: [String]) -> [DataPickerItem] {
        let array = strings.map { title in
            DataPickerItem(title: title)
        }
        return array
    }
}



