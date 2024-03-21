//
//  CommentCell.swift
//  EDYOU
//
//  Created by  Mac on 21/09/2021.
//

import UIKit
import ActiveLabel

protocol CommentActionProtocol {
    func moreOptionTappedForComment(comment: Comment)
    func profileTappedForComment(comment: Comment)
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var verticalSeperator: UIView!
    @IBOutlet weak var verticalLineTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblComment: ActiveLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var reactionStack: UIStackView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var vSeperator: UIView!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var vReactionPanel: UIView!
    var comment: Comment!
    var actionDelegate: CommentActionProtocol?
    
    @IBOutlet weak var constHeaderTrailing: NSLayoutConstraint!
    @IBOutlet weak var constStackLeading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func actProfileBtn(_ sender: UIButton) {
        guard let comment = comment else { return }
        self.actionDelegate?.profileTappedForComment(comment: comment)
    }
    
    @IBAction func actTapMoreOption(_ sender: UIButton) {
        guard let comment = comment else { return }
        self.actionDelegate?.moreOptionTappedForComment(comment: comment)
    }
    
    func setData(_ comment: Comment, actionDelegate: CommentActionProtocol) {
        self.actionDelegate = actionDelegate
        setupCommentInformation(comment)
        self.setReactions()
        self.vSeperator.isHidden = !comment.showSeperator
        if comment.commentType == .parent {
            self.verticalSeperator.isHidden = comment.childComments.count == 0
        }
        self.setupConstrainst()
        lblComment.handleMentionTap { [weak self] tappedName in
            guard let self = self else { return }
            
            for u in (self.comment?.tagFriendsProfile ?? []) {
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
    
    func setDataForReels(_ comment: Comment) {
        self.setupCommentInformation(comment)
        self.vSeperator.isHidden = false
        self.setupConstrainst()
        self.vReactionPanel.isHidden = true
    }
    
    fileprivate func setupCommentInformation(_ comment: Comment) {
        self.comment = comment
        imgProfile.setImage(url: comment.owner?.profileImage, placeholder: R.image.profile_image_dummy())
        lblName.text = comment.owner?.name?.completeName
        lblComment.text = comment.formattedText
        lblTime.text = comment.createdAt?.toDate?.timeAgoDisplay()
        self.lblInstituteName.text = comment.owner?.instituteName
    }
}

extension CommentCell {
    private func setReactions() {
        self.reactionStack.isHidden = (self.comment?.commentLikes?.count ?? 0) == 0
        self.resetReactions()
        for (index,reaction) in (self.comment?.commentLikes ?? []).enumerated() {
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
    
    private func resetReactions() {
        self.reactionStack.arrangedSubviews.forEach { view in
            view.isHidden = true
        }
    }
    func setupConstrainst() {
        guard let comment = comment else { return }
        if comment.commentType == .parent {
            self.constHeaderTrailing.constant = 16
            self.constStackLeading.constant = 0
            self.verticalLineTopConstraint.constant = 14
        }
        else {
            self.constHeaderTrailing.constant = 62
            self.constStackLeading.constant = 50
            self.verticalLineTopConstraint.constant = 0
        }
        self.layoutIfNeeded()
    }
}
