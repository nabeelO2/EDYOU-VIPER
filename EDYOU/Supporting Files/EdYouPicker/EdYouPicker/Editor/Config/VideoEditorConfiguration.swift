//
//  VideoEditorConfiguration.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/9.
//
import UIKit
import AVFoundation

open class VideoEditorConfiguration: EditorConfiguration {
    
    /// Video export resolution
    public var exportPreset: ExportPreset = .ratio_960x540
    
    /// Quality of video export [0-10]
    public var videoQuality: Int = 6
    
    /// back button icon
    public var backButtonImageName: String = "hx_editor_back"
    
    /// The address configuration of video export, the default is under tmp
    /// Please set a different address each time you edit to prevent the existing data from being overwritten
    public var videoURLConfig: EditorURLConfig?
    
    /// Edit the default state of the controller
    public var defaultState: VideoEditorView.State = .normal
    
    
    /// Whether the video must be cropped when the default state of the edit controller is cropped
    public var mustBeTailored: Bool = true
    
    /// brush
    public lazy var brush: EditorBrushConfiguration = .init()
    
    /// texture configuration
    public lazy var chartlet: EditorChartletConfiguration = .init()
    
    /// text
    public lazy var text: EditorTextConfiguration = .init()
    
    /// music configuration
    public lazy var music: Music = .init()
    
    /// filter configuration
    public lazy var filter: Filter = .init(infos: PhotoTools.defaultVideoFilters())
    
    /// Clipping duration configuration
    public lazy var cropTime: VideoCropTimeConfiguration = .init()
    
    /// Crop Screen Configuration
    public lazy var cropSize: EditorCropSizeConfiguration = .init() 
    
    /// Crop confirmation view configuration
    public lazy var cropConfirmView: CropConfirmViewConfiguration = .init()
    
    /// Tool View Configuration
    public lazy var toolView: EditorToolViewConfiguration = {
        let graffiti = EditorToolOptions(
            imageName: "hx_editor_tools_graffiti",
            type: .graffiti
        )
        let chartlet = EditorToolOptions(
            imageName: "hx_editor_photo_tools_emoji",
            type: .chartlet
        )
        let text = EditorToolOptions(
            imageName: "hx_editor_photo_tools_text",
            type: .text
        )
        let cropSize = EditorToolOptions(
            imageName: "hx_editor_photo_crop",
            type: .cropSize
        )
        let music = EditorToolOptions.init(
            imageName: "hx_editor_tools_music",
            type: .music
        )
        let cropTime = EditorToolOptions.init(
            imageName: "hx_editor_video_crop",
            type: .cropTime
        )
        let filter = EditorToolOptions(
            imageName: "hx_editor_tools_filter",
            type: .filter
        )
        return .init(toolOptions: [graffiti, chartlet, text, cropSize, cropTime, filter])
    }()
}

extension VideoEditorConfiguration {
    
    public struct Music {
        /// show search
        public var showSearch: Bool = true
        /// Done button background color, search box cursor color
        public var tintColor: UIColor = .systemTintColor
        /// placeholder for the search box
        public var placeholder: String = ""
        /// Automatically play music when scrolling stops
        public var autoPlayWhenScrollingStops: Bool = true
        /// Soundtrack Information
        /// It can also be set through the proxy callback
        /// func videoEditorViewController(
        /// _ videoEditorViewController: VideoEditorViewController,
        ///  loadMusic completionHandler: @escaping ([VideoEditorMusicInfo]) -> Void) -> Bool
        public var infos: [VideoEditorMusicInfo] = []
        
        /// Get the music list, trigger when infos is empty
        /// handler = { response -> Bool in
        ///     // incoming music data
        ///     response(self.getMusics())
        ///     // Whether to display loading
        ///     return false
        /// }
        public var handler: ((@escaping ([VideoEditorMusicInfo]) -> Void) -> Bool)?
        
        public init() { }
    }
}
