//
//  StoryCell.swift
//  EDYOU
//
//  Created by  Mac on 05/10/2021.
//

import UIKit
import AVFoundation

protocol StoryCellDelegate: AnyObject  {
    func setCurrentStoryIndex(currenIndex:Int)
    func endProgressOfStories()

    func bottomMenuUpdate(isHidden : Bool)
    
}

class StoryCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBg: GradientView!
    @IBOutlet weak var lblStory: UILabel!
    @IBOutlet weak var imgStory: UIImageView!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var clvPages: UICollectionView!
    @IBOutlet weak var cstClvPagesTop: NSLayoutConstraint!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewTextGradient: GradientView!
    @IBOutlet weak var lblImageStoryText: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var loadingView : UIActivityIndicatorView!
    
    weak var parentView: UICollectionView?
    var story: Story?
    var isChangeProgress = true
    var selectedIndex = 0
    var timer: Timer?
    var progress:Float = 0
    
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    weak var delegate : StoryCellDelegate?

    var storyTimer : Float = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        viewTextGradient.colors = [UIColor.black.withAlphaComponent(0.8), UIColor.black.withAlphaComponent(0.4), UIColor.black.withAlphaComponent(0)]
        viewTextGradient.startPoint = CGPoint(x: 0, y: 1)
        viewTextGradient.endPoint = CGPoint(x: 0, y: 0)
        
        
//        cstClvPagesTop.constant =  20
        configure()
    }
    func configure() {
        clvPages.dataSource = self
        clvPages.delegate = self
        clvPages.register(StoryPageIndicatorCell.nib, forCellWithReuseIdentifier: StoryPageIndicatorCell.identifier)
        
        lblName.addShadow(ofColor: UIColor.gray, radius: 5.0, offset: CGSize(width: 1, height: 1), opacity: 0.8)
        lblDate.addShadow(ofColor: UIColor.gray, radius: 5.0, offset: CGSize(width: 1, height: 1), opacity: 0.8)
        
        
    }
    func cleanUpCell()
    {
        self.timer?.invalidate()
        self.progress = 0
        self.stopAVPlayer()
        delegate?.endProgressOfStories()
    }
    func setData(story: Story) {
        self.story = story
        selectedIndex = 0
        showStory()
        lblName.text = story.user.name?.completeName
        imgProfile.setImage(url: story.user.profileImage, placeholder: R.image.profile_image_dummy())
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        print("Video Finished")
        self.timer?.invalidate()
        showNextStory()
    }
    func showNextStory() {
        progress = 0
        self.selectedIndex += 1
        timer?.invalidate()
        self.showStory()
    }
    func showPreviousStory() {
        progress = 0
        self.selectedIndex -= 1
        timer?.invalidate()
        self.showStory()
    }
    


    func showStory() {
        self.stopAVPlayer()
        delegate?.setCurrentStoryIndex(currenIndex: selectedIndex)

        if selectedIndex < 0 {
            selectedIndex = 0

            
            if let c = parentView {
                var x = c.contentOffset.x - c.frame.width
                if x < 0 {
                    x = 0
                } else {
                let contentOffset = c.contentOffset
                    c.setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: true)
                    return
                }
            }
            
          
        }
        if selectedIndex >= (story?.stories.count ?? 0) {
            selectedIndex = (story?.stories.count ?? 1) - 1
            
            if let c = parentView {
                let x = c.contentOffset.x + c.frame.width
                let max = c.contentSize.width - c.frame.width
                if x > max {
                    selectedIndex = (story?.stories.count ?? 0) - 1
                    delegate?.setCurrentStoryIndex(currenIndex: selectedIndex)
//                    c.viewContainingController()?.goBack()
                    return
                }
                //get current content Offset of the Collection view
                let contentOffset = c.contentOffset
                c.setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: true)
            }
            
            print("Stories Ended")
            return
        }
        if let post = story?.stories.object(at: selectedIndex) {
            if post.processingStatus == .processing  || post.processingStatus == .uploading {
                lblImageStoryText.text = post.processingStatus == .processing ? "Processing" : "Uploading"
                lblImageStoryText.textAlignment = .center
                lblDate.text = post.timeOfPost
                lblImageStoryText.textColor = .white
                if post.processingStatus == .processing {
                    viewImage.isHidden = true
                    viewBg.isHidden = false
                    loadingView.isHidden = true
                    lblImageStoryText.isHidden = false
                    viewTextGradient.isHidden = true
                    self.playerView.isHidden = true
                    viewImage.isHidden = true
                    viewBg.colors = [UIColor.black,UIColor.black]
                    viewBg.updatePoints()
                    startProgress()
                    delegate?.bottomMenuUpdate(isHidden: true)
                    
                    
                } else if post.processingStatus == .uploading {
                    
                    if let asset = post.localAssets {
                        delegate?.bottomMenuUpdate(isHidden: true)
                        if asset.key == "images" {
                            self.playerView.isHidden = true
                            viewImage.isHidden = false
                            loadingView.isHidden = true
                            imgStory.backgroundColor = .black
                            imgStory.image = asset.image
                            
                        } else if asset.key == "videos" {
                            loadingView.isHidden = false
                            imgStory.image = nil
                            let videoURL = asset.videoURL
                            lblDate.text = post.timeOfPost
                            prepareVideo(url: videoURL?.absoluteString ?? "")
                        }
                    }
                   
                }
            } else if post.postAsset?.images?.isEmpty ?? true && post.postAsset?.videos?.isEmpty ?? true {
                viewImage.isHidden = true
                viewBg.isHidden = false
                loadingView.isHidden = true
                lblStory.text = post.formattedText
                lblDate.text = post.timeOfPost
                lblImageStoryText.isHidden = true
                viewTextGradient.isHidden = true
                
                if post.formattedText.isEmpty{
                    delegate?.bottomMenuUpdate(isHidden: true)
                }
                let colors = post.backgroundColors?.components(separatedBy: ", ").colors ?? []
                if let points = post.backgroundColorsPosition?.components(separatedBy: "), (") {
                    if points.count >= 2 {
                        let p1 = points[0].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                        let p2 = points[1].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")

                        viewBg.colors = colors
                        viewBg.startPoint = CGPoint(x: Double(p1.first ?? "0") ?? 0, y: Double(p1.last ?? "0") ?? 0)
                        viewBg.endPoint = CGPoint(x: Double(p2.first ?? "0") ?? 0, y: Double(p2.last ?? "0") ?? 0)

                    }
                }
                viewBg.updatePoints()
                progress = 0
                startProgress()
            } else {
                delegate?.bottomMenuUpdate(isHidden: false)
                
                if post.mediaType == .image {
                    self.playerView.isHidden = true
                    viewImage.isHidden = false
                    loadingView.isHidden = true
                    let t = post.formattedText.trimmed
                    viewTextGradient.isHidden = t.count == 0
                    lblDate.text = post.timeOfPost
                    
                   
                    imgStory.setImage(url: post.mediaUrl, placeholderColor: .black) { [weak self] in
                        self?.progress = 0
                        self?.startProgress()
                    }
                    
                    
                } else {
                    
//                    viewBg.colors = [UIColor.black,UIColor.black]
//                    viewBg.updatePoints()
                    viewBg.isHidden = true
                    viewImage.isHidden = false
                    loadingView.isHidden = false
                    lblImageStoryText.text = ""
                    imgStory.image = nil
                    let videoURL = post.mediaUrl
                    lblDate.text = post.timeOfPost
                    prepareVideo(url: videoURL ?? "")
                    
                    
                }
            }
        }
        clvPages.reloadData()
    }
    private func prepareVideo(url: String) {
        self.bringSubviewToFront(self.playerView)
        self.timer?.invalidate()
        self.progress = 0
        self.startProgressForVideo()
        self.playerView.isHidden = false
        self.playerView.layoutIfNeeded()
        guard let neededUrl = URL(string: url)  else {
            return
        }
        avPlayer?.automaticallyWaitsToMinimizeStalling = true
        avPlayer = AVPlayer(url: neededUrl) //AVPlayer(playerItem: CachingPlayerItem.init(url: url))
        let avPlayerView = AVPlayerLayer(player: avPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd),
               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        avPlayerView.frame = self.playerView.bounds
        avPlayerView.videoGravity = .resizeAspectFill
        self.playerView.layer.addSublayer(avPlayerView)
        avPlayer?.seek(to: .zero)
        avPlayer?.play()
        
        self.avPlayerLayer = avPlayerView
    }
    
    
    func pauseProgress() {
        isChangeProgress = false
        self.avPlayer?.pause()
        timer?.invalidate()
        
        
    }
    func resumeProgress() {
        isChangeProgress = true
        self.avPlayer?.play()
        startProgress()
    }
    
    func startProgress() {
        
        timer?.invalidate()
        
        if let cell = self.clvPages.cellForItem(at: IndexPath(row: self.selectedIndex, section: 0)) as? StoryPageIndicatorCell {
            cell.progressBar.setProgress(self.progress / storyTimer, animated: true)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [weak self]  t in
                guard let self = self else { return }
                
                
                if let cell = self.clvPages.cellForItem(at: IndexPath(row: self.selectedIndex, section: 0)) as? StoryPageIndicatorCell {
                    if isChangeProgress{
                        cell.progressBar.setProgress(self.progress / storyTimer, animated: true)
                    }
                    
                }
                
                if self.progress >= storyTimer {
                    self.selectedIndex += 1
                    t.invalidate()
                    self.showStory()
                }
                
                self.progress += 0.001
            })
            
        }
    }
    func stopAVPlayer() {
        //self.avPlayer?.pause()
        self.avPlayer?.replaceCurrentItem(with: nil)
    }
    private func updateProgress() {
        guard let duration = avPlayer?.currentItem?.duration.seconds,
            let currentMoment = avPlayer?.currentItem?.currentTime().seconds else { return }
        if currentMoment != 0.0 {
            if let cell = self.clvPages.cellForItem(at: IndexPath(row: self.selectedIndex, section: 0)) as? StoryPageIndicatorCell {
                cell.progressBar.progress = Float(currentMoment / duration)
                self.progress = cell.progressBar.progress
            }
        }
    }
    func startProgressForVideo() {
        
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [weak self]  t in
                guard let self = self else { return }
                self.updateProgress()
            })
            
        }
    }
    // Remove Observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension StoryCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return story?.stories.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let c = story?.stories.count, c > 0 {
            let w = (collectionView.frame.width - (CGFloat(c - 1) * 8)) / CGFloat(c)
            return CGSize(width: w, height: collectionView.frame.height)
        }
        return CGSize(width: 10, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryPageIndicatorCell.identifier, for: indexPath) as! StoryPageIndicatorCell
        cell.progressBar.progress = indexPath.row < selectedIndex ? 1 : 0
        return cell
    }
}


extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
