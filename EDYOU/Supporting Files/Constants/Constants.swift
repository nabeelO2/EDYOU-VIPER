//
//  Constants.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import UIKit
import MobileCoreServices

class Constants {
    //https://4e81-182-180-126-38.ngrok-free.app
    //https://api.dev.edyou.io
    #if DEBUG
    static var baseURL = "https://api.dev.edyou.io"
    static let socketUrl = "wss:api.dev.edyou.io/chat/v1/ws/room/chat?token="
    #else
    static var baseURL = "https://api.dev.edyou.io"
    static let socketUrl = "wss:api.dev.edyou.io/chat/v1/ws/room/chat?token="
    #endif
    static let realmThread = "com.edyou.realm.thread"
    static let livekitUrl = "http://livekit.chat.edyou.io/"
    static let eventCategories = [DataPickerItem<String>(title: "Beauty", data: "beauty"), DataPickerItem<String>(title: "Birthday", data: "birthday"), DataPickerItem<String>(title: "Breakfast", data: "breakfast"), DataPickerItem<String>(title: "Drinks", data: "drinks"), DataPickerItem<String>(title: "Hangout", data: "hangout"), DataPickerItem<String>(title: "Lunch / Dinner", data: "lunch / dinner"), DataPickerItem<String>(title: "🧑‍🏫 Special Occasion", data: "special occasion"), DataPickerItem<String>(title: "Sport / Activities", data: "sport / activities"), DataPickerItem<String>(title: "Work Meeting", data: "work meeting"), DataPickerItem<String>(title: "Other", data: "other")]
    
    static let videoMediaType: [String] = [kUTTypeMovie as String]
    static let imageMediaType: [String] = [kUTTypeImage as String]
}

typealias GradientColor = (start:UIColor,end:UIColor)

struct GradientShades {
    static var dictionary : [Int : GradientColor] = [
        1: (UIColor.init(hexString: "#FF6A69"),UIColor.init(hexString: "#FF6A69")),
        2: (UIColor.init(hexString: "#152EBF"),UIColor.init(hexString: "#F7D08D")),
        3: (UIColor.init(hexString: "#B294E3"),UIColor.init(hexString: "#3D059C")),
        4: (UIColor.init(hexString: "#09B765"),UIColor.init(hexString: "#C4FB03")),
        5: (UIColor.init(hexString: "#E88F6E"),UIColor.init(hexString: "#2681B4")),
        6: (UIColor.init(hexString: "#0A6D72"),UIColor.init(hexString: "#D4F7BB")),
        7: (UIColor.init(hexString: "#9BB4A4"),UIColor.init(hexString: "#523EBE")),
        8: (UIColor.init(hexString: "#C9F5F1"),UIColor.init(hexString: "#FDCB82")),
        9: (UIColor.init(hexString: "#D862B4"),UIColor.init(hexString: "#E89ACB")),
        10: (UIColor.init(hexString: "#FF6921"),UIColor.init(hexString: "#9FEBD0")),
    ]
    static func getRandom() -> GradientColor {
        let n = Int.random(in: 1...10)
        return dictionary[n] ?? (UIColor.init(hexString: "#FF6A69"),UIColor.init(hexString: "#FF6A69"))
    }
    static var getProfileGradient : GradientColor {
        return (R.color.home_start()!, R.color.home_end()!)
    }
}
