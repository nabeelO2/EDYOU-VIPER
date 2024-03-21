//
// RosterItemTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit

class RosterItemTableViewCell: UITableViewCell {

    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor;
        }
        set {
            super.backgroundColor = newValue;
            avatarStatusView?.backgroundColor = newValue;
        }
    }
    
    @IBOutlet var avatarStatusView: AvatarStatusView! {
        didSet {
            self.avatarStatusView?.backgroundColor = self.backgroundColor;
        }
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    private var originalBackgroundColor: UIColor?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override var isHighlighted: Bool {
//        didSet {
//            avatarStatusView?.backgroundColor = isHighlighted ? UIColor.systemTintColor :  self.backgroundColor;
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if originalBackgroundColor == nil {
            originalBackgroundColor = self.backgroundColor;
            if originalBackgroundColor == nil {
                self.backgroundColor = UIColor.systemBackground;
            }
        }
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = selected ? UIColor.lightGray : self.originalBackgroundColor;
            }
        } else {
            self.backgroundColor = selected ? UIColor.lightGray : originalBackgroundColor;
        }
    }
}
