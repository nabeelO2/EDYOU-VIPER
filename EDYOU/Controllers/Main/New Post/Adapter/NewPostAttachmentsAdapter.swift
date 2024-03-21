//
//  NewPostAttachmentsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import Photos

class NewPostAttachmentsAdapter: NSObject {
    weak var collectionView: UICollectionView!
    private var medias = [PhoneMediaAssets]()
    var mediaForServer: [Media] {
        var mediaArray: [Media] = []
        self.medias.forEach { object in
            let random = arc4random()
            let dimenstion = object.dimenstions ?? ""
            let randomStr = dimenstion.isEmpty ? "_edyou_\(random)" : "_edyou_\(random)_dimenstion_\(object.dimenstions!)"
            
            
            if let imageData = object.imageData {
                let filename =  "image_\(randomStr).jpeg"
                
                mediaArray.append(Media(withData: imageData, key: "images", mimeType: .image, dimenstion: object.dimenstions ?? "",withFileName: filename))
            }
            if let videoData = object.videoData {
                if let thumbNail = object.thumbnailImage{
                    let width = Int(thumbNail.size.width)
                    let height = Int(thumbNail.size.height)
                  
                    let thumbnailDimenstions = "\(width)x\(height)"
                   
                    
                    let randomStrThumbnail = thumbnailDimenstions.isEmpty ? "image_edyou_\(random)_thumbnail" : "image_edyou_\(random)_thumbnail_dimenstion_\(thumbnailDimenstions)"
                    
                    let filenameThumbnail =  "\(randomStrThumbnail).jpeg"
                    
                    if let imageData = thumbNail.jpegData(compressionQuality: 1.0){
                        mediaArray.append(Media(withData: imageData, key: "images", mimeType: .image, dimenstion: object.dimenstions ?? "",withFileName: randomStrThumbnail))
                    }
                    
                }
               
                
                let filename =  "video_\(randomStr).mp4"
                
                mediaArray.append(Media(withData: videoData, key: "videos", mimeType: .video, thumbnailImage: object.thumbnailImage,withFileName: filename))
            }
        }
        return mediaArray
    }
    
    var mediaCount: Int {
        return self.medias.count
    }
    
    var isImagesAndVideosAttached: Bool {
        return !(self.medias.isEmpty)
    }
    
    var parentController : NewPostController? {
        return collectionView.viewContainingController() as? NewPostController
    }
    
    init(collectionView: UICollectionView, forTags: Bool = false, emojiAtIndex: Int = -1) {
        super.init()
        self.collectionView = collectionView
        configure()
    }
    
    func configure() {
        
        collectionView.register(AttachetImageCell.nib, forCellWithReuseIdentifier: AttachetImageCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView.collectionViewLayout = layout
    }
    
    func addData(mediaAsset: PhoneMediaAssets) {
        medias.append(mediaAsset)
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func removeAssets() {
        self.medias.removeAll()
        self.collectionView.reloadData()
    }
}


// MARK: - CollectionView DataSource and Delegate
extension NewPostAttachmentsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (medias.count <= 4) {
            return medias.count
        }
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 64) / 4
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachetImageCell.identifier, for: indexPath) as! AttachetImageCell
        cell.loadData(data: medias[indexPath.row], indexPath: indexPath, totalCount: medias.count)
        cell.btnShowAll.addTarget(self, action: #selector(seeAllBtnTapped), for: .touchUpInside)
        cell.btnRemove.addTarget(self, action: #selector(removeAttachments(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func seeAllBtnTapped() {
        let seeAllVC = SeeAllVC()
        seeAllVC.medias = self.medias
        seeAllVC.delegate = self
        parentController?.present(seeAllVC, presentationStyle: .fullScreen)
    }
    
    @objc func removeAttachments(sender: UIButton) {
        self.medias.remove(at: sender.tag)
        self.collectionView.reloadData()
        if self.medias.count == 0{
            parentController?.collectionViewHeightConstraint.constant = 0
            
        }
    }
}

extension NewPostAttachmentsAdapter : SeeAllVCDelegate {
    func updateImagesAndMedia(media: [PhoneMediaAssets]) {
        self.medias = media
        self.collectionView.reloadData()
    }
}
