//
// VCardAvatarEditCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit

class VCardAvatarEditCell: UITableViewCell {
    
    @IBOutlet var avatarView: AvatarView!;
    @IBOutlet var changeBtn: UIButton!;
     
    override func layoutSubviews() {
        self.changeBtn.isUserInteractionEnabled = false;
        super.layoutSubviews();
        updateCornerRadius();
    }
    
    func updateCornerRadius() {
        self.avatarView.layer.masksToBounds = true;
        self.avatarView.layer.cornerRadius = 100;
    }
    
    
}
