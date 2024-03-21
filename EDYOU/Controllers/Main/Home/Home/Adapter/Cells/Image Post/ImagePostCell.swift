//
//  ImagePostCell.swift
//  EDYOU
//
//  Created by  Mac on 08/09/2021.
//

import UIKit
import ActiveLabel
import AVKit
import AVFoundation

class ImagePostCell: UITableViewCell, PostCell, UIScrollViewDelegate {
    @IBOutlet weak var vContainerReaction: UIView!
    @IBOutlet weak var profileVerifiedLogo: UIImageView!
    @IBOutlet weak var vContainerEmoji: UIView!
    @IBOutlet weak var vContainerComment: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblPost: ActiveLabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var lblComments: UILabel!
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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewGradient: GradientView!
    @IBOutlet weak var vReactions: UIView!
    @IBOutlet weak var reactionStack: UIStackView!
    @IBOutlet weak var vStackEmoji: UIStackView!
    @IBOutlet weak var profileImageForGroup: UIImageView!
    @IBOutlet weak var btnMarkImageView: UIImageView!
    @IBOutlet weak var collectionVH : NSLayoutConstraint!
    @IBOutlet weak var collectionVW : NSLayoutConstraint!
    var media = [PostMedia]()
    var post: Post?
    var indexPath: IndexPath!
    @IBOutlet weak var btnMarkFavorite: UIButton!
    weak var actionDelegate: PostCellActions?
    
    var avQueuePlayer   : AVQueuePlayer?
    var avPlayerLayer   : AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(btnMarkFavorite)
        configure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        viewGradient.colors = [UIColor.black.withAlphaComponent(0.4), UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0)]
        viewGradient.startPoint = CGPoint(x: 0, y: 1)
        viewGradient.endPoint = CGPoint(x: 0, y: 0)
        self.vStackEmoji.isHidden = true
    }
    
    func configure() {
        pageControl.numberOfPages = 10
        pageControl.currentPage = 0
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.register(PostVideoCell.nib, forCellWithReuseIdentifier: PostVideoCell.identifier)

        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func addReaction(_ reaction: PostLike?, totalReactions: Int) {
    }
    
    func updatePostData(data: Post?) {
        print("reaction \(data?.myReaction?.likeEmotion?.decodeEmoji() ?? "")")
        self.post = data
        self.setReactions()
        self.highlightEmojiInPanel(data?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
    }
    
    func setData(_ data: Post?) {
        self.post = data
       
        btnGroupName.isHidden = true
        profileImageForGroup.isHidden = true
        
        if let groupData = data?.groupInfo {
            lblName.text = groupData.groupName
            btnGroupName.isHidden = false
            profileImageForGroup.isHidden = false
            lblInstituteName.font = UIFont.systemFont(ofSize: 12)//R.font.sfProDisplayRegular(size: 12)
            lblInstituteName.text = data?.user?.name?.completeName ?? "N/A"
            imgProfile.image = R.image.event_placeholder_square()
            imgProfile.setImage(url: groupData.groupIcon,placeholder: R.image.event_placeholder_square())
            
            profileImageForGroup.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
            
        } else {
            imgProfile.setImage(url: data?.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
            lblName.text = data?.user?.name?.completeName ?? "N/A"
            lblInstituteName.text = data?.user?.college ?? "N/A"
            let education = data?.user?.education
//            let endDate =
            
            if let str = data?.user?.major_end_year?.toDate?.stringValue(format: "yyyy"){
                lblInstituteName.text = "\(data?.user?.college  ?? "N/A"), \(str)"
            }
            
            
//            if let y = data?.user?.education.first?.degreeEnd?.toDate?.stringValue(format: "yy", timeZone: .current) {
//                lblInstituteName.text = "\(data?.user?.education.first?.instituteName  ?? "N/A"), \(y)"
//            }
        }
        lblPost.text = data?.formattedText
        let date = data?.createdAt?.toDate
        lblDate.text = date?.timeAgoDisplay()
        lblComments.text = "\(data?.comments?.count ?? 0)"
        media = post?.medias ?? []
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
        self.btnMarkImageView.image = (self.post?.isFavourite ?? false) ? UIImage(named: "favourite_event_filled") : UIImage(named: "favourite_event")
        
        self.setReactions()
        self.highlightEmojiInPanel(post?.myReaction?.likeEmotion?.decodeEmoji() ?? "")
        profileVerifiedLogo.isHidden = data?.user?.isUserVerified ?? true

    }
    
    @objc func didTapPlayButton(_ sender: UIButton) {
        if let m = media.object(at: sender.tag), m.type == .video {
            self.viewContainingController()?.playVideo(url: m.url)
        }
    }
    
    
    
    
    @IBAction func actShowAllEmoji(_ sender: UIButton) {
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
    deinit {
        print("deinit image post  cell")
    }
    func setCVDimenstion(_ height : CGFloat,_ width : CGFloat){
        self.collectionVH.constant = height
        self.collectionVH.constant = width
    }
}

extension ImagePostCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size//CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
         let cellData = media[indexPath.row]
        if (cellData.type == .image) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell

            cell.loadData(data: media[indexPath.row], indexPath: indexPath)
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostVideoCell.identifier, for: indexPath) as! PostVideoCell
            cell.loadData(data: cellData, indexPath: indexPath)
    
            return cell

        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PostVideoCell{
            
            cell.pause()
            cell.mute()
            detailcSreen()
            
        }
        else{
            detailcSreen()
        }
        func detailcSreen(){
            if let post = self.post {
                let controller = PostDetailsController(post: post, prefilledComment: nil)
                let navC = self.viewContainingController()?.tabBarController?.navigationController ?? self.viewContainingController()?.navigationController
                navC?.pushViewController(controller, animated: true)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
            pageControl.currentPage = pageNumber
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < media.count{
            let cellData = media[indexPath.row]
            if (cellData.type == .video) {
                if let videoCell = cell as? PostVideoCell {
                    
                    videoCell.player?.pause()
                    
                }
            }

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let cellData = media[indexPath.row]
        if (cellData.type == .video) {
           
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let videoCell = cell as? PostVideoCell else { return }
//        let cellData = media[indexPath.row]
//        if (cellData.type == .video) {
//            videoCell.viewVideo.play()
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let videoCell = cell as? PostVideoCell else { return }
//        let cellData = media[indexPath.row]
//        if (cellData.type == .video) {
//            videoCell.viewVideo.pause()
//        }
//    }
//    
//    // TODO: write logic to stop the video before it begins scrolling
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//       let cells = collectionView.visibleCells.compactMap({ $0 as? PostVideoCell })
//       cells.forEach { videoCell in
//
//           //if videoCell.isPlaying {
//           videoCell.viewVideo.togglePlayback()
//           //}
//       }
//    }
//
//    // TODO: write logic to start the video after it ends scrolling
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//       guard !decelerate else { return }
//       let cells = collectionView.visibleCells.compactMap({ $0 as? PostVideoCell })
//       cells.forEach  { videoCell in
//
//           videoCell.viewVideo.play()
//
//       }
//    }
//
//    // TODO: write logic to start the video after it ends scrolling (programmatically)
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let cells = collectionView.visibleCells.compactMap({ $0 as? PostVideoCell })
//        cells.forEach { videoCell in
//           // TODO: write logic to start the video after it ends scrolling
//            videoCell.viewVideo.play()
//       }
//    }
}

// MARK: - Reaction Management
extension ImagePostCell {
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
