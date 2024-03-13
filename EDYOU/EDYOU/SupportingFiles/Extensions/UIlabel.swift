//
//  UIlabel.swift
//  EDYOU
//
//  Created by Masroor on 14/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import appendAttributedString

extension UILabel {
    
    @IBInspectable var showEsteric: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.attributedText = NSMutableAttributedString().append(self.text ?? "" ,font: self.font).append(" *", color: .red)
            }
        }
    }
    
//    @IBInspectable var fontName: String {
//        get {
//            return ""
//        }
//        set {
//            let f = FontType(rawValue : newValue)
//            self.font = FontManager(fontType: f!).font
//            
//        }
//    }
    
    
    
}

//extension UILabel {
//    override open func awakeFromNib() {
//        super.awakeFromNib()
//        changeFontName()
//    }
//
//    func changeFontName() {
////        self.font = UIFont(name: "SFProDisplay-Bold", size: self.font.pointSize)
//    }
//}

