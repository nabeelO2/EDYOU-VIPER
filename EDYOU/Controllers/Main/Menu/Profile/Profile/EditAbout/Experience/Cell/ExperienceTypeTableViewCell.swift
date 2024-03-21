//
//  ExperienceTypeTableViewCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 07/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class ExperienceTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(type: JobType, checked: Bool) {
        self.imgCheck.isHidden = !checked
        self.lblTitle.text = type.description
    }
    
    func setData(option: String, checked: Bool, optionhasIcons: Bool = false) {
        self.imgCheck.isHidden = !checked
        self.lblTitle.text = option
        titleImage.isHidden = !optionhasIcons
        
        if (optionhasIcons) {
            titleImage.image = getTitleImage(title: option)
        }
    }
    
    func setData(titleLabel: String, checked: Bool, optionhasIcons: Bool = false, hasFarwardArrow: Bool = false) {
        self.lblTitle.text = titleLabel
        self.lblTitle.font = UIFont(name: "CircularStd-Book", size: 14)
        self.imgCheck.isHidden = !checked
        if (hasFarwardArrow) {
            self.imgCheck.isHidden = false
            self.imgCheck.image = R.image.arrowRight()!
        }
        titleImage.isHidden = !optionhasIcons

    }
    
    func getTitleImage(title: String) -> UIImage {
        switch title {
            
        case "Add to Favorite", "Remove From Favorite":
            return R.image.save()!
            
        case "UnFollow":
            return R.image.unfollow()!
            
        case "Hide this Post", "Delete":
            return R.image.hidepost()!
            
        case "Report":
            return R.image.report()!
            
        case "Block":
            return R.image.hidepost()!
            
        case "Camera":
            return R.image.cameraIconGreen()!
            
        case "Gallery":
            return R.image.cameraIconGreen()!
            
        case "View Profile":
            return UIImage(named: "view-profile")!
    
        default:
            return R.image.friendsGreen()!
        }
    }
    
    
}
