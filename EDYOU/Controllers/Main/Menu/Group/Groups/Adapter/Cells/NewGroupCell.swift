//
//  NewGroupCell.swift
//  EDYOU
//
//  Created by Aksa on 18/08/2022.
//

import UIKit

class NewGroupCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var lblOtherMembers: UILabel!
    @IBOutlet weak var joinGroupView: UIView!
    @IBOutlet weak var joinedGroupActivityView: UIView!
    @IBOutlet weak var btnJoinGroup: UIButton!
    @IBOutlet weak var btnViewGroupActivity: UIButton!
    @IBOutlet weak var membersImagesStackView: UIStackView!
    @IBOutlet weak var imgUser1: UIImageView!
    @IBOutlet weak var imgUser2: UIImageView!
    @IBOutlet weak var imgUser3: UIImageView!
    @IBOutlet weak var imgUser4: UIImageView!
    @IBOutlet weak var privateGroupIndicatorView: UIView!
    @IBOutlet weak var moreMenuBtn: UIButton!
    @IBOutlet weak var groupActivityStackView: UIStackView!
    @IBOutlet weak var separatorBottomConsraintWithView: NSLayoutConstraint!
    @IBOutlet weak var topConsraintWithView: NSLayoutConstraint!
    
    var placeholderPicture: UIImage {
        return R.image.profile_image_dummy()!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(_ group: Group, forCreatePost: Bool = false) {
        endSkeltonAnimation()
        
        if (forCreatePost) {
            moreMenuBtn.isHidden = true
            groupActivityStackView.isHidden = true
            separatorBottomConsraintWithView.constant = 0
        }
        
        lblTitle.text = group.groupName ?? "N/A"
        lblDescription.text = group.groupDescription ?? "N/A"
        
        if (group.privacy == "public") {
            privateGroupIndicatorView.isHidden = true
        } else {
            privateGroupIndicatorView.isHidden = false
        }
        
        if group.groupIcon != nil
        {
            imgGroup.setImage(url: group.groupIcon, placeholder: UIImage(named: "group_placeholder"))
        }
        else
        {
            imgGroup.image = R.image.event_placeholder_square()
        }
       
        
        joinedGroupActivityView.isHidden = false
        joinGroupView.isHidden = true
        membersImagesStackView.isHidden = true
        imgUser1.isHidden = true
        imgUser2.isHidden = true
        imgUser3.isHidden = true
        imgUser4.isHidden = true
       
        if ((group.groupMembers?.count ?? 0) > 0) {
            membersImagesStackView.isHidden = false
            
            if let count = group.groupMembers?.count {
                if (count == 0) {
                    membersImagesStackView.isHidden = true
                } else if (count == 1) {
                    imgUser1.isHidden = false
                    print(group.groupMembers?[0].profileImage)
                    imgUser1.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    lblOtherMembers.text = ""
                } else if (count == 2) {
                    imgUser1.isHidden = false
                    imgUser1.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    imgUser2.isHidden = false
                    imgUser2.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    lblOtherMembers.text = ""
                } else if (count == 3) {
                    imgUser1.isHidden = false
                    imgUser1.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    imgUser2.isHidden = false
                    imgUser2.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    imgUser3.isHidden = false
                    imgUser3.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                    lblOtherMembers.text = ""
                } else if (count >= 4) {
                    imgUser1.isHidden = false
                    imgUser1.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    imgUser2.isHidden = false
                    imgUser2.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    imgUser3.isHidden = false
                    imgUser3.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                    imgUser4.isHidden = false
                    imgUser4.setImage(url: group.groupMembers?[3].profileImage, placeholder: placeholderPicture)
                    if (count > 4)
                    {
                        let m = (count - 4) <= 1 ? "member" : "members"
                        lblOtherMembers.text = "& \(count - 4) other \(m)"
                    }
                    else
                    {
                        lblOtherMembers.text = ""
                    }
                  
                } else {
                    lblOtherMembers.text = ""
                }
            }
        }
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
//        imgGroup.isHidden = true
        lblTitle.isHidden = true
//        lblDescription.isHidden = true
        membersImagesStackView.isHidden = true
        lblOtherMembers.isHidden = true
        groupActivityStackView.isHidden = true
        privateGroupIndicatorView.isHidden = true
        moreMenuBtn.isHidden = true
        let views: [UIView] = [moreMenuBtn,imgGroup, lblTitle, lblDescription, membersImagesStackView, privateGroupIndicatorView, lblOtherMembers, groupActivityStackView]
        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
        imgGroup.isHidden = false
        lblTitle.isHidden = false
        lblDescription.isHidden = false
        membersImagesStackView.isHidden = false
        lblOtherMembers.isHidden = false
        groupActivityStackView.isHidden = false
        privateGroupIndicatorView.isHidden = false
        moreMenuBtn.isHidden = false
        let views: [UIView] = [moreMenuBtn, imgGroup, lblTitle, lblDescription, membersImagesStackView, privateGroupIndicatorView, lblOtherMembers, groupActivityStackView]
        views.forEach { $0.stopSkelting() }
    }
}
