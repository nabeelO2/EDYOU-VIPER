//
//  UIFont+Extension.swift
//  EDYOU
//
//  Created by imac3 on 12/04/2023.
//

import Foundation
import UIKit


extension UIFont {
    static var isOverrided: Bool = false

    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }

    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }

//    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
//        return UIFont(name: AppFontName.italic, size: size)!
//    }

    @objc class func myMediumSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.medium, size: size)!
    }

    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFontName.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.bold
        case "CTFontMediumUsage","CTFontObliqueUsage":
            fontName = AppFontName.medium
        case "CTFontDemiUsage":
            fontName = AppFontName.semiBold
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }

    class func overrideInitialize() {
        guard self == UIFont.self, !isOverrided else { return }

        // Avoid method swizzling run twice and revert to original initialize function
        isOverrided = true

        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }

        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }

        if let mediumSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let mymediumSystemFontMethod = class_getClassMethod(self, #selector(myMediumSystemFont(ofSize:))) {
            method_exchangeImplementations(mediumSystemFontMethod, mymediumSystemFontMethod)
        }

        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}



extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}




struct AppFontName {
    static let regular = "SFProDisplay-Regular"
    static let bold = "SFProDisplay-Bold"
   // static let italic = "SFProDisplay-Medium"
    static let medium = "SFProDisplay-Medium"
    static let semiBold = "SFProDisplay-Semibold"
}

