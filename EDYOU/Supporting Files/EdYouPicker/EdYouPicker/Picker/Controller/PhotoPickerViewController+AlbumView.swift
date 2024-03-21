//
//  PhotoPickerViewController+AlbumView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/27.
//

import UIKit

// MARK: AlbumViewDelegate
extension PhotoPickerViewController: AlbumViewDelegate {
    
    @objc func didTitleViewClick(control: AlbumTitleView) {
        control.isSelected = !control.isSelected
        if control.isSelected {
            // 展开
            if albumView.assetCollectionsArray.isEmpty {
//                ProgressHUD.showLoading(addedTo: view, animated: true)
//                ProgressHUD.hide(forView: weakSelf?.navigationController?.view, animated: true)
                control.isSelected = false
                return
            }
            openAlbumView()
        }else {
            // 收起
            closeAlbumView()
        }
    }
    
    @objc func didAlbumBackgroudViewClick() {
        titleView.isSelected = false
        closeAlbumView()
    }
    
    func openAlbumView() {
        collectionView.scrollsToTop = false
        albumBackgroudView.alpha = 0
        albumBackgroudView.isHidden = false
        albumView.scrollToMiddle()
        UIView.animate(withDuration: 0.25) {
            self.albumBackgroudView.alpha = 1
            self.updateAlbumViewFrame()
            self.titleView.arrowView.transform = .init(rotationAngle: .pi)
        }
    }
    
    func closeAlbumView() {
        collectionView.scrollsToTop = true
        UIView.animate(withDuration: 0.25) {
            self.albumBackgroudView.alpha = 0
            self.updateAlbumViewFrame()
            self.titleView.arrowView.transform = .init(rotationAngle: .pi * 2)
        } completion: { (isFinish) in
            if self.albumBackgroudView.alpha == 0 {
                self.albumBackgroudView.isHidden = true
            }
        }
    }
    
    func updateAlbumViewFrame() {
        self.albumView.hx_size = CGSize(width: view.hx_width, height: getAlbumViewHeight())
        if titleView.isSelected {
            if self.navigationController?.modalPresentationStyle == UIModalPresentationStyle.fullScreen &&
                UIDevice.isPortrait {
                self.albumView.hx_y = UIDevice.navigationBarHeight
            }else {
                self.albumView.hx_y = self.navigationController?.navigationBar.hx_height ?? 0
            }
        }else {
            self.albumView.hx_y = -self.albumView.hx_height
        }
    }
    
    func getAlbumViewHeight() -> CGFloat {
        guard let picker = pickerController else { return 0}
        var albumViewHeight = CGFloat(albumView.assetCollectionsArray.count) * albumView.config.cellHeight
        if AssetManager.authorizationStatusIsLimited() &&
            picker.config.allowLoadPhotoLibrary {
            albumViewHeight += 40
        }
        if albumViewHeight > view.hx_height * 0.75 {
            albumViewHeight = view.hx_height * 0.75
        }
        return albumViewHeight
    }
    
    func albumView(
        _ albumView: AlbumView,
        didSelectRowAt assetCollection: PhotoAssetCollection
    ) {
        didAlbumBackgroudViewClick()
        if self.assetCollection == assetCollection {
            return
        }
        titleView.title = assetCollection.albumName
        assetCollection.isSelected = true
        self.assetCollection.isSelected = false
        self.assetCollection = assetCollection
        ProgressHUD.showLoading(
            addedTo: navigationController?.view,
            animated: true
        )
        fetchPhotoAssets()
    }
}
