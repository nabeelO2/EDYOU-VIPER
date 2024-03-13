//
//  ColorExnts.swift
//  EDYOU
//
//  Created by  Mac on 14/09/2021.
//

import UIKit


extension UIColor {
    convenience init(id: Int, alpha: CGFloat = 1.0) {
        
        let EXPECTED_MAX = 15
        let HUE_FACTOR = 255 / EXPECTED_MAX
        
        let Saturation = 175, Brightness = 175
        let Hue = (id * HUE_FACTOR) % 255
        
        self.init(hue: CGFloat(Hue) / 255, saturation: CGFloat(Saturation) / 255, brightness: CGFloat(Brightness) / 255, alpha: alpha)
    }
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }

    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}

extension String {
    var color: UIColor {
        return UIColor(hexString: self)
    }
}

extension Array where Element: UIColor {
    
    var hexStrings: [String] {
        let s = self.map { $0.toHexString() }
        return s
    }
    
}

extension Sequence where Element == String {

    var colors: [UIColor] {
        let c = self.map { $0.color }
        return c
    }
}


extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
