//
// AppStoryboard.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

enum AppStoryboard: String {
    case Chat = "Chat"
    case Groupchat = "Groupchat"
    case Settings = "Settings"
    case Account = "Account"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main);
    }
    
    func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
        return instance.instantiateViewController(withIdentifier: identifier);
    }
    
    func instantiateViewController<T: UIViewController>(ofClass: T.Type) -> T {
        let storyboardID = ofClass.storyboardID;
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T;
    }
}

extension UIViewController {
    
    class var storyboardID: String {
        return "\(self)";
    }
 
    static func instantiate(fromAppStoryboard: AppStoryboard) -> Self {
        return fromAppStoryboard.instantiateViewController(ofClass: self);
    }
    
}
