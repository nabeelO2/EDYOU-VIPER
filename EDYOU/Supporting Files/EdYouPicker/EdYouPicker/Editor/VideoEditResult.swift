//
//  VideoEditResult.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/3/8.
//

import UIKit
import AVFoundation

public struct VideoEditResult {
    
    /// Edited video address
    public var editedURL: URL {
        urlConfig.url
    }
    
    public let urlConfig: EditorURLConfig
    
    /// Edited video cover
    public let coverImage: UIImage?

    /// Edited video size
    public let editedFileSize: Int
    
    /// Video duration format: 00:00
    public let videoTime: String
    
    /// Video duration seconds
    public let videoDuration: TimeInterval
    
    /// Is there original video music
    public let hasOriginalSound: Bool
    
    /// Original video volume
    public let videoSoundVolume: Float
    
    /// background music address
    public let backgroundMusicURL: URL?
    
    /// background music volume
    public let backgroundMusicVolume: Float
    
    /// Duration Clipping Data
    public let cropData: VideoCropData?
    
    /// Size cropping status data
    let sizeData: VideoEditedCropSize?
    
    init(
        urlConfig: EditorURLConfig,
        cropData: VideoCropData?,
        hasOriginalSound: Bool,
        videoSoundVolume: Float,
        backgroundMusicURL: URL?,
        backgroundMusicVolume: Float,
        sizeData: VideoEditedCropSize?
    ) {
        self.urlConfig = urlConfig
        editedFileSize = urlConfig.url.hx_fileSize
        
        videoDuration = PhotoTools.getVideoDuration(videoURL: urlConfig.url)
        videoTime = PhotoTools.transformVideoDurationToString(duration: videoDuration)
        coverImage = PhotoTools.getVideoThumbnailImage(videoURL: urlConfig.url, atTime: 0.1)
        self.cropData = cropData
        self.hasOriginalSound = hasOriginalSound
        self.videoSoundVolume = videoSoundVolume
        self.backgroundMusicURL = backgroundMusicURL
        self.backgroundMusicVolume = backgroundMusicVolume
        self.sizeData = sizeData
    }
}

public struct VideoCropData: Codable {
    
    /// Edit start time
    public let startTime: TimeInterval
    
    /// edit end time
    public let endTime: TimeInterval
    
    public let preferredTimescale: Int32
    
    /// Already determined clipping data
    /// 0：offsetX ，CollectionView offset.x
    /// 1：validX ，The x of the crop box
    /// 2：validWidth ，The width of the crop box
    let cropingData: CropData
    
    /// The position and size ratio of the cropping box
    /// 0：offsetX ，CollectionView的offset.x
    /// 1：validX ，The x of the crop box
    /// 2：validWidth ，The width of the crop box
    let cropRectData: CropData
    
    init(
        startTime: TimeInterval,
        endTime: TimeInterval,
        preferredTimescale: Int32,
        cropingData: CropData,
        cropRectData: CropData
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.preferredTimescale = preferredTimescale
        self.cropingData = cropingData
        self.cropRectData = cropRectData
    }
    
    struct CropData: Codable {
        let offsetX: CGFloat
        let validX: CGFloat
        let validWidth: CGFloat
    }
}

struct VideoEditedCropSize: Codable {
    let isPortrait: Bool
    let cropData: PhotoEditCropData?
    let brushData: [PhotoEditorBrushData]
    let stickerData: EditorStickerData?
    let filter: VideoEditorFilter?
}

extension VideoEditResult: Codable {
    
    enum CodingKeys: String, CodingKey {
        case urlConfig
        case coverImage
        case editedFileSize
        case videoTime
        case videoDuration
        case hasOriginalSound
        case videoSoundVolume
        case backgroundMusicURL
        case backgroundMusicVolume
        case cropData
        case sizeData
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        urlConfig = try container.decode(EditorURLConfig.self, forKey: .urlConfig)
        if let coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImage) {
            coverImage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(coverImageData) as? UIImage
        }else {
            coverImage = nil
        }
        editedFileSize = try container.decode(Int.self, forKey: .editedFileSize)
        videoTime = try container.decode(String.self, forKey: .videoTime)
        videoDuration = try container.decode(TimeInterval.self, forKey: .videoDuration)
        hasOriginalSound = try container.decode(Bool.self, forKey: .hasOriginalSound)
        videoSoundVolume = try container.decode(Float.self, forKey: .videoSoundVolume)
        backgroundMusicURL = try container.decodeIfPresent(URL.self, forKey: .backgroundMusicURL)
        backgroundMusicVolume = try container.decode(Float.self, forKey: .backgroundMusicVolume)
        cropData = try container.decodeIfPresent(VideoCropData.self, forKey: .cropData)
        sizeData = try container.decodeIfPresent(VideoEditedCropSize.self, forKey: .sizeData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(urlConfig, forKey: .urlConfig)
        try container.encode(editedFileSize, forKey: .editedFileSize)
        try container.encode(videoTime, forKey: .videoTime)
        try container.encode(videoDuration, forKey: .videoDuration)
        try container.encode(hasOriginalSound, forKey: .hasOriginalSound)
        try container.encode(videoSoundVolume, forKey: .videoSoundVolume)
        try container.encode(backgroundMusicURL, forKey: .backgroundMusicURL)
        try container.encode(backgroundMusicVolume, forKey: .backgroundMusicVolume)
        try container.encodeIfPresent(cropData, forKey: .cropData)
        try container.encodeIfPresent(sizeData, forKey: .sizeData)
        
        if let image = coverImage {
            if #available(iOS 11.0, *) {
                let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
                try container.encodeIfPresent(imageData, forKey: .coverImage)
            } else {
                // Fallback on earlier versions
                let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
                try container.encodeIfPresent(imageData, forKey: .coverImage)
            }
        }
    }
}
