//
//  SeeAllVC.swift
//  EDYOU
//
//  Created by Aksa on 24/08/2022.
//

import UIKit
import Photos
import SwiftUI

protocol SeeAllVCDelegate: AnyObject {
//    func updateImagesAndMedias(images: [UIImage], medias: [Media])
    func updateImagesAndMedia(media: [PhoneMediaAssets])
}

class SeeAllVC: BaseController {
    // MARK: - Outlets
    @IBOutlet weak var imagesAndVideosTableView: UITableView!
    
//    var images = [UIImage]()
    var medias = [PhoneMediaAssets]()
    weak var delegate: SeeAllVCDelegate?
    var targetSizeArray = [CGFloat]()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesAndVideosTableView.register(SeeAllCell.nib, forCellReuseIdentifier: SeeAllCell.name)
        imagesAndVideosTableView.delegate = self
        imagesAndVideosTableView.dataSource = self
        calculateImageHeight()
    }
    
    // MARK: - Functions
    func calculateImageHeight() {
        for media in medias {
            let targetSize = CGSize(width: self.imagesAndVideosTableView.frame.width, height: self.imagesAndVideosTableView.frame.width)
            let image = media.image ?? media.thumbnailImage ?? UIImage()
            let scaledImage = image.scalePreservingAspectRatio(
                targetSize: targetSize
            )
            if (scaledImage.size.height > 500) {
                targetSizeArray.append(500)
            } else {
                targetSizeArray.append(scaledImage.size.height)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if (navigationController?.presentationController != nil) {
            delegate?.updateImagesAndMedia(media: self.medias)
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.updateImagesAndMedia(media: self.medias)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TableView delegate and datasource
extension SeeAllVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SeeAllCell.name, for: indexPath) as! SeeAllCell
        let media = medias[indexPath.row]
        
        cell.selectedImageView.image = media.image ?? media.thumbnailImage
        cell.deleteImageBtn.tag = indexPath.row
        cell.deleteImageBtn.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
        
        if (!medias[indexPath.row].isImage) {
            cell.videoLengthLbl.isHidden = false
            cell.videoLengthLbl.text = media.videoDuration.toMinutesSeconds
        } else {
            cell.videoLengthLbl.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return targetSizeArray[indexPath.row]
    }
    
    @objc func deleteImage(sender: UIButton) {
        self.medias.remove(at: sender.tag)
        calculateImageHeight()
        self.imagesAndVideosTableView.reloadData()
    }
}
