//
//  ReelsPostViewController.swift
//  EDYOU
//
//  Created by Masroor Elahi on 08/09/2022.
//

import UIKit
import DPTagTextView
import TransitionButton
import AVFoundation

protocol ReelsPostDelegate {
    func reelSubmitted()
    func backToReels()
}

class ReelsPostViewController: BaseController {
    // MARK: - Outlets
    @IBOutlet weak var txtTitle: DPTagTextView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    // MARK: - Video URL
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnShare: TransitionButton!
    let placeholderText: String = "Be a star and share your Uclip short video to friends or everyone."
    let videoURL: URL?
    let delegate: ReelsPostDelegate?
    var reelsCreateRequest = ReelsCreateRequest()
    lazy var adapater = ReelsPostAdapter(tableView: self.tableView, request: self.reelsCreateRequest, controller: self)
    
    init(videoURL : URL, delegate: ReelsPostDelegate) {
        self.videoURL = videoURL
        self.delegate = delegate
        super.init(nibName: ReelsPostViewController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.videoURL = nil
        self.delegate = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.adapater.reloadTable()
    }
    
    func setUI() {
        guard let image = self.videoURL?.getThumbnailImage() else {
            return
        }
        self.imgThumbnail.image = image
        self.txtTitle.delegate = self
    }
    
    @IBAction func actPlayFile(_ sender: UIButton) {
        guard let videoURL = videoURL else {
            return
        }
        self.playVideo(url: videoURL.absoluteString)
    }
    @IBAction func actBack(_ sender: UIButton) {
        self.delegate?.backToReels()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actSubmitVideo(_ sender: UIButton) {
        if self.txtTitle.text == placeholderText {
            self.showErrorWith(message: "Please enter video description")
            return
        }
        guard let videoURL = videoURL else {
            return
        }
        self.reelsCreateRequest.title = self.txtTitle.text
        self.reelsCreateRequest.duration = videoURL.getVideoDuration()
        if !self.reelsCreateRequest.saveToGallery {
            self.submitReelsVideo(url: videoURL)
        } else {
            self.saveVideoToGallery(videoURL: videoURL) { success in
                self.submitReelsVideo(url: videoURL)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Reels Video
extension ReelsPostViewController {
    func submitReelsVideo(url: URL) {
        guard let data = try? Data.init(contentsOf: url) else { return }
        let parameters = self.reelsCreateRequest.dictionary
        print(parameters)
        self.btnShare.startAnimation()
        APIManager.fileUploader.createReels(parameters: parameters, media: [Media.init(withData: data, key: "video", mimeType: MimeType.video)], progress: nil) { response, error in
            self.btnShare.stopAnimation()
            if let error = error {
                self.showErrorWith(message: error.message)
            } else {
                self.navigateBack()
            }
        }
    }
    
    func navigateBack() {
        self.delegate?.reelSubmitted()
        self.navigationController?.popViewController(animated: true)
    }
}

extension ReelsPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
        }
    }
}
