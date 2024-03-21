//
//  PPTextPostCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import ActiveLabel
import TransitionButton

class PPTextPostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBOutlet weak var btnApprove: TransitionButton!
    @IBOutlet weak var btnDecline: TransitionButton!
    
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(_ data: Post?) {
        self.post = data
        endSkeltonAnimation()
        imgProfile.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = data?.user?.name?.completeName ?? "N/A"
        lblInstituteName.text = data?.user?.college ?? "N/A"
        lblPost.text = data?.formattedText

        lblPost.handleMentionTap { [weak self] tappedName in
            guard let self = self else { return }
            
            for u in (self.post?.tagFriendsProfile ?? []) {
                if let user = u {
                    let name = user.formattedUserName
                    if name == tappedName {
                        let controller = ProfileController(user: user)
                        let navC = self.viewContainingController()?.tabBarController?.navigationController ?? self.viewContainingController()?.navigationController
                        navC?.popToRootViewController(animated: false)

                        navC?.pushViewController(controller, animated: true)
                    }
                }
                
            }
        }
    }
    
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        lblPost.text = ""
        viewContainer.backgroundColor = .clear
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, lblPost, btnApprove, btnDecline]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        //viewContainer.backgroundColor = R.color.sub_title()?.withAlphaComponent(0.06)
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, lblPost, btnApprove, btnDecline]
        views.forEach { $0.stopSkelting() }
    }
    
}
