//
//  GroupTableCell.swift
//  EDYOU
//
//  Created by  Mac on 19/10/2021.
//

import UIKit

class GroupTableCell: UITableViewCell {

    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMembers: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var viewPrivacy: UIView!
    @IBOutlet weak var viewAcceptReject: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setData(_ group: Group) {
        endSkeltonAnimation()
        
        imgProfile.setImage(url: group.groupIcon, placeholderColor: R.color.image_placeholder())
        lblName.text = group.groupName ?? "N/A"
        let m = group.groupMembers?.count == 1 ? "Member" : "Members"
        lblMembers.text = "\(group.groupMembers?.count ?? 0) \(m)"
        lblPrivacy.text = "\((group.privacy ?? "Public").capitalized) group"
        //let isMember = group.groupMembers?.contains(where: { $0.userID == Cache.shared.user?.userID }
        viewDot.isHidden = true
        viewPrivacy.isHidden = true
        viewAcceptReject.isHidden = true
    }
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        viewDot.isHidden = true
        viewPrivacy.isHidden = true
        viewAcceptReject.isHidden = true
        let views: [UIView] = [imgProfile, lblName, lblMembers, lblPrivacy]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        viewDot.isHidden = false
        viewPrivacy.isHidden = false
        let views: [UIView] = [imgProfile, lblName, lblMembers, lblPrivacy]
        views.forEach { $0.stopSkelting() }
    }

    
    
}
