//
//  YPImagePickerConfiguration.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 18/10/2017.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

/// Typealias for code prettiness
internal var EDConfig: EDImagePickerConfiguration { return EDImagePickerConfiguration.shared }

public struct EDImagePickerConfiguration {
    public static var shared: EDImagePickerConfiguration = EDImagePickerConfiguration()
    
    public static var widthOniPad: CGFloat = -1
    
    public static var screenWidth: CGFloat {
		var screenWidth: CGFloat = UIScreen.main.bounds.width
		if UIDevice.current.userInterfaceIdiom == .pad && EDImagePickerConfiguration.widthOniPad > 0 {
			screenWidth =  EDImagePickerConfiguration.widthOniPad
		}
		return screenWidth
    }

    /// If don't want to have logs from picker, set it to false.
    public var isDebugLogsEnabled: Bool = true

    public init() {}
    
    /// Library configuration
    public var library = EDConfigLibrary()
    
    /// Video configuration
    public var video = YPConfigVideo()
    
    /// Gallery configuration
    public var gallery = YPConfigSelectionsGallery()
    
    /// Use this property to modify the default wordings provided.
    public var wordings = EDWordings()
    
    /// Use this property to modify the default icons provided.
    public var icons = EDIcons()
    
    /// Use this property to modify the default colors provided.
    public var colors = EDColors()

    /// Use this property to modify the default fonts provided
    public var fonts = EDFonts()

    /// Scroll to change modes, defaults to true
    public var isScrollToChangeModesEnabled = true

    /// Set this to true if you want to force the camera output to be a squared image. Defaults to true
    public var onlySquareImagesFromCamera = true
    
    /// Enables selecting the front camera by default, useful for avatars. Defaults to false
    public var usesFrontCamera = false
    
    /// Adds a Filter step in the photo taking process.  Defaults to true
    public var showsPhotoFilters = true
    
    /// Adds a Video Trimmer step in the video taking process.  Defaults to true
    public var showsVideoTrimmer = true
    
    /// Enables you to opt out from saving new (or old but filtered) images to the
    /// user's photo library. Defaults to true.
    public var shouldSaveNewPicturesToAlbum = true
    
    /// Defines the name of the album when saving pictures in the user's photo library.
    /// In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName"
    public var albumName = "DefaultYPImagePickerAlbumName"

    /// Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
    /// Default value is `.photo`
    public var startOnScreen: EDPickerScreen = .photo
    
    /// Defines which screens are shown at launch, and their order.
    /// Default value is `[.library, .photo]`
    public var screens: [EDPickerScreen] = [.library, .photo]

    /// Adds a Crop step in the photo taking process, after filters.  Defaults to .none
    public var showsCrop: YPCropType = .none
    
    /// Controls the visibility of a grid on crop stage. Default it false
    public var showsCropGridOverlay = false
    
    /// Ex: cappedTo:1024 will make sure images from the library or the camera will be
    /// resized to fit in a 1024x1024 box. Defaults to original image size.
    public var targetImageSize = EDImageSize.original
    
    /// Adds a Overlay View to the camera
    public var overlayView: UIView?

    /// Defines if the navigation bar cancel button should be hidden when showing the picker. Default is false
    public var hidesCancelButton = false
    
    /// Defines if the status bar should be hidden when showing the picker. Default is true
    public var hidesStatusBar = true
    
    /// Defines if the bottom bar should be hidden when showing the picker. Default is false.
    public var hidesBottomBar = false

    /// Defines the preferredStatusBarAppearance
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    /// Defines the text colour to be shown when a bottom option is selected
    public var bottomMenuItemSelectedTextColour: UIColor = .ypLabel
    
    /// Defines the text colour to be shown when a bottom option is unselected
    public var bottomMenuItemUnSelectedTextColour: UIColor = .ypSecondaryLabel
    
    /// Defines the max camera zoom factor for camera. Disable camera zoom with 1. Default is 1.
    public var maxCameraZoomFactor: CGFloat = 1.0
    
    /// List of default filters which will be added on the filter screen
    public var filters: [EDFilter] = [
        EDFilter(name: "Normal", applier: nil),
        EDFilter(name: "Nashville", applier: EDFilter.nashvilleFilter),
        EDFilter(name: "Toaster", applier: EDFilter.toasterFilter),
        EDFilter(name: "1977", applier: EDFilter.apply1977Filter),
        EDFilter(name: "Clarendon", applier: EDFilter.clarendonFilter),
        EDFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        EDFilter(name: "Fade", coreImageFilterName: "CIPhotoEffectFade"),
        EDFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        EDFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        EDFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        EDFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        EDFilter(name: "Tonal", coreImageFilterName: "CIPhotoEffectTonal"),
        EDFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
        EDFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        EDFilter(name: "Linear", coreImageFilterName: "CISRGBToneCurveToLinear"),
        EDFilter(name: "Sepia", coreImageFilterName: "CISepiaTone"),
        EDFilter(name: "XRay", coreImageFilterName: "CIXRay")
        ]
}

/// Encapsulates library specific settings.
public struct EDConfigLibrary {
    
    public var options: PHFetchOptions?

    /// Set this to true if you want to force the library output to be a squared image. Defaults to false.
    public var onlySquare = false
    
    /// Sets the cropping style to square or not. Ignored if `onlySquare` is true. Defaults to true.
    public var isSquareByDefault = true
    
	/// Minimum width, to prevent selectiong too high images. Have sense if onlySquare is true and the image is portrait.
    public var minWidthForItem: CGFloat?
    
    /// Choose what media types are available in the library. Defaults to `.photo`.
    /// If you define custom options PHFetchOptions var, than this will not work.
    public var mediaType = YPlibraryMediaType.photo

    /// Initial state of multiple selection button.
    public var defaultMultipleSelection = false

    /// Pre-selects the current item on setting multiple selection
    public var preSelectItemOnMultipleSelection = true

    /// Anything superior than 1 will enable the multiple selection feature.
    public var maxNumberOfItems = 1
    
    /// Anything greater than 1 will desactivate live photo and video modes (library only) and
    /// force users to select at least the number of items defined.
    public var minNumberOfItems = 1

    /// Set the number of items per row in collection view. Defaults to 4.
    public var numberOfItemsInRow: Int = 4

    /// Set the spacing between items in collection view. Defaults to 1.0.
    public var spacingBetweenItems: CGFloat = 1.0

    /// Allow to skip the selections gallery when selecting the multiple media items. Defaults to false.
    public var skipSelectionsGallery = false
    
    /// Allow to preselected media items
    public var preselectedItems: [EDMediaItem]?
    
    /// Set the overlay type shown on top of the selected library item
    public var itemOverlayType: YPItemOverlayType = .grid
}

/// Encapsulates video specific settings.
public struct YPConfigVideo {
    
    /** Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality
     - "AVAssetExportPresetLowQuality"
     - "AVAssetExportPreset640x480"
     - "AVAssetExportPresetMediumQuality"
     - "AVAssetExportPreset1920x1080"
     - "AVAssetExportPreset1280x720"
     - "AVAssetExportPresetHighestQuality"
     - "AVAssetExportPresetAppleM4A"
     - "AVAssetExportPreset3840x2160"
     - "AVAssetExportPreset960x540"
     - "AVAssetExportPresetPassthrough" // without any compression
     */
    public var compression: String = AVAssetExportPresetHighestQuality
    
    /// Choose the result video extension if you trim or compress a video. Defaults to mov.
    public var fileType: AVFileType = .mov
    
    /// Defines the time limit for recording videos.
    /// Default is 60 seconds.
    public var recordingTimeLimit: TimeInterval = 60.0
    
    /// Defines the size limit in bytes for recording videos.
    /// If this property is not nil, then the recording percentage line tracks buy this.
    /// In bytes. 100000000 is 100 MB.
    /// AVCaptureMovieFileOutput.maxRecordedFileSize.
    public var recordingSizeLimit: Int64?

    /// Minimum free space when recording videos.
    /// AVCaptureMovieFileOutput.minFreeDiskSpaceLimit.
    public var minFreeDiskSpaceLimit: Int64 = 1024 * 1024
    
    /// Defines the time limit for videos from the library.
    /// Defaults to 60 seconds.
    public var libraryTimeLimit: TimeInterval = 60.0
    
    /// Defines the minimum time for the video
    /// Defaults to 3 seconds.
    public var minimumTimeLimit: TimeInterval = 3.0
    
    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    /// - Tag: trimmerMaxDuration
    public var trimmerMaxDuration: Double = 60.0
    
    /// The minimum duration allowed for the trimming.
    /// The handles won't pan further if the minimum duration is attained.
    public var trimmerMinDuration: Double = 3.0

    /// Defines if the user skips the trimer stage,
    /// the video will be trimmed automatically to the maximum value of trimmerMaxDuration.
    /// This case occurs when the user already has a video selected and enables a
    /// multiselection to pick more than one type of media (video or image),
    /// so, the trimmer step becomes optional.
    /// - SeeAlso: [trimmerMaxDuration](x-source-tag://trimmerMaxDuration)
    public var automaticTrimToTrimmerMaxDuration: Bool = false
}

/// Encapsulates gallery specific settings.
public struct YPConfigSelectionsGallery {
    /// Defines if the remove button should be hidden when showing the gallery. Default is true.
    public var hidesRemoveButton = true
}

public enum YPItemOverlayType {
    case none
    case grid
}

public enum YPlibraryMediaType {
    case photo
    case video
    case photoAndVideo
}
