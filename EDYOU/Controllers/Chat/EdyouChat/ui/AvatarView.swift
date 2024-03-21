//
// AvatarStatusView.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class AvatarView: UIImageView {
    
    private var name: String? {
        didSet {
            if let parts = name?.uppercased().components(separatedBy: CharacterSet.letters.inverted) {
                let first = parts.first?.first;
                let last = parts.count > 1 ? parts.last?.first : nil;
                self.initials = (last == nil || first == nil) ? (first == nil ? nil : "\(first!)") : "\(first!)\(last!)";
            } else {
                self.initials = nil;
            }
            self.updateImage();
        }
    }
    
    var avatar: UIImage? {
        didSet {
            updateImage();
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = min(frame.width, frame.height) / 2;
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.layer.cornerRadius = min(frame.width, frame.height) / 2;
    }
//    override var image: UIImage? {
//        get {
//            return super.image;
//        }
//        set {
//            //if image != nil {
//            //    self.image = prepareInitialsAvatar();
//            //}
//            if newValue != nil {
//                super.image = newValue;
//            } else if let initials = self.initials {
//                super.image = prepareInitialsAvatar(for: initials);
//            } else {
//                super.image = nil;
//            }
//        }
//    }
    fileprivate(set) var initials: String?;
    
    private func updateImage() {
        if avatar != nil {
            // workaround to properly handle appearance
//            if self.avatar! == AvatarManager.instance.defaultGroupchatAvatar {
                self.image = self.avatar;
//            } else {
//                self.image = avatar?.square(max(self.frame.size.width, self.frame.size.height));
//            }
        } else if let initials = self.initials {
            self.image = self.prepareInitialsAvatar(for: initials);
        } else {
            self.image = AvatarManager.instance.defaultAvatar;
        }
    }
    
    func set(name: String?, avatar: UIImage?) {
        self.name = name;
        self.avatar = avatar;
        self.setNeedsDisplay();
    }
}
