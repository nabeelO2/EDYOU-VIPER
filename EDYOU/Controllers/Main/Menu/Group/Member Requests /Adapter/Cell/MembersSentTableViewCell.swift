//
//  MembersSentTableViewCell.swift
//  EDYOU
//
//  Created by admin on 28/09/2022.
//

import UIKit

class MembersSentTableViewCell: UITableViewCell {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var userCurrentStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(_ user: User) {
        endSkeltonAnimation()
        self.seperatorView.isHidden = false
        imgProfile.setImage(url: user.profileImage, placeholder : R.image.profileImagePlaceHolder())
        lblName.text = user.name?.completeName ?? "--"
        lblInstituteName.text = user.college ?? "--"
        if let groupMemberStatus = user.groupMemberStatus {
            let memberStatus = GroupMemberStatus(rawValue: groupMemberStatus ) ?? .waiting_for_admin_approval
            switch memberStatus {
            case .waiting_for_admin_approval, .waiting_for_my_approval:
                self.userCurrentStatus.text = "Pending"
                self.userCurrentStatus.textColor = UIColor(hexString: "#F2A43A")
            case .joined_via_invite, .joined_by_me:
                self.userCurrentStatus.text = "Accepted"
                self.userCurrentStatus.textColor = UIColor(hexString: "#53B36E")
            case .rejected_by_admin:
                self.userCurrentStatus.text = "Rejected"
                self.userCurrentStatus.textColor = UIColor(hexString: "#E83B41")
            case .defaultState:
                break
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func endSkeltonAnimation() {
        let views: [UIView] = [imgProfile, lblName, lblInstituteName]
        views.forEach { $0.stopSkelting() }
    }
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        
        let views: [UIView] = [imgProfile, lblName, lblInstituteName]
        views.forEach { $0.startSkelting() }
        
        
    }
    
}
