//
//  PostDetailsImageCell.swift
//  EDYOU
//
//  Created by  Mac on 08/09/2021.
//

import UIKit
import ActiveLabel

class PostDetailsImageCell: UITableViewCell, PostDetailCellUpdateProtocol {
    var imgComment: UIImageView!
    var imgShare: UIImageView!
    
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblTextLikes: UILabel!
    @IBOutlet weak var lblTextComments: UILabel!
    @IBOutlet weak var lblTextShares: UILabel!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnTotalLikes: UIButton!
    @IBOutlet weak var vStackEmoji: UIStackView!
    @IBOutlet weak var lblReaction: UILabel!
    @IBOutlet weak var lblThirdReaction: UILabel!
    @IBOutlet weak var lblSecondReaction: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionHeight : NSLayoutConstraint!
    
    @IBOutlet weak var vReactions: UIView!
    @IBOutlet weak var reactionStack: UIStackView!
    var media = [PostMedia]()
    var post: Post?
    var indexPath: IndexPath!
    weak var actionDelegate: PostCellActions?
    @IBOutlet weak var btnMarkFavorite: UIButton!
    @IBOutlet weak var btnMarkImageView: UIImageView!
    
    var heightCV : [CGFloat] = []
    
    var reloadTblV : (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        self.bringSubviewToFront(btnMarkFavorite)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        pageControl.numberOfPages = 10
        pageControl.currentPage = 0
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
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
    func updatePostData(data: Post?) {
        self.post = data
        self.setReactions()
        self.highlightEmojiInPanel(data?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
    }
    
    func setData(_ data: Post?) {
        self.post = data
        lblPost.text = data?.formattedText
        lblLikes.text = "\(data?.totalLikes ?? 0)"
        lblComments.text = "\(data?.comments?.count ?? 0)"
        lblTextLikes.text = data?.totalLikes == 1 ? "Reaction" : "Reactions"
        lblTextComments.text = data?.comments?.count == 1 ? "Comment" : "Comments"
       
        self.setReactions()

        media = post?.medias ?? []
        media.forEach { _ in
            self.heightCV.append(0)
        }
        
        pageControl.numberOfPages = media.count
        pageControl.isHidden = media.count <= 1
        collectionView.reloadData()
        
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
        self.setReactions()
        self.highlightEmojiInPanel(post?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
        self.btnMarkImageView.image = (self.post?.isFavourite ?? false) ? UIImage(named: "favourite_event_filled") : UIImage(named: "favourite_event")

    }
    
    
    @objc func didTapPlayButton(_ sender: UIButton) {
        if let m = media.object(at: sender.tag), m.type == .video {
            self.viewContainingController()?.playVideo(url: m.url)
        }
    }
    
    @IBAction func actShowAllReactions(_ sender: UIButton) {
        guard let post = post?.postID else {
            return
        }
        self.actionDelegate?.showAllReactions(indexPath: indexPath, postId: post)
    }
    
    @IBAction func actMarkFavorite(_ sender: UIButton) {
        guard let post = post?.postID else {
            return
        }
        self.actionDelegate?.manageFavorites(indexPath: indexPath, postId: post)
    }
    
    @IBAction func actTapEmoji(_ sender: UIButton) {
        self.actionDelegate?.tapOnReaction(indexPath: indexPath, reaction: sender.titleLabel?.text ?? "")
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

extension PostDetailsImageCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell
        
        cell.loadData(data: media[indexPath.row], indexPath: indexPath)

        if media[indexPath.row].type == .image {

            cell.imgPost.setImage(url: media[indexPath.row].url, placeholder: R.image.imagePlaceholder())
        } else {
            cell.imgPost.image = nil

           // cell.playVideo(url: media[indexPath.row].url)
        }
        
        
//        cell.btnPlay.tag = indexPath.row
//        cell.btnPlay.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
            pageControl.currentPage = pageNumber
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if let cell = cell as? PostImageCell{
            if heightCV[indexPath.row] == 0{
                
//                let dimenstion = post?.medias.first?.url.getDimenstions()
//                let w = Double(dimenstion?.0 ?? 0)
//                let h = Double(dimenstion?.1 ?? 0)
//                print(dimenstion)
//                let ratio = h > 0 ? Double(h / w) : Double(1.1)
//                let width = Double(collectionView.frame.width)
//                var height =  width * ratio
//                if height == 0 {
//                    height = width * 1.1
//                }
                
//                cell.reloadHeight = { height in
////                    if self.heightCV[indexPath.row] == 0 {
//                        self.heightCV[indexPath.row] = height
//                        self.collectionHeight.constant = height
////
//                        self.collectionView.reloadData()
////
//                        self.reloadTblV?()
////
//                    cell.reloadHeight = nil
////                    }
//
//
//                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                cell.play()
            })
        }
        
    }
}

extension PostDetailsImageCell {
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
