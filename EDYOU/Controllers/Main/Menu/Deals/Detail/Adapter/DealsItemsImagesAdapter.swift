//
//  
//  DealsItemsImagesAdapter.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//
//

import UIKit

class DealsItemsImagesAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
//    var parent: UIViewController {
//        return collectionView.viewContainingController()
//    }
    var images: [String] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(PostImageCell.nib, forCellWithReuseIdentifier: PostImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension DealsItemsImagesAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension DealsItemsImagesAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.identifier, for: indexPath) as! PostImageCell
        cell.imgPost.setImage(url: images[indexPath.row], placeholderColor: R.color.image_placeholder())
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
