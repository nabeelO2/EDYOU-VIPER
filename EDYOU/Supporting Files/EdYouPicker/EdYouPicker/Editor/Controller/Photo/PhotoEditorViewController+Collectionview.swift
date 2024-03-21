//
//  PhotoEditorPreviewViewController+Collectionview.swift
//  ustories
//
//  Created by imac3 on 14/06/2023.
//

import Foundation
import UIKit

// MARK: UICollectionViewDataSource
extension PhotoEditorViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCount
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let photoAsset = photoAsset(for: indexPath.item) else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: NSStringFromClass(PreviewPhotoViewCell.self),
                for: indexPath)
        }
        
        let cell: PhotoEditorPreviewCell
        
        
        cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(PhotoEditorPreviewCell.self),
            for: indexPath
        ) as! PhotoEditorPreviewCell
        cell.photoAsset = photoAsset
        cell.delegate = self
        return cell

    }
}
// MARK: UICollectionViewDelegate
extension PhotoEditorViewController: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let myCell = cell as! PhotoEditorPreviewCell
       // myCell.scrollContentView.startAnimatedImage()
        if myCell.photoAsset.mediaType == .video {
          //  myCell.scrollView.zoomScale = 1
        }
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(
                pickerController,
                previewCellWillDisplay: myCell.photoAsset,
                at: indexPath.item
            )
        }
    }
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let myCell = cell as! PhotoEditorPreviewCell
        myCell.cancelRequest()
        if let pickerController = pickerController {
            pickerController.pickerDelegate?.pickerController(
                pickerController,
                previewCellDidEndDisplaying: myCell.photoAsset,
                at: indexPath.item
            )
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != collectionView || orientationDidChange {
            return
        }
        let offsetX = scrollView.contentOffset.x  + (view.hx_width + 20) * 0.5
        let viewWidth = view.hx_width + 20
        var currentIndex = Int(offsetX / viewWidth)
        if currentIndex > assetCount - 1 {
            currentIndex = assetCount - 1
        }
        if currentIndex < 0 {
            currentIndex = 0
        }
        if let photoAsset = photoAsset(for: currentIndex) {
            if !isExternalPreview {
                if photoAsset.mediaType == .video && videoLoadSingleCell {
//                    selectBoxControl.isHidden = true
//                    selectBoxControl.isEnabled = false
                }else {
//                    selectBoxControl.isHidden = false
//                    selectBoxControl.isEnabled = true
//                    updateSelectBox(photoAsset.isSelected, photoAsset: photoAsset)
//                    selectBoxControl.isSelected = photoAsset.isSelected
                }
            }
            if !firstLayoutSubviews &&
                configPreview.bottomView.showSelectedView &&
                (isMultipleSelect || isExternalPreview) &&
                configPreview.showBottomView {
//                bottomView.selectedView.scrollTo(photoAsset: photoAsset)
            }
//            #if HXPICKER_ENABLE_EDITOR
            if let pickerController = pickerController,
               !configPreview.bottomView.editButtonHidden,
               configPreview.showBottomView {
//                if photoAsset.mediaType == .photo {
//                }else if photoAsset.mediaType == .video {
//
//                }
            }
//            #endif
            pickerController?.previewUpdateCurrentlyDisplayedAsset(photoAsset: photoAsset, index: currentIndex)
        }
        //self.currentPreviewIndex = currentIndex
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != collectionView || orientationDidChange {
            return
        }
        if scrollView.isTracking {
            return
        }
        let cell = getEditorCell(for: currentPreviewIndex)
       // cell?.requestPreviewAsset()
        if let pickerController = pickerController, let cell = cell {
            pickerController.pickerDelegate?.pickerController(
                pickerController,
                previewDidEndDecelerating: cell.photoAsset,
                at: currentPreviewIndex
            )
        }
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if let cell = getEditorCell(for: indexPath.row){
            
            cell.delegate?.bottomView(didSelectedItemAt: cell.photoAsset)
        }
        if indexPath.row != 0 {
            //deselect first
            
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
   
}
