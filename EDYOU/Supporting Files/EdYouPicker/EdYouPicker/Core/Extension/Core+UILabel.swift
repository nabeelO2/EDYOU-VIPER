//
//  Core+UILabel.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/10/22.
//

import UIKit

extension UILabel {
    var textHeight: CGFloat {
        text?.height(ofFont: font, maxWidth: hx_width > 0 ? hx_width : CGFloat(MAXFLOAT)) ?? 0
    }
    var textWidth: CGFloat {
        text?.width(ofFont: font, maxHeight: hx_height > 0 ? hx_height : CGFloat(MAXFLOAT)) ?? 0
    }
}

public extension HXPickerWrapper where Base: UILabel {
    var textWidth: CGFloat {
        base.textWidth
    }
    var textHeight: CGFloat {
        base.textHeight
    }
}
