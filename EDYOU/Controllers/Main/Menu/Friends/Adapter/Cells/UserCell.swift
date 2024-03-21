//
//  UserCell.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

protocol UserCellActionsDelegate: AnyObject {
    func sendMessageToUser(user: User)
    func callToUser(user: User)
    func unblockUser(user: User)
}
class UserCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var viewCross: UIView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewCall: UIView!
    @IBOutlet weak var stkButtons: UIStackView!
    @IBOutlet weak var viewCheckMark: UIView!
    @IBOutlet weak var imgCheckMark: UIImageView!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var imgCall: UIImageView!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var viewOnlineStatus: UIView!
    @IBOutlet weak var profileVerifiedLogo: UIImageView!

    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var btnMore: UIButton!
    weak var delegate : UserCellActionsDelegate?
    var user = User()
    
//    checkmark.square.fill
    
    override func awakeFromNib() {
        super.awakeFromNib()
       btnConfirm.layer.cornerRadius =  btnConfirm.frame.size.height/2.0
       btnCross.layer.cornerRadius =  btnCross.frame.size.height/2.0

    }
    
    override func prepareForReuse() {
        imgProfile.image = R.image.profile_image_dummy()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapSendMessage(_ sender: UIButton) {
        delegate?.sendMessageToUser(user: self.user)
    }
    @IBAction func didTapCallUser(_ sender: UIButton) {
        delegate?.callToUser(user: self.user)
    }
    
    @IBAction func unBlockUser(_ sender: UIButton) {
        delegate?.unblockUser(user: self.user)
    }
    
    func setData(_ group: Group) {
        endSkeltonAnimation()
        imgProfile.setImage(url: group.groupIcon, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = group.groupName ?? "--"
        lblInstituteName.text = group.purpose
    }
    
    func disableAllOptions() {
        self.btnConfirm.isHidden = true
        self.viewCross.isHidden = true
        self.viewCall.isHidden = true
        self.viewMessage.isHidden = true
        self.viewCheckMark.isHidden = true
    }
    
    
    
    func setData(_ user: User) {
        self.user = user
        endSkeltonAnimation()
        
        imgProfile.setImage(url: user.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = user.name?.completeName ?? "--"
        lblInstituteName.text = user.college ?? "--"
        profileVerifiedLogo.isHidden = user.isUserVerified
        let status = user.friendrequeststatus
    }
    
    func hideSktButtonsSubViews() {
        for v in stkButtons.subviews {
            v.isHidden = true
        }
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, btnConfirm, viewCross, viewMessage, viewCall, profileVerifiedLogo]
        views.forEach { $0.startSkelting() }
    }
    func endSkeltonAnimation() {
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, btnConfirm, viewCross, viewMessage, viewCall, profileVerifiedLogo]
        views.forEach { $0.stopSkelting() }
    }
    
    func startLoading() {
        viewLoader.isHidden = false
    }
    func stopLoading() {
        viewLoader.isHidden = true
    }
    
}
