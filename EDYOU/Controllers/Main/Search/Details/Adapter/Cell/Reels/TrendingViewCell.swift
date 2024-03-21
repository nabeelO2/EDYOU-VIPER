//
//  TrendingViewCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 24/10/2022.
//

import UIKit
import AVFoundation

class TrendingViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var playerView: UIView!
    
    // MARK: - Private
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var reels: Reels!
    
    // MARK: - Public
    
    var index: IndexPath!

//    override func prepareForReuse() {
//    
//        self.playerView = UIView(frame: self.playerView.frame)
//    }
    func setData(data: Reels, index: IndexPath)
    {
        self.reels = data
        
        self.prepareVideo()
    }
    
    private func prepareVideo() {
        self.playerView.layoutIfNeeded()
        guard let videoURL = self.reels.url, let url = URL(string: videoURL) else {
            return
        }
        
        avPlayer?.automaticallyWaitsToMinimizeStalling = true
        avPlayer = AVPlayer(url: url) //AVPlayer(playerItem: CachingPlayerItem.init(url: url))
        let avPlayerView = AVPlayerLayer(player: avPlayer)
        avPlayerView.frame = self.playerView.bounds
        avPlayerView.videoGravity = .resizeAspectFill
        avPlayerView.player?.isMuted = true
        self.playerView.layer.addSublayer(avPlayerView)
        self.avPlayerLayer = avPlayerView
        
       // self.playVideoFromStart()
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
}
