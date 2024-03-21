//
//  
//  MediaViewerAdapter.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 13/03/2022.
//
//

import UIKit
import RealmSwift

class MediaViewerAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: UIViewController? {
        return collectionView.viewContainingController()
    }
    var media = [MediaAsset]()
    var videos = List<String>()
    var images = List<String>()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(MediaViewerCell.nib, forCellWithReuseIdentifier: MediaViewerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Actions
extension MediaViewerAdapter {
    @objc func didTapPlayButton(_ sender: UIButton) {
        if(media.count > 0){
            if let m = media.object(at: sender.tag), m.type == .video {
                self.parent?.playVideo(url: m.url)
            }
        }
        else{
            if (images.count > 0 && sender.tag < images.count){
            
            }
            else{
                if let m = videos.toArray(type: String.self).object(at: sender.tag) {
                    self.parent?.playVideo(url: m)
                }
            }
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension MediaViewerAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(media.count > 0){
            return media.count
        }
        else{
            return images.count + videos.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaViewerCell.identifier, for: indexPath) as! MediaViewerCell
        if(media.count > 0){
            cell.setData(media[indexPath.row])
        }
        else if (images.count > 0 && indexPath.row < images.count){
            cell.setImageData(images[indexPath.row])
        }
        else{
            cell.setVideoData(videos[indexPath.row])
        }
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(didTapPlayButton(_:)), for: .touchUpInside)
        return cell
    }
}
