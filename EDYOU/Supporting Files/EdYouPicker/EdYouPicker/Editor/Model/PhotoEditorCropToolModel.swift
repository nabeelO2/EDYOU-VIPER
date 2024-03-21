//
//  PhotoEditorCropToolModel.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/4/15.
//

import UIKit

class PhotoEditorCropToolModel: Equatable {
    
    var size: CGSize = .zero
    var scaleSize: CGSize = .zero
    var widthRatio: CGFloat = 0
    var heightRatio: CGFloat = 0
    var scaleText: String {
        if widthRatio == 0 {
            return "Free".localized
        }
        return String(
            format: "%d:%d",
            Int(widthRatio),
            Int(heightRatio)
        )
    }
    var isSelected: Bool = false
    
    static func == (
        lhs: PhotoEditorCropToolModel,
        rhs: PhotoEditorCropToolModel
    ) -> Bool {
        lhs === rhs
    }
}
