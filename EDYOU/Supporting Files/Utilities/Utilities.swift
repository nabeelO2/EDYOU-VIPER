//
//  Utilities.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//

import Foundation
import CoreLocation
import MapKit
import SwiftMessages

class Device {
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

struct EmojiVal {
    var value: String
    var category: EmojiCategory
}

class Utilities {
    static var emojis = [EmojiVal]()
    
    static func getFriendShipButtonProperties(for status: FriendShipStatusModel) -> (title: String, color: UIColor?) {
        var title = ""
        var color = R.color.buttons_green()
        
        if status.friendRequestStatus == .approved {
            title = "Unfriend"
            color = R.color.sub_title() ?? .lightGray
        } else if status.friendRequestStatus == FriendShipStatus.none {
            title = "Add Friend"
            color = R.color.buttons_green() ?? .green
        } else if status.friendRequestStatus == FriendShipStatus.pending {
            if status.requestOrigin == .sent {
                title = "Cancel Request"
                color = R.color.sub_title() ?? .lightGray
            } else {
                title = "Accept Request"
                color = R.color.buttons_green() ?? .green
            }
        }
        
        return (title: title, color: color)
    }
    
    
    static func openLocationInMap(latitude: Double, longitude: Double, locationName: String?) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = locationName
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    static func openURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.showErrorWith(message: "Invalid url to open. Please enter valid link")
            return
        }
        UIApplication.shared.open(url, options: [:]) { error in
            if !error {
                self.showErrorWith(message: "Invalid url to open. Please enter valid link")
            }
            
        }
    }
    
    static func getCurrentTimeStamp() -> String
    {
        
        let date = Date()

        var calendar = Calendar.current


        calendar.timeZone = TimeZone(identifier: "UTC")!

        let components = calendar.dateComponents([.hour, .year, .minute], from: date)


        // *** Get Individual components from date ***
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return ("\(hour):\(minutes):\(seconds)")
    }
    
    static func loadEmojis() {
        _ = getEmojis()
    }
    static func getEmojis() -> [EmojiVal] {
        if emojis.count > 0 {
            return emojis
        }
        emojis = []
        let e = EmojiCategory.allCases
        for em in e {
            for i in em.getRange() where isEmoji(i) {
                if let scalar = UnicodeScalar(i) {
                    let unicode = Character(scalar)
                    if unicode.unicodeAvailable() {
                        emojis.append(EmojiVal(value: String(scalar), category: em))
                    }
                }
            }
        }
        return emojis
    }
    
    static func isEmoji(_ value: Int) -> Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols 9728 - 9983
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
        0x1F018...0x1F270, // Various asian characters           127000...127600
        65024...65039, // Variation selector
        9100...9300, // Misc items
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
           
        default: return false
        }
    }
    
    static func showErrorWith(message: String){

        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 3)
        
        let error = MessageView.viewFromNib(layout: .cardView)
        
        let iconImage = IconStyle.default.image(theme: .error)
        error.configureTheme(backgroundColor: R.color.buttons_blue() ?? .blue, foregroundColor:  UIColor.white, iconImage: iconImage)
        
        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }
}



extension Character {
    private static let refUnicodeSize: CGFloat = 8
    private static let refUnicodePng =
        Character("\u{1fff}").png(ofSize: Character.refUnicodeSize)
    
    func png(ofSize fontSize: CGFloat) -> Data? {
        var png:Data? = nil
        DispatchQueue.main.async {
            let attributes = [NSAttributedString.Key.font:
                                UIFont.systemFont(ofSize: fontSize)]
            let charStr = "\(self)" as NSString
            let size = charStr.size(withAttributes: attributes)

            UIGraphicsBeginImageContext(size)
            charStr.draw(at: CGPoint(x: 0,y :0), withAttributes: attributes)

            if let charImage = UIGraphicsGetImageFromCurrentImageContext() {
                png = charImage.pngData()
            }
            UIGraphicsEndImageContext()
        }
        return png
    }
    
    func unicodeAvailable() -> Bool {
        if let refUnicodePng = Character.refUnicodePng,
           let myPng = self.png(ofSize: Character.refUnicodeSize) {
            return refUnicodePng != myPng
        }
        return false
    }
}

enum EmojiCategory: CaseIterable {
    case emoticons
    case pictographs
    case transport
    case flags
    case music
    case dingbats
    case variation
    case supplemental
    case asian
    case variationSelector
    case miscs
    case combining
    
    func getRange() -> ClosedRange<Int> {
        switch self {
        case .emoticons:
            return 0x1F600...0x1F64F
        case .pictographs:
            return 0x1F300...0x1F5FF
        case .transport:
            return 0x1F680...0x1F6FF
        case .flags:
            return 0x1F1E6...0x1F1FF
        case .music:
            return 0x2600...0x26FF
        case .dingbats:
            return 0x2700...0x27BF
        case .variation:
            return 0xFE00...0xFE0F
        case .supplemental:
            return 0x1F900...0x1F9FF
        case .asian:
            return 0x1F018...0x1F270
        case .variationSelector:
            return 65024...65039
        case .miscs:
            return 9100...9300
        case .combining:
            return 8400...8447
        }
    }
    
//    func all() -> [ClosedRange<Int>] {
//        let x = [Emojis.emoticons, Emojis.supplemental, Emojis.pictographs, Emojis.transport, Emojis.music, Emojis.dingbats, Emojis.flags, Emojis.variation, Emojis.asian, Emojis.variationSelector, Emojis.miscs, Emojis.combining]
//        return x
//    }
}

//struct Emojis {
//
//    case emoticons:  return0x1F600...0x1F64F
//    case pictographs:  return0x1F300...0x1F5FF
//    case transport:  return0x1F680...0x1F6FF
//    case flags:  return0x1F1E6...0x1F1FF
//    case music:  return0x2600...0x26FF
//    case dingbats:  return0x2700...0x27BF
//    case variation:  return0xFE00...0xFE0F
//    case supplemental:  return0x1F900...0x1F9FF
//    case asian:  return0x1F018...0x1F270
//    case variationSelector:  return65024...65039
//    case miscs:  return9100...9300
//    case combining:  return8400...8447
//
//
//    func all() -> [ClosedRange<Int>] {
//        let x = [Emojis.emoticons, Emojis.supplemental, Emojis.pictographs, Emojis.transport, Emojis.music, Emojis.dingbats, Emojis.flags, Emojis.variation, Emojis.asian, Emojis.variationSelector, Emojis.miscs, Emojis.combining]
//        return x
//    }
//}

struct HomeReactions {
    static var homeReaction =  ["🔥","🥰","👍","🎉","😡","🎖"]
}
