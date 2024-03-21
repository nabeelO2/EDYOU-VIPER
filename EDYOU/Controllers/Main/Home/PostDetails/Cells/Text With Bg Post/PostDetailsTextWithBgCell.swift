//
//  TextWithBgPostCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import ActiveLabel

protocol PostDetailCellUpdateProtocol {
    func updatePostData(data: Post?)
}

class PostDetailsTextWithBgCell: UITableViewCell, PostDetailCellUpdateProtocol {
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblShares: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var lblTextLikes: UILabel!
    @IBOutlet weak var lblTextComments: UILabel!
    @IBOutlet weak var lblTextShares: UILabel!
    @IBOutlet weak var lblReaction: UILabel!
    @IBOutlet weak var lblThirdReaction: UILabel!
    @IBOutlet weak var lblSecondReaction: UILabel!
    @IBOutlet weak var vStackEmoji: UIStackView!
    @IBOutlet weak var vReactions: UIView!
    @IBOutlet weak var reactionStack: UIStackView!
    @IBOutlet weak var btnMarkImageView: UIImageView!

    @IBOutlet weak var btnMarkFavorite: UIButton!
    var indexPath: IndexPath!
    weak var actionDelegate: PostCellActions?
    
    
    
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(btnMarkFavorite)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func actMarkFavorite(_ sender: UIButton) {
        self.actionDelegate?.manageFavorites(indexPath: indexPath, postId: self.post?.postID ?? "")
    }
    
    func addReaction(_ reaction: PostLike?, totalReactions: Int) {
//        lblLikes.text = "\(totalReactions)"
//        lblTextLikes.text = totalReactions == 1 ? "Reaction" : "Reactions"
//        if let reaction = reaction {
//            imgLike.isHidden = true
//            lblReaction.isHidden = false
//            lblReaction.text = reaction.likeEmotion?.decodeEmoji()
//        } else {
//            imgLike.isHidden = false
//            lblReaction.isHidden = true
//        }
    }
    func setData(_ data: Post?) {
        self.post = data
        lblPost.text = data?.formattedText
        lblLikes.text = "\(data?.totalLikes ?? 0)"
        lblComments.text = "\(data?.comments?.count ?? 0)"
//        lblTextLikes.text = data?.totalLikes == 1 ? "Like" : "Likes"
        lblTextComments.text = data?.comments?.count == 1 ? "Comment" : "Comments"
//        imgLike.tintColor = post?.isReacted == true ? R.color.like_enable() : R.color.like_disable()
        
        gradientView.colors = [UIColor(red: 70 / 255, green: 79 / 255, blue: 245 / 255, alpha: 1),
                               UIColor(red: 151 / 255, green: 76 / 255, blue: 214 / 255, alpha: 1),
                               UIColor(red: 231 / 255, green: 96 / 255, blue: 196 / 255, alpha: 1)
        ]
        
        let colors = data?.backgroundColors?.components(separatedBy: ", ").colors ?? []
        if let points = data?.backgroundColorsPosition?.components(separatedBy: "), (") {
            if points.count >= 2 {
                let p1 = points[0].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                let p2 = points[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                
                gradientView.colors = colors
                gradientView.startPoint = CGPoint(x: Double(p1.first ?? "0") ?? 0, y: Double(p1.last ?? "0") ?? 0)
                gradientView.endPoint = CGPoint(x: Double(p2.first ?? "0") ?? 0, y: Double(p2.last ?? "0") ?? 0)
                
            }
        }
        gradientView.updatePoints()
        
        
        
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
        
//        if let reaction = post?.myReaction {
//            imgLike.isHidden = true
//            lblReaction.isHidden = false
//            lblReaction.text = reaction.likeEmotion?.decodeEmoji()
//        } else {
//            imgLike.isHidden = false
//            lblReaction.isHidden = true
//        }
        self.btnMarkImageView.image = (self.post?.isFavourite ?? false) ? UIImage(named: "favourite_event_filled") : UIImage(named: "favourite_event")

        self.setReactions()
        self.highlightEmojiInPanel(post?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
        
    }
    
    @IBAction func actShowAllReactions(_ sender: UIButton) {
        guard let post = post?.postID else {
            return
        }
        self.actionDelegate?.showAllReactions(indexPath: indexPath, postId: post)
    }
    
    @IBAction func actTapEmoji(_ sender: UIButton) {
        self.actionDelegate?.tapOnReaction(indexPath: indexPath, reaction: sender.titleLabel?.text ?? "")
    }
    
    func updatePostData(data: Post?) {
        self.post = data
        self.setReactions()
        self.highlightEmojiInPanel(data?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
    }
    
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
}
