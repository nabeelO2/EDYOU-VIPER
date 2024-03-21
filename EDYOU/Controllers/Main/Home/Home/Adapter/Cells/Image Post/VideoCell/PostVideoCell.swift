//
//  PostImageCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import MediaPlayer
import AVKit
import LiveKit
import AVFoundation
import SDWebImage
//import VersaPlayer

class PostVideoCell: UICollectionViewCell, AVAssetResourceLoaderDelegate {
   
    @IBOutlet weak var controllerBGView: UIView!
    @IBOutlet var imgPost: UIImageView!
    @IBOutlet weak var playerBGView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var mediaProgressV: UIProgressView!
    @IBOutlet weak var bufferingSpinner : UIActivityIndicatorView!
    
//    @IBOutlet weak var controls: VideoPlayerView!
    var postData = PostMedia(url: "", type: .video)
   // var playerView: VideoPlayerV!
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    @IBOutlet var playImgV: UIImageView!
    @IBOutlet var speakImgV: UIImageView!
    
    var player: AVPlayer!
    var isPlaying : Bool = false
    var playerTime  : Float = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgPost.isHidden = false
        self.imgPost.layer.cornerRadius = 5
        self.imgPost.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        self.imgPost.clipsToBounds = true
        self.imgPost.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.imgPost.layer.borderWidth = 0.5
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resize
        //self.imgPost.layer.addSublayer(videoLayer)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetVideoData()
    }
    
    
    
    func loadData(data: PostMedia, indexPath: IndexPath) {
//        print("playerTime : \(data.url): \(playerTime)")
//        playerView = VideoPlayerV(frame: self.playerBGView.frame)
        if let url = URL(string: data.thumbnailURL){
            imgPost.sd_setImage(with: url)
        }
        
        resetVideoData()
        if let layers = playerBGView.layer.sublayers{
            layers.forEach({ layer in
            layer.removeFromSuperlayer()
        })
        }
            
        downloadVideo(url: URL(string: data.url)!)
//        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
//        downloadInChunks(url: URL(string: data.url)!)

        bufferingSpinner.isHidden = false
        bufferingSpinner.startAnimating()
        

//        }
            
        
//
        playerBGView.clipsToBounds = true
//        playerBGView.addSubview(playerView)
        self.sendSubviewToBack(playerBGView)

        self.bringSubviewToFront(controllerBGView)

        postData = data

        self.btnPlay.tag = indexPath.row
    }
    
    func resetVideoData() {
//        self.imgPost.image = nil
//        self.playerBGView.backgroundColor = UIColor.clear
        
    }
    
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        if isPlaying{
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let horizontalMargin: CGFloat = 20
//        let width: CGFloat = bounds.size.width - horizontalMargin * 2
//        let height: CGFloat = (width * 0.9).rounded(.up)
        playerLayer.frame = playerBGView.frame
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(imgPost.frame, from: imgPost)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    
    func replay(){
        self.player?.seek(to: .zero)
        play()
    }
    
    func play() {

        isPlaying = true
//        self.playImgV.image = UIImage(named: "add_story_icon")
        self.player?.play()
        _ =  player?.addPeriodicTimeObserver(forInterval: CMTime(value: CMTimeValue(1), timescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            self?.bufferingSpinner.isHidden = true
            let currentTime = Float(CMTimeGetSeconds(progressTime))
            self?.playerTime = currentTime
            if currentTime > 0{
                self?.imgPost.isHidden = true
            }
           
            let duration = Float(CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTime.zero))
          

            if currentTime >= duration{
                self?.player.seek(to: CMTime.zero)
                self?.play()
            }
        }
    
    }
    func generateThumbnailInBackground(from videoURL: URL, cacheKey: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.generateThumbnail(from: videoURL) { thumbnailImage in
                if let thumbnailImage = thumbnailImage {
                    // Cache the thumbnail image using SDWebImage
                    SDWebImageManager.shared.imageCache.store(thumbnailImage, imageData: thumbnailImage.pngData(), forKey: cacheKey, cacheType: .all) {
                        completion(thumbnailImage)
                    }
                    
                } else {
                    completion(nil)
                }
            }
        }
    }
    func generateThumbnail(from videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        // Get the first frame as a CGImage
        guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil) else {
            completion(nil)
            return
        }

        // Convert the CGImage to a UIImage
        let thumbnailImage = UIImage(cgImage: cgImage)
        completion(thumbnailImage)
    }
    func downloadVideo(url videoUrl: URL){
        let fileName = videoUrl.lastPathComponent
        let cacheKey = fileName.replacingOccurrences(of: ".mp4", with: "")
//        generateThumbnailInBackground(from: videoUrl, cacheKey: cacheKey) { thumbnailImage in
//            if let thumbnailImage = thumbnailImage {
//                // Use the thumbnail image as needed
//                self.imgPost.image = thumbnailImage
//                print("Thumbnail image generated and cached successfully.")
//            } else {
//                self.imgPost.image = UIImage(named: "11")
//                print("Failed to generate and cache thumbnail image.")
//            }
//        }
       
        let urlSession = URLSession.shared
        let videoCacheURL = try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(fileName)
        print(videoCacheURL?.absoluteString ?? "")
        if FileManager.default.fileExists(atPath: videoCacheURL!.path){
            //have file
            DispatchQueue.main.async { [self] in
//                imgPost.sd_setImage(with: videoCacheURL!, placeholderImage: UIImage(named: "11"))
                 player = AVPlayer(url: videoCacheURL!)
                 playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = playerBGView.bounds
                playerLayer.videoGravity = .resizeAspectFill
                playerBGView.layer.addSublayer(playerLayer)
//                player.play()
                layoutSubviews()
            }
        }else{
            //download
            let task = urlSession.dataTask(with: videoUrl) { (data, _, error) in
                if let data = data {
                    // Save the video data to a file
                    
                    
                    try? data.write(to: videoCacheURL!)
                    DispatchQueue.main.async { [self] in
//                        imgPost.sd_setImage(with: videoCacheURL!, placeholderImage: UIImage(named: "11"))
                        player = AVPlayer(url: videoCacheURL!)
                        playerLayer = AVPlayerLayer(player: player)
                        playerLayer.frame = playerBGView.bounds
                        playerLayer.videoGravity = .resizeAspectFill
                        playerBGView.layer.addSublayer(playerLayer)
                        //                        player.play()
                        layoutSubviews()
                    }
//                    self.downloadVideo(url: videoCacheURL!)
                   
                   
                }
            }
            task.resume()
            
        }
        
        
//        imgPost.sd_setImage(with: videoUrl, placeholderImage: UIImage(named: "11"))
//
//        let cachedAsset = AVURLAsset(url: videoUrl)
//
//        cachedAsset.resourceLoader.setDelegate(self, queue: .main)
//        let playerItem = AVPlayerItem(asset: cachedAsset)
////            let player = AVPlayer(playerItem: playerItem)
//        self.player = AVPlayer(playerItem: playerItem)
//        self.playerLayer = AVPlayerLayer(player: self.player)
//        DispatchQueue.main.async {
//            self.playerLayer.frame = self.playerBGView.frame
//            self.playerLayer.videoGravity = .resizeAspectFill
//            self.playerBGView!.layer.addSublayer(self.playerLayer)
//            self.layoutSubviews()
//
//        }
        return
        
        
        // Create a URL for the video you want to download and cache
//        let videoUrl = URL(string: "https://example.com/video.mp4")!

        // Create a URL for the cached video file
        let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(videoUrl.lastPathComponent)

        // Check if the cached video file exists
        if FileManager.default.fileExists(atPath: cacheUrl.path) {
            // If the cached video file exists, use it to create an AVURLAsset
            let cachedAsset = AVURLAsset(url: cacheUrl)
            cachedAsset.resourceLoader.setDelegate(self, queue: .main)
            let playerItem = AVPlayerItem(asset: cachedAsset)
//            let player = AVPlayer(playerItem: playerItem)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.player)
            DispatchQueue.main.async {
                self.playerLayer.frame = self.playerBGView.frame
                self.playerLayer.videoGravity = .resizeAspectFill
                self.playerBGView!.layer.addSublayer(self.playerLayer)
                self.layoutSubviews()
            }
            // Use the AVPlayer to play the video
            // ...
        } else {
            // If the cached video file doesn't exist, download the video data using URLSession
            let task = URLSession.shared.downloadTask(with: videoUrl) { (location, response, error) in
                    guard let location = location else { return }
                    // Move the downloaded video data to the cache URL
                    try? FileManager.default.moveItem(at: location, to: cacheUrl)
                    // Use the cache URL to create an AVURLAsset
                    let cachedAsset = AVURLAsset(url: cacheUrl)
                cachedAsset.resourceLoader.setDelegate(self, queue: .main)
                    let playerItem = AVPlayerItem(asset: cachedAsset)
//                    let player = AVPlayer(playerItem: playerItem)
                self.player = AVPlayer(playerItem: playerItem)
                self.playerLayer = AVPlayerLayer(player: self.player)
                DispatchQueue.main.async {
                    self.playerLayer.frame = self.playerBGView.frame
                    self.playerLayer.videoGravity = .resizeAspectFill
                    self.playerBGView!.layer.addSublayer(self.playerLayer)
                    self.layoutSubviews()
                }
                
                    // Use the AVPlayer to play the video
                    // ...
                }
                task.resume()
            
//            let fileHandle = try? FileHandle(forWritingTo: cacheUrl)
//            var offset = 0
//            let task = URLSession.shared.dataTask(with: videoUrl) { (data, response, error) in
//                guard let data = data else { return }
//                // Write the downloaded data to the cache file
//                fileHandle?.seek(toFileOffset: UInt64(offset))
//                fileHandle?.write(data)
//                offset += data.count
//            }
//            task.resume()
//
//            // Create an AVPlayerItem and an AVPlayer once enough data has been downloaded
//            DispatchQueue.global(qos: .background).async {
//                while fileHandle?.offsetInFile ?? 0 < Int64(chunkSize) {
//                    usleep(100)
//                }
//                fileHandle?.closeFile()
//                let cachedAsset = AVURLAsset(url: cacheUrl)
//                let playerItem = AVPlayerItem(asset: cachedAsset)
////                let player = AVPlayer(playerItem: playerItem)
//                self.player = AVPlayer(playerItem: playerItem)
//                self.playerLayer = AVPlayerLayer(player: self.player)
//                self.playerLayer.frame = self.playerBGView.frame
//                self.playerLayer.videoGravity = .resizeAspectFill
//                self.playerBGView!.layer.addSublayer(self.playerLayer)
//                // Use the AVPlayer to play the video
//                // ...
//            }
        }
    }

    func downloadInChunks(url videoUrl: URL){
        
        let asset = AVURLAsset(url: videoUrl)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerBGView.bounds
        playerBGView.layer.addSublayer(playerLayer)

        layoutSubviews()
       // player.play()

    }

    func pause(){
//        self.playImgV.image = UIImage(named: "play_icon")
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
            self.speakImgV.image = UIImage(systemName: "speaker.slash.fill")
            
        }
        
    }
    func unMute(){
        if let queue = player {
            queue.isMuted = false
            self.speakImgV.image = UIImage(systemName: "speaker.wave.2.fill")
        }
        
    }
    func isMute()-> Bool{
        if let queue = player {
           return  queue.isMuted
            
        }
        return false
    }
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int,let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int
        {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus
            {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused
                    {
                       // LoaderView.show()
                    }
                    else
                    {
                     //   LoaderView.hide()
                    }
                }
            }
        }
    }
 
//    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
//        guard let url = loadingRequest.request.url else {
//            return false
//        }
//
//        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                loadingRequest.finishLoading(with: error ?? NSError(domain: "Unknown error", code: -1, userInfo: nil))
//                return
//            }
//
//            loadingRequest.dataRequest?.respond(with: data)
//            loadingRequest.finishLoading()
//        }
//
//        dataTask.resume()
//        return true
//    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            // Implement custom processing of the request here
        print("Resource shouldWaitForLoadingOfRequestedResource")
            return true
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didFinishLoading loadingRequest: AVAssetResourceLoadingRequest) {
            print("Resource loading finished")
        }
        
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didFailWithError error: Error) {
            print("Resource loading failed with error: \(error)")
        }

}
