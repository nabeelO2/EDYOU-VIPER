//
//  PhotoEditorViewController+Request.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/7/14.
//

import UIKit
#if canImport(Kingfisher)
import Kingfisher
#endif

extension PhotoEditorViewController {
//    #if HXPICKER_ENABLE_PICKER
    func requestImage() {
        if photoAsset().isLocalAsset {
            requestLocalAsset(photoAsset())
        }else if photoAsset().isNetworkAsset {
            requestNetworkAsset(photoAsset())
        } else {
            ProgressHUD.showLoading(addedTo: view, animated: true)
            if photoAsset().phAsset != nil && !photoAsset().isGifAsset {
                requestAssetData(photoAsset())
                return
            }
            requestAssetURL(photoAsset())
        }
    }
    func requestImages() {
        previewAssets.forEach { photoAsset in
            if photoAsset.isLocalAsset {
                requestLocalAsset(photoAsset)
            }else if photoAsset.isNetworkAsset {
                requestNetworkAsset(photoAsset)
            } else {
                ProgressHUD.showLoading(addedTo: view, animated: true)
                if photoAsset.phAsset != nil && !photoAsset.isGifAsset {
                    requestAssetData(photoAsset)
                    return
                }
                requestAssetURL(photoAsset)
            }
        }
        
    }
    
    func requestLocalAsset(_ photoAsset : PhotoAsset) {
        
        ProgressHUD.showLoading(addedTo: view, animated: true)
        DispatchQueue.global().async {
            if photoAsset.mediaType == .photo {
                var image: UIImage
                if let img = photoAsset.localImageAsset?.image {
                    image = img
                }else if let localLivePhoto = photoAsset.localLivePhoto,
                   let img = UIImage(contentsOfFile: localLivePhoto.imageURL.path) {
                    image = img
                }else {
                    image = UIImage()
                }
                image = self.fixImageOrientation(image)
                if photoAsset.mediaSubType.isGif {
                    if let imageData = photoAsset.localImageAsset?.imageData {
                        #if canImport(Kingfisher)
                        if let gifImage = DefaultImageProcessor.default.process(
                            item: .data(imageData),
                            options: .init([])
                        ) {
                            image = gifImage
                        }
                        #endif
                    }else if let imageURL = photoAsset.localImageAsset?.imageURL {
                        if let imageData = try? Data(contentsOf: imageURL) {
                            #if canImport(Kingfisher)
                            if let gifImage = DefaultImageProcessor.default.process(
                                item: .data(imageData),
                                options: .init([])
                            ) {
                                image = gifImage
                            }
                            #endif
                        }
                    }
                }
                self.filterHDImageHandler(image: image)
                DispatchQueue.main.async {
                    ProgressHUD.hide(forView: self.view, animated: true)
                    self.requestAssetCompletion(image: image)
                }
            }else {
                var image: UIImage
                if let img = photoAsset.localVideoAsset?.image {
                    image = img
                }else {
                    image = UIImage()
                }
                self.filterHDImageHandler(image: image)
                DispatchQueue.main.async {
                    ProgressHUD.hide(forView: self.view, animated: true)
                    self.requestAssetCompletion(image: image)
                }
            }
        }
    }
    func requestNetworkAsset(_ photoAsset : PhotoAsset) {
        #if canImport(Kingfisher)
        let loadingView = ProgressHUD.showLoading(addedTo: view, animated: true)
        photoAsset.getNetworkImage(urlType: .original, filterEditor: true) { (receiveSize, totalSize) in
            let progress = CGFloat(receiveSize) / CGFloat(totalSize)
            if progress > 0 {
                loadingView?.mode = .circleProgress
                loadingView?.text = "Picture downloading".localized
                loadingView?.progress = progress
            }
        } resultHandler: { [weak self] (image) in
            guard let self = self else { return }
            if var image = image {
                DispatchQueue.global().async {
                    image = self.fixImageOrientation(image)
                    self.filterHDImageHandler(image: image)
                    DispatchQueue.main.async {
                        ProgressHUD.hide(forView: self.view, animated: true)
                        self.requestAssetCompletion(image: image)
                    }
                }
            }else {
                ProgressHUD.hide(forView: self.view, animated: true)
                PhotoTools.showConfirm(
                    viewController: self,
                    title: "Prompt".localized,
                    message: "Image acquisition failed!".localized,
                    actionTitle: "Done".localized
                ) { (alertAction) in
                    self.didBackClick()
                }
            }
        }
        #endif
    }
    
    func requestAssetData(_ photoAsset : PhotoAsset) {
        photoAsset.requestImageData(
            filterEditor: true,
            iCloudHandler: nil,
            progressHandler: nil
        ) { [weak self] asset, result in
            guard let self = self else { return }
            switch result {
            case .success(let dataResult):
                DispatchQueue.global().async {
                    var image: UIImage?
                    let dataCount = CGFloat(dataResult.imageData.count)
                    if dataCount > 3000000 {
                        let compressionQuality: CGFloat
                        if dataCount > 30000000 {
                            compressionQuality = 30000000 / dataCount
                        }else if dataCount > 15000000 {
                            compressionQuality = 10000000 / dataCount
                        }else if dataCount > 10000000 {
                            compressionQuality = 6000000 / dataCount
                        }else {
                            compressionQuality = 3000000 / dataCount
                        }
                        if let imageData = PhotoTools.imageCompress(
                            dataResult.imageData,
                            compressionQuality: compressionQuality
                        ) {
                            image = .init(data: imageData)
                        }
                    }
                    if image == nil {
                        image = UIImage(data: dataResult.imageData)
                    }
                    guard var image = image else {
                        DispatchQueue.main.async {
                            ProgressHUD.hide(forView: self.view, animated: true)
                            self.requestAssetFailure(isICloud: false)
                        }
                        return
                    }
                    image = self.fixImageOrientation(image)
                    self.filterHDImageHandler(image: image)
                    DispatchQueue.main.async {
                        ProgressHUD.hide(forView: self.view, animated: true)
                        self.requestAssetCompletion(image: image)
                    }
                }
            case .failure(let error):
                ProgressHUD.hide(forView: self.view, animated: true)
                if let inICloud = error.info?.inICloud {
                    self.requestAssetFailure(isICloud: inICloud)
                }else {
                    self.requestAssetFailure(isICloud: false)
                }
            }
        }
    }
    
    func requestAssetURL(_ photoAsset : PhotoAsset) {
        photoAsset.requestAssetImageURL(
            filterEditor: true
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.global().async {
                    let imageURL = response.url
                    #if canImport(Kingfisher)
                    if photoAsset.isGifAsset == true,
                       let imageData = try? Data.init(contentsOf: imageURL) {
                        if let gifImage = DefaultImageProcessor.default.process(
                            item: .data(imageData),
                            options: .init([])
                        ) {
                            self.filterHDImageHandler(image: gifImage)
                            DispatchQueue.main.async {
                                ProgressHUD.hide(forView: self.view, animated: true)
                                self.requestAssetCompletion(image: gifImage)
                            }
                            return
                        }
                    }
                    #endif
                    if var image = UIImage.init(contentsOfFile: imageURL.path)?.scaleSuitableSize() {
                        image = self.fixImageOrientation(image)
                        self.filterHDImageHandler(image: image)
                        DispatchQueue.main.async {
                            ProgressHUD.hide(forView: self.view, animated: true)
                            self.requestAssetCompletion(image: image)
                        }
                        return
                    }
                }
            case .failure(_):
                ProgressHUD.hide(forView: self.view, animated: true)
                self.requestAssetFailure(isICloud: false)
            }
        }
    }
//    #endif
    
    #if canImport(Kingfisher)
    func requestNetworkImage() {
        let url = networkImageURL!
        let loadingView = ProgressHUD.showLoading(addedTo: view, animated: true)
        PhotoTools.downloadNetworkImage(with: url, options: [.backgroundDecode]) { (receiveSize, totalSize) in
            let progress = CGFloat(receiveSize) / CGFloat(totalSize)
            if progress > 0 {
                loadingView?.mode = .circleProgress
                loadingView?.text = "Picture downloading".localized
                loadingView?.progress = progress
            }
        } completionHandler: { [weak self] (image) in
            guard let self = self else { return }
            if let image = image {
                DispatchQueue.global().async {
                    self.filterHDImageHandler(image: image)
                    DispatchQueue.main.async {
                        ProgressHUD.hide(forView: self.view, animated: true)
                        self.requestAssetCompletion(image: image)
                    }
                }
            }else {
                self.requestAssetFailure(isICloud: false)
            }
        }
    }
    #endif
    
    func requestAssetCompletion(image: UIImage) {
        if !imageInitializeCompletion {
            imageView()?.setImage(image)
            filterView().image = filterImage()
            if let editedData = editResult?.editedData {
                imageView()?.setEditedData(editedData: editedData)
                if let imageView = imageView(){
                    brushColorView.canUndo = imageView.canUndoDraw
                    mosaicToolView.canUndo = imageView.canUndoMosaic
                }
                
            }
            imageInitializeCompletion = true
            if transitionCompletion {
                initializeStartCropping()
            }
        }
        setFilterImage(image)
        setImage(image)
        imageView()?.imageResizerView.imageView.originalImage = image
    }
    func requestAssetFailure(isICloud: Bool) {
        ProgressHUD.hide(forView: view, animated: true)
        let text = isICloud ? "iCloud sync failed".localized : "Image acquisition failed!".localized
        PhotoTools.showConfirm(
            viewController: self,
            title: "Prompt".localized,
            message: text.localized,
            actionTitle: "Done".localized
        ) { (alertAction) in
            self.didBackClick()
        }
    }
    func fixImageOrientation(_ image: UIImage) -> UIImage {
        var image = image
        if image.imageOrientation != .up,
           let nImage = image.normalizedImage() {
            image = nImage
        }
        return image
    }
    func filterHDImageHandler(image: UIImage) {
        if config[currentPreviewIndex].fixedCropState {
            guard let editedData = editResult?.editedData else {
                return
            }
            if editedData.mosaicData.isEmpty &&
               !editedData.hasFilter {
                return
            }
        }
        var hasMosaic = false
        var hasFilter = false
        for option in config[currentPreviewIndex].toolView.toolOptions {
            if option.type == .filter {
                hasFilter = true
            }else if option.type == .mosaic {
                hasMosaic = true
            }
        }
        if hasFilter || hasMosaic {
            var minSize: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            if hasFilter {
                DispatchQueue.main.sync {
                    if !view.hx_size.equalTo(.zero) {
                        minSize = min(view.hx_width, view.hx_height) * 2
                    }
                }
            }
            if image.width > minSize {
                let thumbnailScale = minSize / image.width
                if let _image = image.scaleImage(toScale: thumbnailScale){
                    thumbnailImages[currentPreviewIndex] = _image
                }
                else{
                    thumbnailImages[currentPreviewIndex] = image
                }
                
            }
            if thumbnailImages[currentPreviewIndex] == nil {
                thumbnailImages[currentPreviewIndex] = image
            }
        }
        
        if let result = editResult,
           let filterURL = result.editedData.filterImageURL,
           result.editedData.hasFilter,
           hasFilter {
            if let newImage = UIImage(contentsOfFile: filterURL.path) {
                filterHDImages?[currentPreviewIndex] = newImage
                if hasMosaic {
                    mosaicImage = newImage.mosaicImage(level: config[currentPreviewIndex].mosaic.mosaicWidth)
                }
            }
        }else {
            if hasMosaic {
                mosaicImage = thumbnailImage().mosaicImage(level: config[currentPreviewIndex].mosaic.mosaicWidth)
            }
        }
        if hasFilter {
            if let img = image.scaleToFillSize(size: CGSize(width: 80, height: 80), equalRatio: true){
                filterImages?[currentPreviewIndex] = img
            }
            
        }
    }
    func setFilterImage(_ image : UIImage) {
        
        filterViews[currentPreviewIndex].originalImage = image
        if let image = filterHDImage() {
            imageView()?.updateImage(image)
        }
        imageView()?.setMosaicOriginalImage(mosaicImage)
        filterView().image = filterImage()
       
    }
    func localImageHandler() {
        ProgressHUD.showLoading(addedTo: view, animated: true)
        DispatchQueue.global().async {
            self.filterHDImageHandler(image: self.image)
            DispatchQueue.main.async {
                ProgressHUD.hide(forView: self.view, animated: true)
                self.requestAssetCompletion(image: self.image)
            }
        }
    }
}



//MARK: - for video

//extension PhotoEditorViewController{
//
//    func requestAVAsset() {
//        if photoAsset().isNetworkAsset {
//            pNetworkVideoURL = photoAsset().networkVideoAsset?.videoURL
//            downloadNetworkVideo()
//            return
//        }
//        let loadingView = ProgressHUD.showLoading(addedTo: view, text: nil, animated: true)
//        view.bringSubviewToFront(topView)
//        assetRequestID = photoAsset().requestAVAsset(
//            filterEditor: true,
//            deliveryMode: .highQualityFormat
//        ) { [weak self] (photoAsset, requestID) in
//            self?.assetRequestID = requestID
//            loadingView?.mode = .circleProgress
//            loadingView?.text = "iCloud syncing".localized + "..."
//        } progressHandler: { (photoAsset, progress) in
//            if progress > 0 {
//                loadingView?.progress = CGFloat(progress)
//            }
//        } success: { [weak self] (photoAsset, avAsset, info) in
//            ProgressHUD.hide(forView: self?.view, animated: false)
//            self?.pAVAsset = avAsset
//            self?.avassetLoadValuesAsynchronously()
////            self?.reqeustAssetCompletion = true
////            self?.assetRequestComplete()
//        } failure: { [weak self] (photoAsset, info, error) in
//            if let info = info, !info.isCancel {
//                ProgressHUD.hide(forView: self?.view, animated: false)
//                if info.inICloud {
//                    self?.assetRequestFailure(message: "iCloud sync failed".localized)
//                }else {
//                    self?.assetRequestFailure()
//                }
//            }
//        }
//    }
////    #endif
//
//    func assetRequestFailure(message: String = "Video acquisition failed!".localized) {
//        PhotoTools.showConfirm(
//            viewController: self,
//            title: "Prompt".localized,
//            message: message,
//            actionTitle: "Done".localized
//        ) { (alertAction) in
//            self.backAction()
//        }
//    }
//
//    func assetRequestComplete() {
//        let image = PhotoTools.getVideoThumbnailImage(avAsset: avAsset, atTime: 0.1)
//        filterImageHandler(image: image)
//        videoSize = image?.size ?? view.hx_size
//        coverImage = image
//        videoView.setAVAsset(avAsset, coverImage: image ?? .init())
//        cropView.avAsset = avAsset
//        if orientationDidChange {
//            setCropViewFrame()
//        }
//        if !videoInitializeCompletion {
//            setEditedSizeData()
//            videoInitializeCompletion = true
//        }
//        if transitionCompletion {
//            setAsset()
//        }
//    }
//
//    func setEditedSizeData() {
//        if let sizeData = editResult?.sizeData {
//            videoView.setVideoEditedData(editedData: sizeData)
//            brushColorView.canUndo = videoView.canUndoDraw
//            if let stickerData = sizeData.stickerData {
//                musicView.showLyricButton.isSelected = stickerData.showLyric
//                if stickerData.showLyric {
//                    otherMusic = stickerData.items[stickerData.LyricIndex].item.music
//                }
//            }
//        }
//    }
//
//    func setAsset() {
//        if setAssetCompletion {
//            return
//        }
//        videoView.playerView.configAsset()
//        if let editResult = editResult {
//            hasOriginalSound = editResult.hasOriginalSound
//            if hasOriginalSound {
//                videoVolume = editResult.videoSoundVolume
//            }else {
//                videoView.playerView.player.volume = 0
//            }
//            volumeView.originalVolume = videoVolume
//            musicView.originalSoundButton.isSelected = hasOriginalSound
//            if let audioURL = editResult.backgroundMusicURL {
//                backgroundMusicPath = audioURL.path
//                musicView.backgroundButton.isSelected = true
//                PhotoManager.shared.playMusic(filePath: audioURL.path) {
//                }
//                videoView.imageResizerView.imageView.stickerView.audioView?.contentView.startTimer()
//                backgroundMusicVolume = editResult.backgroundMusicVolume
//                volumeView.musicVolume = backgroundMusicVolume
//            }
//            if !orientationDidChange && editResult.cropData != nil {
//                videoView.playerView.resetPlay()
//                startPlayTimer()
//            }
//            if let videoFilter = editResult.sizeData?.filter,
//               config.filter.isLoadLastFilter,
//               videoFilter.index < config.filter.infos.count {
//                let filterInfo = config.filter.infos[videoFilter.index]
//                videoView.playerView.setFilter(filterInfo, parameters: videoFilter.parameters)
//            }
//            videoView.imageResizerView.videoFilter = editResult.sizeData?.filter
//        }
//        setAssetCompletion = true
//    }
//
//    func filterImageHandler(image: UIImage?) {
//        guard let image = image else {
//            return
//        }
//        var hasFilter = false
//        var thumbnailImage: UIImage?
//        for option in config.toolView.toolOptions where option.type == .filter {
//            hasFilter = true
//        }
//        if hasFilter {
//            DispatchQueue.global().async {
//                thumbnailImage = image.scaleToFillSize(
//                    size: CGSize(width: 80, height: 80),
//                    equalRatio: true
//                )
//                if thumbnailImage == nil {
//                    thumbnailImage = image
//                }
//                DispatchQueue.main.async {
//                    self.filterView.image = thumbnailImage
//                }
//            }
//        }
//    }
//}
//
//// MARK: DownloadNetworkVideo
//extension PhotoEditorViewController {
//    func downloadNetworkVideo() {
//        if let videoURL = networkVideoURL {
//            let key = videoURL.absoluteString
//            if PhotoTools.isCached(forVideo: key) {
//                let localURL = PhotoTools.getVideoCacheURL(for: key)
//                pAVAsset = AVAsset.init(url: localURL)
//                avassetLoadValuesAsynchronously()
//                return
//            }
//            loadingView = ProgressHUD.showLoading(addedTo: view, text: "Video downloading".localized, animated: true)
//            view.bringSubviewToFront(topView)
//            PhotoManager.shared.downloadTask(
//                with: videoURL
//            ) { [weak self] (progress, task) in
//                if progress > 0 {
//                    self?.loadingView?.mode = .circleProgress
//                    self?.loadingView?.progress = CGFloat(progress)
//                }
//            } completionHandler: { [weak self] (url, error, _) in
//                if let url = url {
//                    #if HXPICKER_ENABLE_PICKER
//                    if let photoAsset = self?.photoAsset() {
//                        photoAsset.networkVideoAsset?.fileSize = url.fileSize
//                    }
//                    #endif
//                    self?.loadingView = nil
//                    ProgressHUD.hide(forView: self?.view, animated: false)
//                    self?.pAVAsset = AVAsset(url: url)
//                    self?.avassetLoadValuesAsynchronously()
//                }else {
//                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
//                        return
//                    }
//                    self?.loadingView = nil
//                    ProgressHUD.hide(forView: self?.view, animated: false)
//                    self?.assetRequestFailure()
//                }
//            }
//        }
//    }
//
//    func avassetLoadValuesAsynchronously() {
//        avAsset.loadValuesAsynchronously(
//            forKeys: ["duration"]
//        ) { [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if self.avAsset.statusOfValue(forKey: "duration", error: nil) != .loaded {
//                    self.assetRequestFailure()
//                    return
//                }
//                self.reqeustAssetCompletion = true
//                self.assetRequestComplete()
//            }
//        }
//    }
//}
//
