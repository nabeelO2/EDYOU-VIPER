//
//  StoryMediaFilesAdapter.swift
//  EDYOU
//
//  Created by Raees on 11/09/2022.
//

import Foundation
import UIKit
class StoryMediaFilesAdapter : NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: StoryMediaFilesViewController? {
        return collectionView.viewContainingController() as? StoryMediaFilesViewController
    }
    var mediaFiles = [Media]()
    var selectedIndex = Int()
    // MARK: - Initializers
    init(collectionView: UICollectionView,mediaFiles : [Media],selectedIndex: Int) {
        super.init()
        self.collectionView = collectionView
        self.mediaFiles = mediaFiles
        self.selectedIndex = selectedIndex
        configure()
    }
    func configure() {
        collectionView.register(MediaFilesCollectionViewCell.nib, forCellWithReuseIdentifier: MediaFilesCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
       
    }
}
// MARK: - CollectionView DataSource and Delegates
extension StoryMediaFilesAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.restore()
        if mediaFiles.count == 0 {
            collectionView.addEmptyView("No Media file(s)", "You have no media files to upload", EmptyCellConfirguration.photos.image)
        }
        return mediaFiles.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaFilesCollectionViewCell.identifier, for: indexPath) as! MediaFilesCollectionViewCell
        if indexPath.row == selectedIndex {
            cell.containerView.borderWidth = 1
        } else {
            cell.containerView.borderWidth = 0
        }
        cell.mediaImage.image = mediaFiles[indexPath.row].image
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parent?.setupActiveImage(index: indexPath.row)
        self.selectedIndex = indexPath.row
        self.collectionView.reloadData()
    }
}
