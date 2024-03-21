//
//  PostImageCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import MediaPlayer
import AVKit
import SDWebImage

class PostImageCell: UICollectionViewCell {

    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var controllerBGView: UIView!
    @IBOutlet var playImgV: UIImageView!
    @IBOutlet var muteImgV: UIImageView!
    
    @IBOutlet weak var bufferingSpinner : UIActivityIndicatorView!

    @IBOutlet weak var mediaProgressV: UIProgressView!
        var avQueuePlayer   : AVQueuePlayer?
   //     var avPlayerLayer   : AVPlayerLayer?
    
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var player: AVPlayer!
    var isPlaying : Bool = false
    private var playerObserver: Any?
    
    var reloadHeight : ((CGFloat)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetVideoData()
    }
    
//    func play(for url: URL) {
        //            self.avQueuePlayer = AVQueuePlayer(url: url)
        //            self.avPlayerLayer = AVPlayerLayer(player: self.avQueuePlayer!)
        //            self.avPlayerLayer?.frame = self.viewVideo.bounds
        //            self.avPlayerLayer?.fillMode = .both
        //            self.viewVideo.layer.addSublayer(self.avPlayerLayer!)
        //            self.avQueuePlayer?.play()
        
//        self.bringSubviewToFront(controllerBGView)
//        player = AVPlayer(url: url)
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = viewVideo.frame
//        playerLayer.videoGravity = .resizeAspectFill
//        viewVideo!.layer.addSublayer(playerLayer)
//        player.play()
//    }
    
    func loadData(data: PostMedia, indexPath: IndexPath) {
       // self.resetVideoData()
        if data.type == .image {
            self.viewVideo.isHidden = true
            self.controllerBGView.isHidden = true
            self.bufferingSpinner.isHidden = true
            self.imgPost.isHidden = false
            
            DispatchQueue.main.async {
                self.imgPost.setImage(url: data.url, placeholderColor: R.color.image_placeholder() ?? .lightGray) {
                    if let action = self.reloadHeight{
                        if let img = self.imgPost.image{
                            let height = self.getImageHeight(image: self.imgPost.image!)
                            action(height)
                        }
                        
                       
//                        self.imgPost.image = nil
                    }
                }
            }
        } else if let videoURL = URL(string: data.url) {
            if let url = URL(string: data.thumbnailURL){
                self.imgPost.isHidden = false
                imgPost.sd_setImage(with: url)
                
            }
            self.viewVideo.isHidden = false
            self.controllerBGView.isHidden = false
            self.bufferingSpinner.isHidden = false
            
            self.bringSubviewToFront(controllerBGView)
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = viewVideo.frame
            playerLayer.videoGravity = .resizeAspectFill
            viewVideo!.layer.addSublayer(playerLayer)
           
            bufferingSpinner.startAnimating()
           //play()
            layoutSubviews()
//            self.imgPost.getThumbnailImageFromVideoUrl(url: videoURL) { [weak self] image in
//                guard let self = self , let image = image else { return }
//                DispatchQueue.main.async {
//                    self.imgPost.image = self.imgPost.image == nil ? image : self.imgPost.image
//                }
//                self.viewVideo.backgroundColor = .clear
//            }
//            self.viewVideo.isHidden = false
        }
        self.btnPlay.tag = indexPath.row
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.frame = viewVideo.frame
    }
    func resetVideoData() {
//        self.imgPost.image = nil
        self.viewVideo.backgroundColor = UIColor.black
    }
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        if isPlaying{//playerView.isPlaying{
            pause()
            
            
        }else{
            play()
        }
    }
    
    @IBAction func didTapMuteButton(_ sender: UIButton) {
        if isMute(){
            unMute()
        }else{
            mute()
        }
        
    }
    
    
    
    
    func play() {
        if isPlaying {
            return
        }
        isPlaying = true
        self.playImgV.image = UIImage(named: "pause")
        self.player?.play()
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
         playerObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            // Update the progress bar based on the current playback time
            self?.bufferingSpinner.isHidden = true
            let currentTime = Float(CMTimeGetSeconds(time))
             if currentTime > 0{
                 self?.imgPost.isHidden = true
             }
            let duration = Float(CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTime.zero))
            let progress = currentTime / duration
            self?.mediaProgressV.setProgress(progress, animated: true)
             if currentTime >= duration{
                 self?.isPlaying = false
                 
                 self?.player.seek(to: CMTime.zero)
                 self?.mediaProgressV.setProgress(0, animated: false)
                 DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                     self?.play()
                 }
                 
             }
        }
        
    }
   
    
    func pause(){
        self.playImgV.image = UIImage(named: "play_icon")
        isPlaying = false
        self.player?.pause()
    }
    func toggleMute()->Bool{
        if let queue = player {
            queue.isMuted = !queue.isMuted
            return queue.isMuted
        }
        return false
    }
    func mute(){
        if let queue = player {
            queue.isMuted = true
            self.muteImgV.image = UIImage(systemName: "speaker.slash.fill")
            
        }
        
    }
    func unMute(){
        if let queue = player {
            queue.isMuted = false
            self.muteImgV.image = UIImage(systemName: "speaker.wave.2.fill")
        }
        
    }
    func isMute()-> Bool{
        if let queue = player {
           return  queue.isMuted
            
        }
        return false
    }
    fileprivate let seekDuration: Float64 = 5


    @IBAction func doForwardJump(_ sender : UIButton) {
        guard let duration  = player.currentItem?.duration else{
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seekDuration

        if newTime < CMTimeGetSeconds(duration) {

            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2)
        }
    }
    @IBAction func doBackwardJump(_ sender : UIButton) {

        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDuration

        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time2)

    }
    private func getImageHeight(image: UIImage)->CGFloat{
        var cellFrame = self.frame.size
        cellFrame.height = cellFrame.height - 15
        cellFrame.width = cellFrame.width - 15
        return self.getAspectRatioAccordingToiPhones(cellImageFrame: cellFrame, image: image)
    }
    private func getAspectRatioAccordingToiPhones(cellImageFrame:CGSize,image: UIImage)->CGFloat {
        let widthOffset = image.size.width - cellImageFrame.width
        let widthOffsetPercentage = (widthOffset*100)/image.size.width
        let heightOffset = (widthOffsetPercentage * image.size.height)/100
        let effectiveHeight = image.size.height - heightOffset
        return(effectiveHeight)
      }
    
    deinit {
        print("deinit post image cell")
    }
}
