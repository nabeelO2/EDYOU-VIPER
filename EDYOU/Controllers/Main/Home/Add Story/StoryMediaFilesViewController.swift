//
//  StoryMediaFilesViewController.swift
//  EDYOU
//
//  Created by Raees on 11/09/2022.
//

import UIKit
import TransitionButton
class StoryMediaFilesViewController: BaseController {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var btnShare: TransitionButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    var adapter: StoryMediaFilesAdapter!
    var mediaFiles = [Media]()
    var selectedIndex = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupActiveImage(index: 0)
        adapter = StoryMediaFilesAdapter(collectionView: self.collectionView,mediaFiles: self.mediaFiles,selectedIndex: 0)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func shareToStoryTapped(_ sender: Any) {
        self.btnShare.startAnimation()
        createStory()
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        let alert = UIAlertController.init(title: "Delete Stories?", message: "If you leave, all changes will be lost", preferredStyle: .alert)
      
        alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: { _ in
            return
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.popBack(3)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func moreOptionsTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete Story", style: .destructive, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Save to Gallery", style: .default, handler: { _ in
                if self.playButton.isHidden {
                ImagePicker.shared.saveImage(selectedImage: self.mainImageView.image ?? UIImage(),showMessage: false)
                } else {
                    if let videoURL = self.mediaFiles[self.selectedIndex].videoURL,UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.relativePath) {
                        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, nil, nil, nil)
                    }
                }
                    
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func playTapped(_ sender: Any) {
        //play video in AVPlayer
        if let url = mediaFiles[selectedIndex].videoURL {
            self.playVideo(url: url.absoluteString)
        }
    }
    
    func createStory() {
        
//        var colors = ""
//        var colorPositions = ""
//        colors = viewBg.colors.hexStrings.joined(separator: ", ")
//        colorPositions = "(\(viewBg.startPoint.x), \(viewBg.startPoint.y)), (\(viewBg.endPoint.x), \(viewBg.endPoint.y))"
        
 //       let n = (txtStory.text ?? " ")
        let n = "Test"
        let parameters: [String: Any] = [
            "post_name" : n,
            "background_colors": "",
           "background_colors_position": "",
            "is_background": false,
            "post_type": "story",
            "post_deletion_settings": "a_day",
            "privacy": "friends"
        ]
        // video case
        let media = self.mediaFiles
        if media.count > 0 {
            view.endEditing(true)
            view.isUserInteractionEnabled = false
            progressBar.isHidden = false
            self.addBlurView(top: 0, bottom: 0, left: 0, right: 0, style: .dark)
            btnShare.startAnimation()
            APIManager.fileUploader.createPost(parameters: parameters, media: media) { [weak self] progress in
                guard let self = self else { return }

                self.progressBar.progress = progress
            } completion: { [weak self] response, error in
                guard let self = self else { return }

                self.view.isUserInteractionEnabled = true
                self.progressBar.isHidden = true
                self.btnShare.stopAnimation()
                self.removeBlurView()
                self.popBack(3)

                self.view.isUserInteractionEnabled = true
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorWith(message: error!.message)
                }

            }
        } else {
            self.view.isUserInteractionEnabled = true
            self.progressBar.isHidden = true
            self.btnShare.stopAnimation()
            self.removeBlurView()
        }
    }
    func setupActiveImage(index: Int)
    {
        selectedIndex = index
        let mediaFile = mediaFiles[index]
        if mediaFile.mimeType == "image/jpeg" {
            playButton.isHidden = true
        } else {
            playButton.isHidden = false
        }
        self.mainImageView.image = mediaFiles[index].image
    }



}
