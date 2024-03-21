//
//  TextPostCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import ActiveLabel

class TextPostCell: UITableViewCell, PostCell {
    
    
    @IBOutlet weak var vContainerComment: UIView!
    @IBOutlet weak var vContainerReactions: UIView!
    @IBOutlet weak var profileVerifiedLogo: UIImageView!
    @IBOutlet weak var VContainerEmoji: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgArrowGroup: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var btnGroupName: UIButton!
    @IBOutlet weak var lblReaction: UILabel!
    @IBOutlet weak var lblThirdReaction: UILabel!
    @IBOutlet weak var lblSecondReaction: UILabel!
    @IBOutlet weak var vReactions: UIView!
    @IBOutlet weak var reactionStack: UIStackView!
    @IBOutlet weak var vStackEmoji: UIStackView!
    @IBOutlet weak var profileImageForGroup: UIImageView!
    @IBOutlet weak var btnMarkFavorite: UIButton!
    @IBOutlet weak var btnMarkImageView: UIImageView!
    var indexPath: IndexPath!
    weak var actionDelegate: PostCellActions?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vStackEmoji.isHidden = true
        self.bringSubviewToFront(btnMarkFavorite)
//        self.layoutIfNeeded()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func highlightEmojiInPanel(_ reaction: String) {
        self.vStackEmoji.arrangedSubviews.forEach { view in
            guard let buttonView = (view.viewWithTag(1)) as? UIButton else { return }
            let highlight = buttonView.titleLabel?.text == reaction
            buttonView.borderWidth = highlight ? 1 : 0
            buttonView.borderColor = highlight ?  R.color.home_end()! : R.color.background()!
            buttonView.backgroundColor = highlight ? R.color.reaction_background()! : UIColor.white
            buttonView.cornerRadius = highlight ? (buttonView.height / 2.0) : 0
        }
    }
        
    func addReaction(_ reaction: PostLike?, totalReactions: Int) { }
    
    func updatePostData(data: Post?) {
        self.post = data
        self.setReactions()
        self.highlightEmojiInPanel(data?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
    }
    
    func setData(_ data: Post?) {
        self.post = data
       
        endSkeltonAnimation()
        btnGroupName.isHidden = true
        profileImageForGroup.isHidden = true
        if let groupData = data?.groupInfo {
            lblName.text = groupData.groupName
            btnGroupName.isHidden = false
            profileImageForGroup.isHidden = false
            lblInstituteName.font = UIFont.systemFont(ofSize: 13, weight: .semibold)//R.font.sfProDisplaySemibold(size: 13)
            lblInstituteName.text = data?.user?.name?.completeName ?? "N/A"
            imgProfile.image = R.image.event_placeholder_square()
            imgProfile.setImage(url: groupData.groupIcon,placeholder: R.image.event_placeholder_square())
            profileImageForGroup.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        }
        else {
        imgProfile.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = data?.user?.name?.completeName ?? "N/A"
            lblInstituteName.text = data?.user?.college ?? "N/A"
//        if let y = data?.user?.education.first?.degreeEnd?.toDate?.stringValue(format: "yy", timeZone: .current) {
//            lblInstituteName.text = "\(data?.user?.education.first?.instituteName ?? "N/A"), \(y)"
//        }
            
            if let str = data?.user?.major_end_year?.toDate?.stringValue(format: "yyyy"){
                lblInstituteName.text = "\(data?.user?.college  ?? "N/A"), \(str)"
            }
        }
        lblPost.text = data?.formattedText
        lblLikes.text = "\(data?.totalLikes ?? 0)"
        lblComments.text = "\(data?.comments?.count ?? 0)"
        self.vReactions.isHidden = (self.post?.reactions?.count ?? 0) == 0
        self.setReactions()
        let date = data?.createdAt?.toDate
        lblDate.text = date?.timeAgoDisplay()
        
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
        
        self.btnMarkImageView.image = (self.post?.isFavourite ?? false) ? UIImage(named: "favourite_event_filled") : UIImage(named: "favourite_event")
        self.highlightEmojiInPanel(post?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
        profileVerifiedLogo.isHidden = data?.user?.isUserVerified ?? true
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        
        lblPost.text = ""
        imgArrowGroup.isHidden = true
        lblGroupName.isHidden = true
        profileVerifiedLogo.isHidden = true
        viewContainer.backgroundColor = .clear
        
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, lblDate, lblPost, imgLike, lblLikes, lblComments, VContainerEmoji, vContainerReactions, vContainerComment,btnMarkFavorite,profileImageForGroup]
        views.forEach { $0.startSkelting() }
        
    }
    
    func endSkeltonAnimation() {
        let views: [UIView] = [imgProfile, lblName, lblInstituteName, lblDate, lblPost, imgLike, lblLikes, lblComments,VContainerEmoji, vContainerReactions, vContainerComment,btnMarkFavorite,profileImageForGroup]
        views.forEach { $0.stopSkelting() }
    }
    
    @IBAction func actShowAllReactions(_ sender: UIButton) {
        guard let post = post?.postID else {
            return
        }
        self.actionDelegate?.showAllReactions(indexPath: indexPath, postId: post)
    }
    
    @IBAction func actShowReactionPanel(_ sender: UIButton) {
        self.vStackEmoji.isHidden.toggle()
        self.actionDelegate?.showReactionPanel(indexPath: indexPath, postId: self.post?.postID ?? "")
    }
    @IBAction func actTapEmoji(_ sender: UIButton) {
        self.actionDelegate?.tapOnReaction(indexPath: indexPath, reaction: sender.titleLabel?.text ?? "")
    }
    @IBAction func actAddComments(_ sender: UIButton) {
        self.actionDelegate?.tapOnComments(indexPath: indexPath, comment: sender.titleLabel?.text)
    }

    @IBAction func actMarkFavorite(_ sender: UIButton) {
        guard let post = post?.postID else {
            return
        }
        self.actionDelegate?.manageFavorites(indexPath: indexPath, postId: post)
    }
}

// MARK: - Reactions Management
extension TextPostCell {
    private func setReactions() {
        self.setReactionText()
        self.vReactions.isHidden = (self.post?.reactions?.count ?? 0) == 0
        self.resetReactions()
        for (index,reaction) in (post?.reactions ?? []).enumerated() {
            if index == self.reactionStack.arrangedSubviews.count {
                return
            }
            guard let reactLabel = self.reactionStack.arrangedSubviews[index] as? UILabel else {
                return
            }
            reactLabel.text = reaction.likeEmotion?.decodeEmoji()
            reactLabel.isHidden = false
        }
    }
    private func setReactionText() {
        let totalLikes = self.post?.totalLikes ?? 0
        if totalLikes == 1 && self.post?.myReaction != nil {
            lblLikes.text = "You reacted"
        }
        if totalLikes > 1 && self.post?.myReaction != nil {
            lblLikes.text = "You and \(totalLikes - 1) other"
        }
        if totalLikes >= 1 && self.post?.myReaction == nil {
            lblLikes.text = "\(totalLikes)"
        }
    }
    
    private func resetReactions() {
        self.reactionStack.arrangedSubviews.forEach { view in
            view.isHidden = true
        }
    }
}
