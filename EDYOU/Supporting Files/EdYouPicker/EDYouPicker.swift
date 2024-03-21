    //
    //  EDYouPicker.swift
    //  ustories
    //
    //  Created by imac3 on 27/06/2023.
    //
import Foundation
import UIKit
import AVFoundation


class EDYouPicker: NSObject {
    
        //MARK: - Properties
    var giphyAPIKey = "ed6EUc4F8JfF60NrwOXSeBYMAlNm02Vx"
    
    
    
        //MARK: - Signleton
    static var shared = EDYouPicker()
    var mediaFiles = [MediaHX]()
    var addText :[String : Any]?
    private override init() { super.init() }
    var group = DispatchGroup()
        //MARK: - Methods
    
    private func setupConfigs() -> PickerConfiguration {
        let config = PhotoTools.getWXPickerConfig()
            //MARK: Add configurationChanges here
        config.maximumSelectedCount = 10
        config.maximumSelectedVideoDuration = 60
        return config
    }
    
    
    func openPicker(from controller: UIViewController, didProcessingStart: @escaping (_ isStarted: Bool, _ elementCount:Int) -> Void, completion: @escaping (_ results: [Any]?,_ addText: [String : Any]?) -> Void)
    {
    mediaFiles.removeAll()
    addText = nil
    let config = setupConfigs()
    
    Photo.picker(
        config
        
    ) { [weak self] results, pickerController in
        guard let self = self else {return}
        didProcessingStart(true,results.count)
        results.enumerated().forEach({ index,result in
            if let text = result as? [String : Any] {
                self.addText = text
            } else if var photoEdit = result as? PhotoEditorView{
                self.group.enter()
                photoEdit.tag = index
                print(" photoEdit edit \(photoEdit)")
                self.exportResources(photoEdit)
            }
            else if let firstView = result as? UIView, let videoEdit = firstView.subviews.first as? VideoEditorView{
                self.group.enter()
                videoEdit.tag = index
                print(" video edit \(videoEdit)")
                self.exportVideoResources(videoEditorView: videoEdit)
            }
            else{
                print("video not found")
            }
            
        })
        
        group.notify(queue: .main) { [weak self]  in

            guard let self = self else {return}
//            didProcessingStart(false,mediaFiles.count)
            completion(self.mediaFiles, self.addText)
            print("group notify")
        }
        
            //            var mediaFiles = [MediaHX]()
            //            var addText : [String : Any]?
        
            //            results.forEach { result in
            //
            //                if let photoEdit = result as? PhotoEditorView{
            //                    print(" photo edit ")
            //
            //                }
            //                else if let videoEdit = result as? VideoEditorView{
            //                    print(" video edit ")
            //                }
        
            //                if let photoEdit = result as? PhotoEditResult{
            //                    let img = photoEdit.editedImage
            //                    print(img)
            //                    if let media = MediaHX(withImage: img,key: "images",mediaImage: img){
            //                        mediaFiles.append(media)
            //                    }
            //
            //                }
            //                else if let videoEdit = result as? VideoEditResult{
            //                    let video = videoEdit.editedURL
            //                    print(video)
            //                    let data = try! Data(contentsOf: video)
            //                    let thumbImage = videoEdit.coverImage
            //                    let url = videoEdit.editedURL
            //                    let media = MediaHX(withData: data,key: "videos", mimeType: .video,thumbnailImage: thumbImage,videoURL: url)
            //                        mediaFiles.append(media)
            //
            //                }
            //                else if let addTextParam = result as? [String : Any] {//text a
            //                    addText = addTextParam
            //                }
            //            }
        
        
        
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        
            //            }
        
    } cancel: { pickerController in
        
    }
    
    
    
    }
    
    private func exportResources(_ imageView :PhotoEditorView ) {
        print("ProcessingStart",imageView.tag)
        if imageView.canReset() ||
            imageView.imageResizerView.hasCropping ||
            imageView.canUndoDraw ||
            imageView.canUndoMosaic ||
            imageView.hasFilter ||
            imageView.hasSticker {
            imageView.deselectedSticker()
            imageView.cropping { [weak self] in
                guard let self = self else {
                    self?.group.leave()
                    print("ProcessingEnd",imageView.tag,self)
                    return
                }
               
                if let result = $0 {
                    let img = result.editedImage
                    print(img)
                    
                    if let media = MediaHX(withImage: img,key: "images",mediaImage: img){
                        mediaFiles.append(media)
                    }
                    self.group.leave()
                    print("ProcessingEnd",imageView.tag,self)
                }
            }
        } else {
            imageView.cropping { [weak self] result in
                guard let self = self else {
                    self?.group.leave()
                    print("ProcessingEnd",imageView.tag,self)
                    return
                }
                if let res = result{
                    let img = res.editedImage
                    
                    if let media = MediaHX(withImage: img,key: "images",mediaImage: img){
                        mediaFiles.append(media)
                    }
                    self.group.leave()
                    print("ProcessingEnd",imageView.tag,self)
                }
                else {
                    guard  let img = imageView.imageResizerView.imageView.originalImage else {
                        self.group.leave()
                        print("ProcessingEnd",imageView.tag,self)
                        return
                    }
                    if let media = MediaHX(withImage: img,key: "images",mediaImage: img){
                        mediaFiles.append(media)
                    }
                    group.leave()
                    print("ProcessingEnd",imageView.tag,self)
                }
            }
        }
    }
    
    func exportVideoResources(videoEditorView : VideoEditorView) {
        let toolView = videoEditorView.toolView
        let videoView = videoEditorView.videoView
        videoView.deselectedSticker()
        let timeRang: CMTimeRange
        if let startTime = videoView.playerView.playStartTime,
           let endTime = videoView.playerView.playEndTime {
            if endTime.seconds - startTime.seconds > videoEditorView.config.cropTime.maximumVideoCroppingTime {
                let seconds = Double(videoEditorView.config.cropTime.maximumVideoCroppingTime)
                timeRang = CMTimeRange(
                    start: startTime,
                    duration: CMTime(
                        seconds: seconds,
                        preferredTimescale: endTime.timescale
                    )
                )
            }else {
                timeRang = CMTimeRange(start: startTime, end: endTime)
            }
        }else {
            timeRang = .zero
        }
        
        let hasCropSize: Bool
        if videoView.canReset() ||
            videoView.imageResizerView.hasCropping ||
            videoView.canUndoDraw ||
            videoView.hasFilter ||
            videoView.hasSticker ||
            videoView.imageResizerView.videoFilter != nil {
            hasCropSize = true
        }else {
            hasCropSize = false
        }
        
        exportVideoURL(
            videoEditorView: videoEditorView, timeRang: timeRang,
            hasCropSize: hasCropSize,
            cropSizeData: videoView.getVideoCropData()
        )
        
    }
    func exportVideoURL(
        videoEditorView : VideoEditorView,
        timeRang: CMTimeRange,
        hasCropSize: Bool,
        cropSizeData: VideoEditorCropSizeData
    ) {
        videoEditorView.avAsset.loadValuesAsynchronously(
            forKeys: ["tracks"]
        ) { [weak self] in
            guard let self = self else {
                self?.group.leave()
                
                return
                
            }
//            DispatchQueue.global().async {
                if videoEditorView.avAsset.statusOfValue(forKey: "tracks", error: nil) != .loaded {
                    self.group.leave()
                    return
                }
                var audioURL: URL?
                if let musicPath = videoEditorView.backgroundMusicPath {
                    audioURL = URL(fileURLWithPath: musicPath)
                }
                let urlConfig: EditorURLConfig
                if let config = videoEditorView.config.videoURLConfig {
                    urlConfig = config
                }else {
                    urlConfig = .init(fileName: String.fileName(suffix: "mp4"), type: .temp)
                }
                PhotoTools.getVideoTmpURL()
                PhotoTools.exportEditVideo(
                    for: videoEditorView.avAsset,
                    outputURL: urlConfig.url,
                    timeRang: timeRang,
                    cropSizeData: cropSizeData,
                    audioURL: audioURL,
                    audioVolume: videoEditorView.backgroundMusicVolume,
                    originalAudioVolume: videoEditorView.hasOriginalSound ? videoEditorView.videoVolume : 0,
                    exportPreset: videoEditorView.config.exportPreset,
                    videoQuality: videoEditorView.config.videoQuality
                ) {  [weak self] videoURL, error in
                    if videoURL != nil {
//                        ProgressHUD.hide(forView: self, animated: true)
                        self?.editFinishCallBack(videoEditorView: videoEditorView, urlConfig)
//                        self?.backAction()
                    }else {
                        self?.group.leave()
                        return
//                        videoEditorView.showErrorHUD()
//                        if let action = videoEditorView.videoEditedResult{
//                            action(nil)
//                        }
                    }
                }
        }
    }
    
    func editFinishCallBack(videoEditorView : VideoEditorView,_ urlConfig: EditorURLConfig) {
        if let currentCropOffset = videoEditorView.currentCropOffset {
            videoEditorView.rotateBeforeStorageData = videoEditorView.cropView.getRotateBeforeData(
                offsetX: currentCropOffset.x,
                validX: videoEditorView.currentValidRect.minX,
                validWidth: videoEditorView.currentValidRect.width
            )
        }
        videoEditorView.rotateBeforeData = videoEditorView.cropView.getRotateBeforeData()
        var cropData: VideoCropData?
        if let startTime = videoEditorView.videoView.playerView.playStartTime,
           let endTime = videoEditorView.videoView.playerView.playEndTime,
           let rotateBeforeStorageData = videoEditorView.rotateBeforeStorageData,
           let rotateBeforeData = videoEditorView.rotateBeforeData {
            cropData = VideoCropData(
                startTime: startTime.seconds,
                endTime: endTime.seconds,
                preferredTimescale: videoEditorView.avAsset.duration.timescale,
                cropingData: .init(
                    offsetX: rotateBeforeStorageData.0,
                    validX: rotateBeforeStorageData.1,
                    validWidth: rotateBeforeStorageData.2
                ),
                cropRectData: .init(
                    offsetX: rotateBeforeData.0,
                    validX: rotateBeforeData.1,
                    validWidth: rotateBeforeData.2
                )
            )
        }
        var backgroundMusicURL: URL?
        if let audioPath = videoEditorView.backgroundMusicPath {
            backgroundMusicURL = URL(fileURLWithPath: audioPath)
        }
        let editResult = VideoEditResult(
            urlConfig: urlConfig,
            cropData: cropData,
            hasOriginalSound: videoEditorView.hasOriginalSound,
            videoSoundVolume: videoEditorView.videoVolume,
            backgroundMusicURL: backgroundMusicURL,
            backgroundMusicVolume: videoEditorView.backgroundMusicVolume,
            sizeData: videoEditorView.videoView.getVideoEditedData()
        )
//        delegate?.videoEditorViewController(self, didFinish: editResult)
//        finishHandler?(self, editResult)
        
        let video = editResult.editedURL
        print(video)
        let data = try! Data(contentsOf: video)
        let thumbImage = editResult.coverImage
        let url = editResult.editedURL
        let media = MediaHX(withData: data,key: "videos", mimeType: .video,thumbnailImage: thumbImage,videoURL: url)
        DispatchQueue.main.async {
            self.mediaFiles.append(media)
            self.group.leave()
        }
        
        
        
    }
    
}
