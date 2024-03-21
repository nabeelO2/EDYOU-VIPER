//
//  
//  PhotosAdapter.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//
//

import UIKit
import ImageSlideshow
import SDWebImage

class PhotosAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: PhotosController? {
        return collectionView.viewContainingController() as? PhotosController
    }
    
    var media = [MediaAsset]()
    var isLoading = true
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension PhotosAdapter {
    
}


// MARK: - CollectionView DataSource and Delegates
extension PhotosAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 42 : media.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.width - 6) / 3
        return CGSize(width: w, height: w)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        if isLoading {
            cell.imageView.startSkelting()
            cell.viewPlay.isHidden = true
        } else {
            cell.imageView.stopSkelting()
            cell.imageView.setImage(url: media[indexPath.row].url, placeholderColor: R.color.image_placeholder())
            cell.viewPlay.isHidden = media[indexPath.row].type == .image
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MediaViewerController(media: media, selectedIndex: indexPath.row)
        self.parent?.present(controller, animated: false, completion: nil)
        
    }
}
