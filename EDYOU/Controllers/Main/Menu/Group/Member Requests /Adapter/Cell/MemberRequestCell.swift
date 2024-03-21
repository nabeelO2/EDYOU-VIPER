//
//  UserCell.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit
import TransitionButton

class MemberRequestCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var btnApprove: TransitionButton!
    @IBOutlet weak var btnDecline: TransitionButton!
    @IBOutlet weak var stkButtons: UIStackView!
    @IBOutlet weak var seperatorView: UIView!
    
//    checkmark.square.fill
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
    }
    
    
    func setData(_ user: User) {
        endSkeltonAnimation()
        self.seperatorView.isHidden = false
        imgProfile.setImage(url: user.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = user.name?.completeName ?? "--"
        lblInstituteName.text = user.college ?? "--"
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, btnApprove, btnDecline]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, btnApprove, btnDecline]
        views.forEach { $0.stopSkelting() }
    }
    
}
