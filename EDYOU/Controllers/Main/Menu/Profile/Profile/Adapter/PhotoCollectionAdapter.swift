//
//  PhotoCollectionAdapter.swift
//  EDYOU
//
//  Created by Admin on 20/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class PhotoCollectionAdapter: NSObject {
    
    var collectionView:UICollectionView
    var photos:[MediaAsset]!
    var videos:[MediaAsset]!
    var isLoading:Bool = true
    var type = ProfilePhotosType(rawValue: 1)
    init(collectionView:UICollectionView, photos: [MediaAsset], videos: [MediaAsset],isLoading:Bool){
        self.collectionView = collectionView
        self.photos = photos
        self.videos = videos
        self.isLoading = isLoading
        super.init()
        configure()
    }
    func configure(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
    }
}
extension PhotoCollectionAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type{
        case .all:
            return photos.count + videos.count
        case .photos:
            return photos.count
        case .videos:
            return videos.count
        default:
            return 0
        }
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
            cell.imageView.setImage(url: photos[indexPath.row].url, placeholderColor: R.color.image_placeholder())
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let controller = MediaViewerController(media: media, selectedIndex: indexPath.row)
        //self.parent?.present(controller, animated: false, completion: nil)
        
    }
}
extension PhotoCollectionAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {

        return NSAttributedString(string: EmptyCellConfirguration.photos.title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold) , NSAttributedString.Key.foregroundColor : R.color.text_color()!])
    }
//
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: EmptyCellConfirguration.photos.shortDescription, attributes: [NSAttributedString.Key.font :  UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : R.color.dark_gray_text()!])
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -60
    }
        
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return EmptyCellConfirguration.photos.image
    }
    
}

extension PhotoCollectionAdapter:PhotoHeaderActions{
    func photoSegmentChanged(type: ProfilePhotosType) {
        self.type = type
    }
    
    
    
}

