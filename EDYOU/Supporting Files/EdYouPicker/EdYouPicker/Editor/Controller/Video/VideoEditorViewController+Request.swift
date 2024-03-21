//
//  VideoEditorViewController+Request.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/6.
//

import UIKit
import AVKit
import Photos

// MARK: PhotoAsset Request AVAsset
extension VideoEditorView {
//    #if HXPICKER_ENABLE_PICKER
    func requestAVAsset() {
        if photoAsset.isNetworkAsset {
            pNetworkVideoURL = photoAsset.networkVideoAsset?.videoURL
            downloadNetworkVideo()
            return
        }
        let loadingView = ProgressHUD.showLoading(addedTo: self, text: nil, animated: true)
        self.bringSubviewToFront(topView)
        assetRequestID = photoAsset.requestAVAsset(
            filterEditor: true,
            deliveryMode: .highQualityFormat
        ) { [weak self] (photoAsset, requestID) in
            self?.assetRequestID = requestID
            loadingView?.mode = .circleProgress
            loadingView?.text = "iCloud syncing".localized + "..."
        } progressHandler: { (photoAsset, progress) in
            if progress > 0 {
                loadingView?.progress = CGFloat(progress)
            }
        } success: { [weak self] (photoAsset, avAsset, info) in
            ProgressHUD.hide(forView: self, animated: false)
            self?.pAVAsset = avAsset
            self?.avassetLoadValuesAsynchronously()
//            self?.reqeustAssetCompletion = true
//            self?.assetRequestComplete()
        } failure: { [weak self] (photoAsset, info, error) in
            if let info = info, !info.isCancel {
                ProgressHUD.hide(forView: self, animated: false)
                if info.inICloud {
                    self?.assetRequestFailure(message: "iCloud sync failed".localized)
                }else {
                    self?.assetRequestFailure()
                }
            }
        }
    }
//    #endif
    
    func assetRequestFailure(message: String = "Video acquisition failed!".localized) {
//        PhotoTools.showConfirm(
//            viewController: self,
//            title: "Prompt".localized,
//            message: message,
//            actionTitle: "Done".localized
//        ) { (alertAction) in
//            self.backAction()
//        }
    }
    
    func assetRequestComplete() {
        let image = PhotoTools.getVideoThumbnailImage(avAsset: avAsset, atTime: 0.1)
        filterImageHandler(image: image)
        videoSize = image?.size ?? hx_size
        coverImage = image
        videoView.setAVAsset(avAsset, coverImage: image ?? .init())
        cropView.avAsset = avAsset
        if orientationDidChange {
            setCropViewFrame()
        }
        if !videoInitializeCompletion {
            setEditedSizeData()
            videoInitializeCompletion = true
        }
        if transitionCompletion {
            setAsset()
        }
    }
    
    func setEditedSizeData() {
        if let sizeData = editResult?.sizeData {
            videoView.setVideoEditedData(editedData: sizeData)
            brushColorView.canUndo = videoView.canUndoDraw
            if let stickerData = sizeData.stickerData {
                musicView.showLyricButton.isSelected = stickerData.showLyric
                if stickerData.showLyric {
                    otherMusic = stickerData.items[stickerData.LyricIndex].item.music
                }
            }
        }
    }
    
    func setAsset() {
        if setAssetCompletion {
            return
        }
        videoView.playerView.configAsset()
        if let editResult = editResult {
            hasOriginalSound = editResult.hasOriginalSound
            if hasOriginalSound {
                videoVolume = editResult.videoSoundVolume
            }else {
                videoView.playerView.player.volume = 0
            }
            volumeView.originalVolume = videoVolume
            musicView.originalSoundButton.isSelected = hasOriginalSound
            if let audioURL = editResult.backgroundMusicURL {
                backgroundMusicPath = audioURL.path
                musicView.backgroundButton.isSelected = true
                PhotoManager.shared.playMusic(filePath: audioURL.path) {
                }
                videoView.imageResizerView.imageView.stickerView.audioView?.contentView.startTimer()
                backgroundMusicVolume = editResult.backgroundMusicVolume
                volumeView.musicVolume = backgroundMusicVolume
            }
            if !orientationDidChange && editResult.cropData != nil {
                videoView.playerView.resetPlay()
                startPlayTimer()
            }
            if let videoFilter = editResult.sizeData?.filter,
               config.filter.isLoadLastFilter,
               videoFilter.index < config.filter.infos.count {
                let filterInfo = config.filter.infos[videoFilter.index]
                videoView.playerView.setFilter(filterInfo, parameters: videoFilter.parameters)
            }
            videoView.imageResizerView.videoFilter = editResult.sizeData?.filter
        }
        setAssetCompletion = true
    }
    
    func filterImageHandler(image: UIImage?) {
        guard let image = image else {
            return
        }
        var hasFilter = false
        var thumbnailImage: UIImage?
        for option in config.toolView.toolOptions where option.type == .filter {
            hasFilter = true
        }
        if hasFilter {
            DispatchQueue.global().async {
                thumbnailImage = image.scaleToFillSize(
                    size: CGSize(width: 80, height: 80),
                    equalRatio: true
                )
                if thumbnailImage == nil {
                    thumbnailImage = image
                }
                DispatchQueue.main.async {
                    self.filterView.image = thumbnailImage
                }
            }
        }
    }
}

// MARK: DownloadNetworkVideo
extension VideoEditorView {
    func downloadNetworkVideo() {
        if let videoURL = networkVideoURL {
            let key = videoURL.absoluteString
            if PhotoTools.isCached(forVideo: key) {
                let localURL = PhotoTools.getVideoCacheURL(for: key)
                pAVAsset = AVAsset.init(url: localURL)
                avassetLoadValuesAsynchronously()
                return
            }
            loadingView = ProgressHUD.showLoading(addedTo: self, text: "Video downloading".localized, animated: true)
            bringSubviewToFront(topView)
            PhotoManager.shared.downloadTask(
                with: videoURL
            ) { [weak self] (progress, task) in
                if progress > 0 {
                    self?.loadingView?.mode = .circleProgress
                    self?.loadingView?.progress = CGFloat(progress)
                }
            } completionHandler: { [weak self] (url, error, _) in
                if let url = url {
                    #if HXPICKER_ENABLE_PICKER
                    if let photoAsset = self?.photoAsset {
                        photoAsset.networkVideoAsset?.fileSize = url.fileSize
                    }
                    #endif
                    self?.loadingView = nil
                    ProgressHUD.hide(forView: self, animated: false)
                    self?.pAVAsset = AVAsset(url: url)
                    self?.avassetLoadValuesAsynchronously()
                }else {
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        return
                    }
                    self?.loadingView = nil
                    ProgressHUD.hide(forView: self, animated: false)
                    self?.assetRequestFailure()
                }
            }
        }
    }
    
    func avassetLoadValuesAsynchronously() {
        avAsset.loadValuesAsynchronously(
            forKeys: ["duration"]
        ) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.avAsset.statusOfValue(forKey: "duration", error: nil) != .loaded {
                    self.assetRequestFailure()
                    return
                }
                self.reqeustAssetCompletion = true
                self.assetRequestComplete()
            }
        }
    }
}
