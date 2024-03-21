//
//  MediaViewerCell.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 13/03/2022.
//

import UIKit

class MediaViewerCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnPlay: UIButton!
    
    
    var tapGesture: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = 1
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        if tapGesture == nil {
            tapGesture = UITapGestureRecognizer()
            tapGesture?.numberOfTapsRequired = 2
            tapGesture?.addTarget(self, action: #selector(didDoubleTapImageView(_:)))
            scrollView.addGestureRecognizer(tapGesture!)
        }
        
        
    }
    
    @objc func didDoubleTapImageView(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 2 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.setZoomScale(2, animated: true)
        }
        
    }
    
    func setData(_ media: MediaAsset) {
        activityIndicator.isHidden = false
        imageView.setImage(url: media.url, placeholder: nil) { [weak self] in
            self?.activityIndicator.isHidden = true
        }
        viewPlay.isHidden = media.type == .image
        btnPlay.isHidden = media.type == .image
    }
    func setVideoData(_ media: String) {
        activityIndicator.isHidden = false
        imageView.setImage(url: media, placeholder: nil) { [weak self] in
            self?.activityIndicator.isHidden = true
        }
        viewPlay.isHidden = false
        btnPlay.isHidden = false
    }
    func setImageData(_ media: String) {
        activityIndicator.isHidden = false
        imageView.setImage(url: media, placeholder: nil) { [weak self] in
            self?.activityIndicator.isHidden = true
        }
        viewPlay.isHidden = true
        btnPlay.isHidden = true
    }
    

}

extension MediaViewerCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
