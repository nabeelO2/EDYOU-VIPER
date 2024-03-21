//
//  PhotoEditorViewController+Bottom.swift
//  ustories
//
//  Created by imac3 on 14/06/2023.
//

import Foundation

import UIKit

// MARK: PhotoPickerBottomViewDelegate
extension PhotoEditorViewController: PhotoPickerBottomViewDelegate {
    
    func bottomView(didEditButtonClick bottomView: PhotoPickerBottomView) {
        guard let photoAsset = photoAsset(for: currentPreviewIndex) else {
            return
        }
       // openEditor(photoAsset)
    }
    
    func openEditor(_ photoAsset: PhotoAsset) {
//        guard let picker = pickerController else { return }
//        let shouldEditAsset = picker.shouldEditAsset(
//            photoAsset: photoAsset,
//            atIndex: currentPreviewIndex
//        )
//        if !shouldEditAsset {
//            return
//        }
////        #if HXPICKER_ENABLE_EDITOR && HXPICKER_ENABLE_PICKER
//        beforeNavDelegate = navigationController?.delegate
//        let pickerConfig = picker.config
//        if photoAsset.mediaType == .video && pickerConfig.editorOptions.isVideo {
//            let cell = getCell(
//                for: currentPreviewIndex
//            )
//            cell?.scrollContentView.stopVideo()
//            let videoEditorConfig: VideoEditorConfiguration
//            let isExceedsTheLimit = picker.videoDurationExceedsTheLimit(
//                photoAsset: photoAsset
//            )
//            if isExceedsTheLimit {
//                videoEditorConfig = pickerConfig.videoEditor.mutableCopy() as! VideoEditorConfiguration
//                videoEditorConfig.defaultState = .cropTime
//                videoEditorConfig.mustBeTailored = true
//            }else {
//                videoEditorConfig = pickerConfig.videoEditor
//            }
//            if !picker.shouldEditVideoAsset(
//                videoAsset: photoAsset,
//                editorConfig: videoEditorConfig,
//                atIndex: currentPreviewIndex
//            ) {
//                return
//            }
//            if let shouldEdit = delegate?.previewViewController(
//                self,
//                shouldEditVideoAsset: photoAsset,
//                editorConfig: videoEditorConfig
//            ), !shouldEdit {
//                return
//            }
//            videoEditorConfig.languageType = pickerConfig.languageType
//            videoEditorConfig.appearanceStyle = pickerConfig.appearanceStyle
//            videoEditorConfig.indicatorType = pickerConfig.indicatorType
//            let videoEditorVC = VideoEditorViewController(
//                photoAsset: photoAsset,
//                editResult: photoAsset.videoEdit,
//                config: videoEditorConfig
//            )
//            videoEditorVC.coverImage = cell?.scrollContentView.imageView.image
//            videoEditorVC.delegate = self
//            if pickerConfig.editorCustomTransition {
//                navigationController?.delegate = videoEditorVC
//            }
//            navigationController?.pushViewController(
//                videoEditorVC,
//                animated: true
//            )
//        }else if pickerConfig.editorOptions.isPhoto {
//            let photoEditorConfig = pickerConfig.photoEditor
//            if !picker.shouldEditPhotoAsset(
//                photoAsset: photoAsset,
//                editorConfig: photoEditorConfig,
//                atIndex: currentPreviewIndex
//            ) {
//                return
//            }
//            if let shouldEdit = delegate?.previewViewController(
//                self,
//                shouldEditPhotoAsset: photoAsset,
//                editorConfig: photoEditorConfig
//            ), !shouldEdit {
//                return
//            }
//            photoEditorConfig.languageType = pickerConfig.languageType
//            photoEditorConfig.appearanceStyle = pickerConfig.appearanceStyle
//            photoEditorConfig.indicatorType = pickerConfig.indicatorType
//            let photoEditorVC = PhotoEditorViewController(
//                photoAsset: photoAsset,
//                editResult: photoAsset.photoEdit,
//                config: photoEditorConfig
//            )
//            photoEditorVC.delegate = self
//            if pickerConfig.editorCustomTransition {
//                navigationController?.delegate = photoEditorVC
//            }
//            navigationController?.pushViewController(
//                photoEditorVC,
//                animated: true
//            )
//        }
//        #endif
    }
    func bottomView(
        didFinishButtonClick bottomView: PhotoPickerBottomView
    ) {
        guard let pickerController = pickerController else {
            return
        }
        if !pickerController.selectedAssetArray.isEmpty {
//            delegate?.previewViewController(didFinishButton: self)
            pickerController.finishCallback()
            return
        }
        if assetCount == 0 {
            ProgressHUD.showWarning(
                addedTo: view,
                text: "No optional resources".localized,
                animated: true,
                delayHide: 1.5
            )
            return
        }
        guard let photoAsset = photoAsset(for: currentPreviewIndex) else {
            return
        }
//        #if HXPICKER_ENABLE_EDITOR
        if photoAsset.mediaType == .video &&
            pickerController.videoDurationExceedsTheLimit(photoAsset: photoAsset) &&
            pickerController.config.editorOptions.isVideo {
            if pickerController.canSelectAsset(
                for: photoAsset,
                showHUD: true
            ) {
                openEditor(photoAsset)
            }
            return
        }
//        #endif
        func addAsset() {
            if !isMultipleSelect {
                if pickerController.canSelectAsset(
                    for: photoAsset,
                    showHUD: true
                ) {
                    if isExternalPickerPreview {
//                        delegate?.previewViewController(
//                            self,
//                            didSelectBox: photoAsset,
//                            isSelected: true,
//                            updateCell: false
//                        )
                    }
//                    delegate?.previewViewController(didFinishButton: self)
                    pickerController.singleFinishCallback(
                        for: photoAsset
                    )
                }
            }else {
                if videoLoadSingleCell {
                    if pickerController.canSelectAsset(
                        for: photoAsset,
                        showHUD: true
                    ) {
                        if isExternalPickerPreview {
//                            delegate?.previewViewController(
//                                self,
//                                didSelectBox: photoAsset,
//                                isSelected: true,
//                                updateCell: false
//                            )
                        }
//                        delegate?.previewViewController(didFinishButton: self)
                        pickerController.singleFinishCallback(
                            for: photoAsset
                        )
                    }
                }else {
                    if pickerController.addedPhotoAsset(
                        photoAsset: photoAsset
                    ) {
                        if isExternalPickerPreview {
//                            delegate?.previewViewController(
//                                self,
//                                didSelectBox: photoAsset,
//                                isSelected: true,
//                                updateCell: false
//                            )
                        }
//                        delegate?.previewViewController(didFinishButton: self)
                        pickerController.finishCallback()
                    }
                }
            }
        }
        let inICloud = photoAsset.checkICloundStatus(
            allowSyncPhoto: pickerController.config.allowSyncICloudWhenSelectPhoto
        ) { _, isSuccess in
            if isSuccess {
                addAsset()
            }
        }
        if !inICloud {
            addAsset()
        }
    }
    func bottomView(
        _ bottomView: PhotoPickerBottomView,
        didOriginalButtonClick isOriginal: Bool
    ) {
//        delegate?.previewViewController(
//            self,
//            didOriginalButton: isOriginal
//        )
//        pickerController?.originalButtonCallback()
    }
    func bottomView(
        _ bottomView: PhotoPickerBottomView,
        didSelectedItemAt photoAsset: PhotoAsset
    ) {
        if previewAssets.contains(photoAsset) {
            scrollToPhotoAsset(photoAsset)
        }else {
          //  bottomView.selectedView.scrollTo(photoAsset: nil)
        }
    }
    func setupRequestPreviewTimer() {
//        requestPreviewTimer?.invalidate()
//        requestPreviewTimer = Timer(
//            timeInterval: 0.2,
//            target: self,
//            selector: #selector(delayRequestPreview),
//            userInfo: nil,
//            repeats: false
//        )
//        RunLoop.main.add(
//            requestPreviewTimer!,
//            forMode: RunLoop.Mode.common
//        )
    }
    @objc func delayRequestPreview() {
//        if let cell = getCell(for: currentPreviewIndex) {
//            cell.requestPreviewAsset()
//            requestPreviewTimer = nil
//        }else {
//            if assetCount == 0 {
//                requestPreviewTimer = nil
//                return
//            }
//            setupRequestPreviewTimer()
//        }
    }
    
    public func setOriginal(_ isOriginal: Bool) {
//        bottomView.boxControl.isSelected =  isOriginal
//        if !isOriginal {
//            // 取消
//            bottomView.cancelRequestAssetFileSize()
//        }else {
//            // 选中
//            bottomView.requestAssetBytes()
//        }
//        pickerController?.isOriginal = isOriginal
//        pickerController?.originalButtonCallback()
//        delegate?.previewViewController(
//            self,
//            didOriginalButton: isOriginal
//        )
    }
    
    func scrollToPhotoAsset(_ photoAsset: PhotoAsset) {
        guard let index = previewAssets.firstIndex(of: photoAsset) else {
            return
        }
        scrollToItem(index,photoAsset)
    }
    func scrollToItem(_ item: Int, _ photoAsset: PhotoAsset ) {
        if item == currentPreviewIndex {
            return
        }
        //getCell(for: currentPreviewIndex)?.cancelRequest()
        changeCurrentAsset(item, photoAsset)
//        collectionView.scrollToItem(
//            at: IndexPath(item: item, section: 0),
//            at: .centeredHorizontally,
//            animated: false
//        )
//        setupRequestPreviewTimer()
    }
    
    func openVideoEditor(
        photoAsset: PhotoAsset,
        parentView : UIView,
        coverImage: UIImage? = nil,
        animated: Bool = true
    ) -> Bool {
        guard let pickerController = pickerController,
              photoAsset.mediaType == .video else {
            openVideoEditorWithoutPicker(photoAsset: photoAsset, parentView: parentView)
            return false
        }
        let editIndex = previewAssets.firstIndex(of: photoAsset) ?? 0
        if !pickerController.shouldEditAsset(photoAsset: photoAsset, atIndex: editIndex) {
            return false
        }
//        #if HXPICKER_ENABLE_EDITOR && HXPICKER_ENABLE_PICKER
        if pickerController.config.editorOptions.contains(.video) {
            let isExceedsTheLimit = pickerController.videoDurationExceedsTheLimit(photoAsset: photoAsset)
            let config: VideoEditorConfiguration
            if isExceedsTheLimit {
                config = pickerController.config.videoEditor.mutableCopy() as! VideoEditorConfiguration
                config.defaultState = .cropTime
                config.cropTime.maximumVideoCroppingTime = TimeInterval(
                    pickerController.config.maximumSelectedVideoDuration
                )
                config.mustBeTailored = true
            }else {
                config = pickerController.config.videoEditor
            }
            if !pickerController.shouldEditVideoAsset(
                videoAsset: photoAsset,
                editorConfig: config,
                atIndex: editIndex
            ) {
                return false
            }
            config.languageType = pickerController.config.languageType
            config.appearanceStyle = pickerController.config.appearanceStyle
            config.indicatorType = pickerController.config.indicatorType
            let videoEditorVC = VideoEditorView(
                photoAsset: photoAsset,
                editResult: photoAsset.videoEdit,
                config: config
            )
            videoEditorVC.coverImage = coverImage
//            videoEditorVC.delegate = self
            videoEditorVC.backgroundColor = .gray
            videoEditorVC.photoAsset = photoAsset
            videoEditorVC.editResult = photoAsset.videoEdit
            videoEditorVC.config = config
            videoEditorVC.viewDidLoad()
            videoEditorVC.frame = parentView.bounds
            videoEditorVC.parentVC = self
            parentView.addSubview(videoEditorVC)
            parentView.isHidden = false
            parentView.clipsToBounds = true
            videoEditorVC.bottomMenuHiddenHandler = { res in
                if res{
//                    UIView.animate(withDuration: 0.25) {
                        self.bottomBGV.isHidden = false
//                    }

                }
                else{

//                    UIView.animate(withDuration: 0.25) {
//
//                    } completion: { (isFinished) in

                        self.bottomBGV.isHidden = true

//                    }
                    
                }
            }
            videoEditorVC.videoEditedResult = { res in
                if let res = res{
                    
                    self.editedResults.append(res)
                }
                else{
                    self.editedResults.append("original image")
                }
               
            }
//            videoEditorVC.backgroundColor = .blue
            videoEditorVC.backButtonHandler = {
                self.didBackClick(true)
            }
//            if pickerController.config.editorCustomTransition {
//                navigationController?.delegate = videoEditorVC
//            }
//            navigationController?.pushViewController(videoEditorVC, animated: animated)
            return true
        }
//        #endif
        return false
    }
    
    func openVideoEditorWithoutPicker(
        photoAsset: PhotoAsset,
        parentView : UIView,
        coverImage: UIImage? = nil,
        animated: Bool = true
    ){
        
//        let isExceedsTheLimit = pickerController.videoDurationExceedsTheLimit(photoAsset: photoAsset)
        let config: VideoEditorConfiguration
//        if isExceedsTheLimit {
//            config = pickerController.config.videoEditor.mutableCopy() as! VideoEditorConfiguration
//            config.defaultState = .cropTime
//            config.cropTime.maximumVideoCroppingTime = TimeInterval(
//                pickerController.config.maximumSelectedVideoDuration
//            )
//            config.mustBeTailored = true
//        }
//        else {
            config = VideoEditorConfiguration()
//        }
//        if !pickerController.shouldEditVideoAsset(
//            videoAsset: photoAsset,
//            editorConfig: config,
//            atIndex: editIndex
//        ) {
//            return false
//        }
        
//        config.languageType = pickerController.config.languageType
//        config.appearanceStyle = pickerController.config.appearanceStyle
//        config.indicatorType = pickerController.config.indicatorType
        let videoEditorVC = VideoEditorView(
            photoAsset: photoAsset,
            editResult: photoAsset.videoEdit,
            config: config
        )
        videoEditorVC.coverImage = coverImage
//            videoEditorVC.delegate = self
        videoEditorVC.backgroundColor = .gray
        videoEditorVC.photoAsset = photoAsset
        videoEditorVC.editResult = photoAsset.videoEdit
        videoEditorVC.config = config
        videoEditorVC.viewDidLoad()
        videoEditorVC.frame = parentView.bounds
        videoEditorVC.parentVC = self
        parentView.addSubview(videoEditorVC)
        parentView.isHidden = false
        parentView.clipsToBounds = true
        videoEditorVC.bottomMenuHiddenHandler = { res in
            if res{
//                    UIView.animate(withDuration: 0.25) {
                    self.bottomBGV.isHidden = false
//                    }

            }
            else{

//                    UIView.animate(withDuration: 0.25) {
//
//                    } completion: { (isFinished) in

                    self.bottomBGV.isHidden = true

//                    }
                
            }
        }
        videoEditorVC.videoEditedResult = { res in
            if let res = res{
                self.editedResults.append(res)
            }
            else{
                self.editedResults.append("original image")
            }
           
        }
//            videoEditorVC.backgroundColor = .blue
        videoEditorVC.backButtonHandler = {
            self.didBackClick(true)
        }
    }
    func changeCurrentAsset(_ item: Int,_ photoAsset: PhotoAsset){
       // self.photoAsset = photoAsset
        self.brushColorView.isHidden = true
        self.brushBlockView.isHidden = true
        self.mosaicToolView.isHidden = true
        self.deselectedDraw()
//        PhotoManager.shared.appearanceStyle = config[currentPreviewIndex].appearanceStyle
//        PhotoManager.shared.createLanguageBundle(languageType: config[currentPreviewIndex].languageType)
//        sourceType = .picker
//        requestType = 1
//        needRequest = true
        
//        self.editResult = editResult
//        self.previewAssets[currentPreviewIndex] = photoAsset
        self.configPreview = PreviewViewConfiguration()
//        requestLocalAsset()
//        editorToolView().isHidden = true
        
        currentPreviewIndex = item
        
        
       // cropToolView().resetSelected()
        
        if photoAsset.mediaType == .photo{
            
            topView.isHidden = false
            editorToolView().isHidden = false
//            viewDidLayoutSubviews()
//            videoPreviewView.isHidden = true
            if imageView()?.imageResizerView.imageView.image == nil{
                //add image first time
                if self.photoAsset().phAsset != nil && !self.photoAsset().isGifAsset {
                    imageInitializeCompletion = false
                    requestAssetData(self.photoAsset())
                    return
                }
            }
        }
        else{
            imageViews.forEach { imgV in
                imgV.isHidden = true
            }
            editorToolView().isHidden = true
            topView.isHidden = true
//            imageViews[currentPreviewIndex].isHidden = false
            if imageViews[currentPreviewIndex].subviews.count > 0{
                
                imageViews[currentPreviewIndex].subviews.forEach { view in
                    if ((view as? VideoEditorView) != nil){
                        imageViews[currentPreviewIndex].isHidden = false
                    }
                    else{
                        openVideoEditor(photoAsset: photoAsset, parentView: imageViews[currentPreviewIndex])
                    }
                }
            }
            else{
                
                openVideoEditor(photoAsset: photoAsset, parentView: imageViews[currentPreviewIndex])
            }
            
                
            
            
            
            
//            videoPreviewView.isHidden = false
            
        }
    }
}




extension PhotoEditorViewController : PhotoEditorPreviewDelegate {
    func bottomView(didSelectedItemAt photoAsset: PhotoAsset) {
        if previewAssets.contains(photoAsset) {
            scrollToPhotoAsset(photoAsset)
        }else {
            //bottomView.selectedView.scrollTo(photoAsset: nil)
        }
    }
}
