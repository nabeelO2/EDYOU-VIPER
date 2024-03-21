//
//  ReelsCollectionViewCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 11/08/2022.
//

import UIKit
import AVFoundation

protocol ReelsCollectionViewActions {
    func likeAndDislikeReels(reel: Reels, index: IndexPath)
    func showReelsComments(reel: Reels)
}

class ReelsCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var lblMusicInfo: UILabel!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUniversity: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var stackMusic: UIStackView!
    // MARK: - Private
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var delegate: ReelsCollectionViewActions!
    private var reels: Reels!
    // MARK: - Public
    var index: IndexPath!
    override var description: String {
        return reels.description ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
//        self.resetAvPlayer()
    }
    
    func resetAvPlayer() {
        self.removeLoopObserver()
        avPlayer?.pause()
    }
    
    func playVideoFromStart() -> AVPlayer? {
        self.loopVideo()
        avPlayer?.seek(to: .zero)
        avPlayer?.play()
        return avPlayer
    }
    
    
    func setData(data: Reels, index: IndexPath, action: ReelsCollectionViewActions) {
        self.reels = data
        self.index = index
        self.delegate = action
        self.lblUsername.text = data.uploaderPublicProfile?.name?.completeName
        self.lblUniversity.text = data.uploaderPublicProfile?.instituteName
        self.imgProfile.setImage(url: data.uploaderPublicProfile?.profileImage, placeholder: R.image.profileImagePlaceHolder()!)
        self.lblComments.text = "\(data.comments?.count ?? 0)"
        self.lblCaption.text = data.description
        self.lblCaption.isHidden = data.description?.isEmpty ?? true
        self.stackMusic.isHidden = data.audioId == nil
        self.manageLikeDislike(reel: data)
        self.prepareVideo()
    }
    
    func manageLikeDislike(reel: Reels) {
        self.lblLikeCount.text = "\(reel.likes?.count ?? 0)"
        self.imgLike.image = reel.isLikedByMe ? R.image.ic_like_me()! : R.image.ic_emoji_count()!
    }
    
    private func prepareVideo() {
        self.playerView.layoutIfNeeded()
        guard let videoURL = self.reels.url, let url = URL(string: videoURL) else {
            return
        }
//        let cachingItem = CachingPlayerItem.init(url: url)
//        cachingItem.download()
        avPlayer?.automaticallyWaitsToMinimizeStalling = true
        avPlayer = AVPlayer(url: url) //AVPlayer(playerItem: CachingPlayerItem.init(url: url))
        let avPlayerView = AVPlayerLayer(player: avPlayer)
        avPlayerView.frame = self.playerView.bounds
        avPlayerView.videoGravity = .resizeAspectFill
        self.playerView.layer.addSublayer(avPlayerView)
        self.avPlayerLayer = avPlayerView
    }
    
    func loopVideo() {
        self.removeLoopObserver()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem, queue: nil) { [weak self] notification in
            self?.avPlayer?.seek(to: .zero)
            self?.avPlayer?.play()
        }
    }
    func removeLoopObserver() {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    @IBAction func actReelLike(_ sender: UIButton) {
        self.delegate.likeAndDislikeReels(reel: self.reels, index: self.index)
    }
    
    @IBAction func actShowReelsComments(_ sender: UIButton) {
        self.delegate.showReelsComments(reel: self.reels)
    }
}
