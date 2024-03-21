//
//  CameraConfiguration.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/30.
//

import UIKit
import AVFoundation

// MARK: camera configuration class
public class CameraConfiguration: BaseConfiguration {
    
    /// Camera type
    public var cameraType: CameraController.CameraType = .normal
    
    /// Camera resolutiion
    public var sessionPreset: Preset = .hd1280x720
    
    /// default camera position
    public var position: DevicePosition = .back
    
    /// default flash mode
    public var flashMode: AVCaptureDevice.FlashMode = .auto
    
    /// settings during video recording `AVVideoCodecType`
    /// iPhone7 以下为 `.h264`
    public var videoCodecType: AVVideoCodecType = {
        if #available(iOS 11.0, *) {
            return .h264
        } else {
            return .init(rawValue: AVVideoCodecH264)
        }
    }()
    
    /// maximum video recording duration
    /// takePhotoMode = .click supports unlimited maximum duration (0 - no limit)
    /// takePhotoMode = .press 最小 1
    public var videoMaximumDuration: TimeInterval = 60
    
    /// minimum video recording duration
    public var videoMinimumDuration: TimeInterval = 1
    
    /// mode
    public var takePhotoMode: TakePhotoMode = .press
    
    /// theme color
    public var tintColor: UIColor = .systemTintColor {
        didSet {
//            #if HXPICKER_ENABLE_EDITOR
            setupEditorColor()
//            #endif
        }
    }
    
    /// maximum camera zoom ratio
    public var videoMaxZoomScale: CGFloat = 6
    
    /// Default filter corresponds to the index in the filter array, -1 means no filter is applied by default
    public var defaultFilterIndex: Int = -1
    
    /// switch/filter display name
    public var changeFilterShowName: Bool = true
    
    /// Filter array for taking photos, please keep it consistent with the videoFilters effect
    /// Swipe left/right to switch filters
    public lazy var photoFilters: [CameraFilter] = [
        InstantFilter(), Apply1977Filter(), ToasterFilter(), TransferFilter()
    ]
    
    /// Filter array for recording videos, please keep it consistent with the photoFilters effect
    /// Swipe left/right to switch filters
    public lazy var videoFilters: [CameraFilter] = [
        InstantFilter(), Apply1977Filter(), ToasterFilter(), TransferFilter()
    ]
    
//    #if HXPICKER_ENABLE_EDITOR
    /// allow editing
    /// true:  After shooting, it will jump to the editing interface
    public var allowsEditing: Bool = true
    
    /// photo editor configuration
    public lazy var photoEditor: PhotoEditorConfiguration = .init()
    
    /// video editor configuration
    public lazy var videoEditor: VideoEditorConfiguration = .init()
//    #endif
    
    /// allow location access
    public var allowLocation: Bool = true
    
    public override init() {
        super.init()
        /// shouldAutorotate can rotate
        /// supportedInterfaceOrientations supported orientations
        
        /// hide the status bar
        prefersStatusBarHidden = true
        
        appearanceStyle = .normal
//        #if HXPICKER_ENABLE_EDITOR
        photoEditor.languageType = languageType
        videoEditor.languageType = languageType
        photoEditor.indicatorType = indicatorType
        videoEditor.indicatorType = indicatorType
        photoEditor.appearanceStyle = appearanceStyle
        videoEditor.appearanceStyle = appearanceStyle
//        #endif
    }
    
//    #if HXPICKER_ENABLE_EDITOR
    public override var languageType: LanguageType {
        didSet {
            photoEditor.languageType = languageType
            videoEditor.languageType = languageType
        }
    }
    public override var indicatorType: BaseConfiguration.IndicatorType {
        didSet {
            photoEditor.indicatorType = indicatorType
            videoEditor.indicatorType = indicatorType
        }
    }
    public override var appearanceStyle: AppearanceStyle {
        didSet {
            photoEditor.appearanceStyle = appearanceStyle
            videoEditor.appearanceStyle = appearanceStyle
        }
    }
//    #endif
}

extension CameraConfiguration {
    
    public enum DevicePosition {
        /// rear-facing
        case back
        /// front-facing
        case front
    }
    
    public enum TakePhotoMode {
        /// long press
        case press
        /// Click (supports unlimited maximum duration)
        case click
    }
    
    public enum Preset {
        case vga640x480
        case iFrame960x540
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
        
        var system: AVCaptureSession.Preset {
            switch self {
            case .vga640x480:
                return .vga640x480
            case .iFrame960x540:
                return .iFrame960x540
            case .hd1280x720:
                return .hd1280x720
            case .hd1920x1080:
                return .hd1920x1080
            case .hd4K3840x2160:
                return .hd4K3840x2160
            }
        }
        
        var size: CGSize {
            switch self {
            case .vga640x480:
                return CGSize(width: 480, height: 640)
            case .iFrame960x540:
                return CGSize(width: 540, height: 960)
            case .hd1280x720:
                return CGSize(width: 720, height: 1280)
            case .hd1920x1080:
                return CGSize(width: 1080, height: 1920)
            case .hd4K3840x2160:
                return CGSize(width: 2160, height: 3840)
            }
        }
    }
    
//    #if HXPICKER_ENABLE_EDITOR
    fileprivate func setupEditorColor() {
        
        videoEditor.cropConfirmView.finishButtonBackgroundColor = tintColor
        videoEditor.cropConfirmView.finishButtonDarkBackgroundColor = tintColor
        videoEditor.cropSize.aspectRatioSelectedColor = tintColor
        videoEditor.toolView.finishButtonBackgroundColor = tintColor
        videoEditor.toolView.finishButtonDarkBackgroundColor = tintColor
        videoEditor.toolView.toolSelectedColor = tintColor
        videoEditor.toolView.musicSelectedColor = tintColor
        videoEditor.music.tintColor = tintColor
        videoEditor.text.tintColor = tintColor
        videoEditor.filter = .init(
            infos: videoEditor.filter.infos,
            selectedColor: tintColor
        )
        
        photoEditor.toolView.toolSelectedColor = tintColor
        photoEditor.toolView.finishButtonBackgroundColor = tintColor
        photoEditor.toolView.finishButtonDarkBackgroundColor = tintColor
        photoEditor.cropConfimView.finishButtonBackgroundColor = tintColor
        photoEditor.cropConfimView.finishButtonDarkBackgroundColor = tintColor
        photoEditor.cropping.aspectRatioSelectedColor = tintColor
        photoEditor.filter = .init(
            infos: photoEditor.filter.infos,
            selectedColor: tintColor
        )
        photoEditor.text.tintColor = tintColor
    }
//    #endif
}
