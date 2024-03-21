//
//  VideoEditorViewController.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/9.
//

import UIKit
import AVKit
import Photos
import GiphyUISDK

open class VideoEditorView: UIView {
    
#if canImport(GiphyUISDK)
    var selectedContentType: GPHContentType?
    var showMoreByUser: String?
#endif
    
    var parentVC : UIViewController?
    
    
    public weak var delegate: VideoEditorViewControllerDelegate?
    
    /// The currently edited AVAsset
    public var avAsset: AVAsset! { pAVAsset }
    
    /// edit configuration
    public var config: VideoEditorConfiguration
    
    /// current editing status
    public var state: State { pState }
    
    /// Resource Type
    public let sourceType: EditorController.SourceType
    
    /// The video cover shown before the video was unsuccessful
    public var coverImage: UIImage?
    
    /// The address of the currently edited online video
    public var networkVideoURL: URL? { pNetworkVideoURL }
    
    /// The audio path of the current soundtrack
    public var backgroundMusicPath: String? {
        didSet { toolView.reloadMusic(isSelected: backgroundMusicPath != nil) }
    }
    
    /// soundtrack volume
    public var backgroundMusicVolume: Float = 1 {
        didSet { PhotoManager.shared.changeAudioPlayerVolume(backgroundMusicVolume) }
    }
    
    /// play video
    public func playVideo() { startPlayTimer() }
    
    /// Video sound volume
    public var videoVolume: Float = 1 {
        didSet { videoView.playerView.player.volume = videoVolume }
    }
    
    /// Cancel downloading online videos after the interface disappears
    public var viewDidDisappearCancelDownload = true
    
    /// last edited data
    public var editResult: VideoEditResult?
    
    /// The address of the currently edited video has a value only when it is initialized through videoURL
    public private(set) var videoURL: URL?
    
    /// Automatically exit the interface after confirmation/cancellation
    public var autoBack: Bool = true
    
    public var finishHandler: FinishHandler?
    
    public var cancelHandler: CancelHandler?
    
    var bottomMenuHiddenHandler: ((Bool)->Void)?
    
    var backButtonHandler: (()->Void)?
    
    var videoEditedResult : ((VideoEditResult?)->Void)?
    
    public typealias FinishHandler = (VideoEditorView, VideoEditResult?) -> Void
    public typealias CancelHandler = (VideoEditorView) -> Void
    
    /// Initialize according to the video address
    /// - Parameters:
    ///   - videoURL: local video address
    ///   - editResult: The result of the last edit, passed in to be edited based on
    ///   - config: edit configuration
    public convenience init(
        videoURL: URL,
        editResult: VideoEditResult? = nil,
        config: VideoEditorConfiguration
    ) {
        self.init(
            avAsset: AVAsset.init(url: videoURL),
            editResult: editResult,
            config: config
        )
        self.videoURL = videoURL
    }
    
    /// Initialize according to AVAsset
    /// - Parameters:
    ///   - avAsset: The AVAsset object corresponding to the video
    ///   - editResult: The result of the last edit, passed in to be edited based on
    ///   - config: edit configuration
    public init(
        avAsset: AVAsset,
        editResult: VideoEditResult? = nil,
        config: VideoEditorConfiguration
    ) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        if config.mustBeTailored {
            onceState = config.defaultState
        }
        needRequest = true
        requestType = 3
        self.sourceType = .local
        self.editResult = editResult
        self.pState = config.defaultState
        self.config = config
        self.pAVAsset = avAsset
        super.init()
//        modalPresentationStyle = config.modalPresentationStyle
    }
    
    /// Edit web video
    /// - Parameters:
    ///   - networkVideoURL: Corresponding web video address
    ///   - editResult: The result of the last edit, passed in to be edited based on
    ///   - config: edit configuration
    public init(
        networkVideoURL: URL,
        editResult: VideoEditResult? = nil,
        config: VideoEditorConfiguration
    ) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        if config.mustBeTailored {
            onceState = config.defaultState
        }
        requestType = 2
        needRequest = true
        self.sourceType = .network
        self.editResult = editResult
        self.pState = config.defaultState
        self.config = config
        self.pNetworkVideoURL = networkVideoURL
        super.init()
//        modalPresentationStyle = config.modalPresentationStyle
    }
    public override init(frame: CGRect) {
        self.config = VideoEditorConfiguration()
        self.sourceType = .picker
        self.pState = config.defaultState
        requestType = 1
        needRequest = true
        
        super.init(frame: frame)
        self.pAVAsset = avAsset
        
    }
    
//    #if HXPICKER_ENABLE_PICKER
    /// 视频对应的 PhotoAsset
    public var photoAsset: PhotoAsset!
    
    /// 根据PhotoAsset初始化
    /// - Parameters:
    ///   - photoAsset: 视频对应的PhotoAsset对象
    ///   - editResult: 上一次编辑的结果，传入可在基础上进行编辑
    ///   - config: 编辑配置
    public init(
        photoAsset: PhotoAsset,
        editResult: VideoEditResult? = nil,
        config: VideoEditorConfiguration
    ) {
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        if config.mustBeTailored {
            onceState = config.defaultState
        }
        requestType = 1
        needRequest = true
        sourceType = .picker
        self.editResult = editResult
        self.pState = config.defaultState
        self.config = config
        self.photoAsset = photoAsset
        super.init()
//        modalPresentationStyle = config.modalPresentationStyle
    }
//    #endif
    
    var hasOriginalSound: Bool = true {
        didSet {
            volumeView.hasOriginalSound = hasOriginalSound
        }
    }
    var pState: State
    var pAVAsset: AVAsset!
    var pNetworkVideoURL: URL?
    
    /// 请求获取AVAsset完成
    var reqeustAssetCompletion: Bool = false
    private var needRequest: Bool = false
    private var requestType: Int = 0
    var loadingView: ProgressHUD?
    
    var videoInitializeCompletion = false
    var setAssetCompletion: Bool = false
    var transitionCompletion: Bool = true
    var onceState: State = .normal
    var assetRequestID: PHImageRequestID?
    var didEdited: Bool = false
    var firstPlay: Bool = true
    var videoSize: CGSize = .zero
    
    /// 不是在音乐列表选中的音乐数据（不包括搜索）
    var otherMusic: VideoEditorMusic?
    lazy var videoView: PhotoEditorView = {
        let videoView = PhotoEditorView(
            editType: .video,
            cropConfig: config.cropSize,
            mosaicConfig: .init(),
            brushConfig: config.brush,
            exportScale: 2
        )
        if let avAsset = avAsset {
            let image = coverImage ?? PhotoTools.getVideoThumbnailImage(avAsset: avAsset, atTime: 0.1)
            videoView.setAVAsset(avAsset, coverImage: image ?? .init())
        }
        videoView.playerView.delegate = self
        videoView.editorDelegate = self
        return videoView
    }()
    lazy var musicView: VideoEditorMusicView = {
        let view = VideoEditorMusicView.init(config: config.music)
        view.delegate = self
        return view
    }()
    lazy var searchMusicView: VideoEditorSearchMusicView = {
        let view = VideoEditorSearchMusicView(config: config.music)
        view.delegate = self
        return view
    }()
    lazy var volumeView: VideoEditorVolumeView = {
        let view = VideoEditorVolumeView(config.music.tintColor)
        view.delegate = self
        return view
    }()
    var isMusicState = false
    var isSearchMusic = false
    var isShowVolume = false
    
    lazy var brushBlockView: PhotoEditorBrushSizeView = {
        let view = PhotoEditorBrushSizeView.init(frame: .init(x: 0, y: 0, width: 30, height: 200))
        view.alpha = 0
        view.isHidden = true
        view.value = config.brush.lineWidth / (config.brush.maximumLinewidth - config.brush.minimumLinewidth)
        view.blockBeganChanged = { [weak self] _ in
            guard let self = self else { return }
            let lineWidth = self.videoView.brushLineWidth + 4
            self.brushSizeView.hx_size = CGSize(width: lineWidth, height: lineWidth)
            self.brushSizeView.center = CGPoint(x: self.hx_width * 0.5, y: self.hx_height * 0.5)
            self.brushSizeView.alpha = 0
            self.addSubview(self.brushSizeView)
            UIView.animate(withDuration: 0.2) {
                self.brushSizeView.alpha = 1
            }
        }
        view.blockDidChanged = { [weak self] in
            guard let self = self else { return }
            let config = self.config.brush
            let lineWidth = (
                config.maximumLinewidth -  config.minimumLinewidth
            ) * $0 + config.minimumLinewidth
            self.videoView.brushLineWidth = lineWidth
            self.brushSizeView.hx_size = CGSize(width: lineWidth + 4, height: lineWidth + 4)
            self.brushSizeView.center = CGPoint(x: self.hx_width * 0.5, y: self.hx_height * 0.5)
        }
        view.blockEndedChanged = { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2) {
                self.brushSizeView.alpha = 0
            } completion: { _ in
                self.brushSizeView.removeFromSuperview()
            }
        }
        return view
    }()
    lazy var brushColorView: PhotoEditorBrushColorView = {
        let view = PhotoEditorBrushColorView(config: config.brush)
        view.delegate = self
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    lazy var brushSizeView: PhotoEditorViewController.BrushSizeView = {
        let lineWidth = videoView.brushLineWidth + 4
        let view = PhotoEditorViewController.BrushSizeView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: lineWidth, height: lineWidth)
            )
        )
        return view
    }()
    lazy var cropToolView: PhotoEditorCropToolView = {
        var showRatios = true
        if config.cropSize.aspectRatios.isEmpty || config.cropSize.isRoundCrop {
            showRatios = false
        }
        let view = PhotoEditorCropToolView(
            showRatios: showRatios,
            scaleArray: config.cropSize.aspectRatios,
            defaultSelectedIndex: config.cropSize.defaultSeletedIndex
        )
        view.delegate = self
        view.themeColor = config.cropSize.aspectRatioSelectedColor
        view.alpha = 0
        view.isHidden = true
        return view
    }()
    lazy var cropView: VideoEditorCropView = {
        let cropView: VideoEditorCropView
        if needRequest {
            cropView = VideoEditorCropView.init(config: config.cropTime)
        }else  if let asset = avAsset{
          
            cropView = VideoEditorCropView.init(avAsset: avAsset, config: config.cropTime)
        }
        else{
            cropView = VideoEditorCropView.init(config: config.cropTime)
        }
        cropView.delegate = self
        cropView.alpha = 0
        cropView.isHidden = true
        return cropView
    }()
    var isFilter = false
    lazy var filterView: PhotoEditorFilterView = {
        let view = PhotoEditorFilterView(
            filterConfig: config.filter,
            hasLastFilter: editResult?.sizeData?.filter != nil,
            isVideo: true
        )
        view.delegate = self
        return view
    }()
    var isShowFilterParameter = false
    lazy var filterParameterView: PhotoEditorFilterParameterView = {
        let view = PhotoEditorFilterParameterView(sliderColor: config.filter.selectedColor)
        view.delegate = self
        return view
    }()
    
    public lazy var toolView: EditorToolView = {
        let toolView = EditorToolView.init(config: config.toolView)
        toolView.delegate = self
        return toolView
    }()
    lazy var cropConfirmView: EditorCropConfirmView = {
        let cropConfirmView = EditorCropConfirmView.init(config: config.cropConfirmView)
        cropConfirmView.alpha = 0
        cropConfirmView.isHidden = true
        cropConfirmView.delegate = self
        return cropConfirmView
    }()
    public lazy var topView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
      //  view.backgroundColor = .red
        return view
    }()
    public lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 44))
        cancelBtn.setImage(UIImage.image(for: config.backButtonImageName), for: .normal)
        cancelBtn.addTarget(self, action: #selector(didBackClick), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var topMaskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(true)
        return layer
    }()
    
    var showChartlet: Bool = false
    lazy var chartletView: EditorChartletView = {
        let view = EditorChartletView(
            config: config.chartlet,
            editorType: .video
        )
         delegate = self
        return view
    }()
    var isPresentText = false
    var orientationDidChange: Bool = true
    var videoViewDidChange: Bool = true
    /// 当前裁剪框的位置大小
    var currentValidRect: CGRect = .zero
    /// 当前裁剪框帧画面的偏移量
    var currentCropOffset: CGPoint?
    var beforeStartTime: CMTime?
    var beforeEndTime: CMTime?
    /// 旋转之前vc存储的当前编辑数据
    var rotateBeforeStorageData: (CGFloat, CGFloat, CGFloat)? // swiftlint:disable:this large_tuple
    /// 旋转之前cropview存储的裁剪框数据
    var rotateBeforeData: (CGFloat, CGFloat, CGFloat)? // swiftlint:disable:this large_tuple
    var playTimer: DispatchSourceTimer?
    
    /// 视频导出会话
    var exportSession: AVAssetExportSession?
    var exportLoadingView: ProgressHUD?
    
    var toolOptions: EditorToolView.Options = []
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func viewDidLoad() {
       // super.viewDidLoad()
        initView()
    }
    func initOptions() {
        for options in config.toolView.toolOptions {
            switch options.type {
            case .graffiti:
                toolOptions.insert(.graffiti)
            case .chartlet:
                toolOptions.insert(.chartlet)
            case .text:
                toolOptions.insert(.text)
            case .cropSize:
                toolOptions.insert(.cropSize)
            case .cropTime:
                toolOptions.insert(.cropTime)
            case .mosaic:
                
                toolOptions.insert(.mosaic)
            case .filter:
                toolOptions.insert(.filter)
            case .music:
//                toolOptions.insert(.music)
                print("music option")
            }
        }
    }
    func initView() {
        initOptions()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        singleTap.delegate = self
        addGestureRecognizer(singleTap)
        isExclusiveTouch = true
        backgroundColor = .black
        clipsToBounds = true
        addSubview(videoView)
        addSubview(cropToolView)
        addSubview(cropView)
        addSubview(cropConfirmView)
        topView.addSubview(toolView)
        topView.addSubview(cancelBtn)
        if toolOptions.contains(.graffiti) {
             addSubview(brushColorView)
             addSubview(brushBlockView)
        }
        if toolOptions.contains(.music) {
             addSubview(musicView)
             addSubview(searchMusicView)
             addSubview(volumeView)
        }
        if toolOptions.contains(.filter) {
             addSubview(filterView)
             addSubview(filterParameterView)
        }
        if toolOptions.isSticker {
             addSubview(chartletView)
        }
         layer.addSublayer(topMaskLayer)
         addSubview(topView)
        if needRequest {
            if requestType == 1 {
//                #if HXPICKER_ENABLE_PICKER
                requestAVAsset()
//                #endif
            }else if requestType == 2 {
                downloadNetworkVideo()
            }else if requestType == 3 {
                avassetLoadValuesAsynchronously()
            }
        }
        if let editResult = editResult {
            didEdited = true
            if let cropData = editResult.cropData {
                videoView.playerView.playStartTime = CMTimeMakeWithSeconds(
                    cropData.startTime,
                    preferredTimescale: cropData.preferredTimescale
                )
                videoView.playerView.playEndTime = CMTimeMakeWithSeconds(
                    cropData.endTime,
                    preferredTimescale: cropData.preferredTimescale
                )
                rotateBeforeStorageData = (
                    cropData.cropingData.offsetX,
                    cropData.cropingData.validX,
                    cropData.cropingData.validWidth
                )
                rotateBeforeData = (
                    cropData.cropRectData.offsetX,
                    cropData.cropRectData.validX,
                    cropData.cropRectData.validWidth
                )
            }
        }
    }
    open override func willMove(toWindow newWindow: UIWindow?) {
        self.videoView.playerView.player.isMuted = true
    }
    @objc func didBackClick() {
        backAction()
        cancelHandler?(self)
        delegate?.videoEditorViewController(didCancel: self)
    }
    func backAction() {
        hiddenBrushColorView()
        stopAllOperations()
        
        if let action = backButtonHandler{
            action()
        }
        
//        if let requestID = assetRequestID {
//            PHImageManager.default().cancelImageRequest(requestID)
//        }
//        if autoBack {
            
//            if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
//                navigationController.popViewController(animated: true)
//            }else {
//                dismiss(animated: true, completion: nil)
//            }
//        }
    }
    open  func deviceOrientationWillChanged(notify: Notification) {
        orientationDidChange = true
        videoViewDidChange = false
        if let currentCropOffset = currentCropOffset {
            rotateBeforeStorageData = cropView.getRotateBeforeData(
                offsetX: currentCropOffset.x,
                validX: currentValidRect.minX,
                validWidth: currentValidRect.width
            )
        }
        if showChartlet {
            singleTap()
        }
        videoView.undoAllSticker()
        videoView.undoAllDraw()
        videoView.reset(false)
        if state == .cropSize {
            pState = .normal
            toolCropSizeAnimation()
        }else if state == .cropTime {
            cancelCropTime(false)
        }
        videoView.finishCropping(false)
        videoView.imageResizerView.isDidFinishedClick = false
        cropToolView.resetSelected()
        rotateBeforeData = cropView.getRotateBeforeData()
        videoView.playerView.pause()
        if toolOptions.contains(.music) {
            searchMusicView.deselect()
            musicView.reset()
        }
        backgroundMusicPath = nil
        stopPlayTimer()
    }
//    open override func deviceOrientationDidChanged(notify: Notification) {
//        orientationDidChange = true
//        videoViewDidChange = false
//    }
    open override func layoutSubviews() {
        topView.frame = CGRect(x: 0, y: 8, width: hx_width, height: UIDevice.isPortrait ? 44 : 32)
        toolView.frame = CGRect(
            x: topView.hx_width - cancelBtn.frame.width - 240,
                y: 0,
                width: 320,
                height: 44
            )
        
        
        toolView.reloadContentInset()
       
       
        cancelBtn.hx_height = topView.hx_height
        cancelBtn.hx_x = UIDevice.leftMargin
      
        
        
        
        topMaskLayer.frame = CGRect(x: 0, y: 0, width:  hx_width, height: topView.frame.maxY + 10)
        cropView.frame = CGRect(x: 0, y: hx_height - UIDevice.bottomMargin - (UIDevice.isPortrait ? 130 : 110), width:  hx_width, height: 100)
        cropConfirmView.frame = toolView.frame
        if !videoView.frame.equalTo( bounds) && !videoView.frame.isEmpty && !videoViewDidChange {
            videoView.frame = bounds
            videoView.reset(false)
            videoView.finishCropping(false)
            videoView.imageResizerView.isDidFinishedClick = false
            cropToolView.resetSelected()
            orientationDidChange = true
        }else {
            videoView.frame =  bounds
        }
        if toolOptions.contains(.cropSize) {
            let cropToolFrame = CGRect(x: 0, y: toolView.hx_y + 60, width:  hx_width, height: 60)
            let cropConfirmViewFrame = CGRect(x: 0, y: hx_height - 72, width: hx_width, height: 60)
            cropConfirmView.frame = cropConfirmViewFrame
            cropToolView.frame = cropToolFrame
            cropToolView.updateContentInset()
        }
        if toolOptions.contains(.graffiti) {
           
            
            brushColorView.frame = CGRect(x: 0, y: toolView.hx_y + 32, width:  hx_width, height: 65)
            brushBlockView.hx_x =  hx_width - 45 - UIDevice.rightMargin
            if UIDevice.isPortrait {
                brushBlockView.centerY =  hx_height * 0.5
            }else {
                brushBlockView.hx_y = brushColorView.hx_y - brushBlockView.hx_height
            }
        }
        if toolOptions.isSticker {
            setChartletViewFrame()
        }
        if toolOptions.contains(.music) {
            setMusicViewFrame()
            setSearchMusicViewFrame()
            setVolumeViewFrame()
            if orientationDidChange {
                searchMusicView.reloadData()
            }
        }
        if toolOptions.contains(.filter) {
            setFilterViewFrame()
            setFilterParameterViewFrame()
        }
        if orientationDidChange {
            if videoView.playerView.avAsset != nil && !videoViewDidChange {
                videoView.orientationDidChange()
            }
            videoViewDidChange = true
        }
        if needRequest {
            if reqeustAssetCompletion {
                setCropViewFrame()
            }
        }else {
            setCropViewFrame()
        }

    }

    open  func viewDidAppear(_ animated: Bool) {
       
        isPresentText = false
//        if let isHidden = navigationController?.navigationBar.isHidden, !isHidden {
//            navigationController?.setNavigationBarHidden(true, animated: false)
//        }
    }
    open  func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
        if isPresentText {
            return
        }
        stopAllOperations()
        if let exportSession = exportSession {
            exportSession.cancelExport()
        }
    }
    
    public func stopAllOperations() {
        stopPlayTimer()
        PhotoManager.shared.stopPlayMusic()
        if let url = networkVideoURL, viewDidDisappearCancelDownload {
            PhotoManager.shared.suspendTask(url)
            pNetworkVideoURL = nil
        }
        viewDidDisappearCancelDownload = true
    }
    open  func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if navigationController?.topViewController != self &&
//            navigationController?.viewControllers.contains(self) == false {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
    }
    open  func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    deinit {
        if let asset = avAsset {
            asset.cancelLoading()
        }
    }
}

extension VideoEditorView: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return EditorTransition(mode: .push)
        }else if operation == .pop {
            return EditorTransition(mode: .pop)
        }
        return nil
    }
}

extension VideoEditorView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is EditorStickerContentView {
            return false
        }
        if let isDescendant = touch.view?.isDescendant(of: videoView), isDescendant {
            return true
        }
        return false
    }
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if otherGestureRecognizer is UILongPressGestureRecognizer &&
            otherGestureRecognizer.view is PhotoEditorContentView {
            return false
        }
        return true
    }
}

// MARK: singleTap
extension VideoEditorView {
    
    @objc func singleTap() {
        if state != .normal {
            return
        }
        if toolOptions.isSticker {
            videoView.deselectedSticker()
        }
        if isSearchMusic {
            hideSearchMusicView()
            return
        }
        if isShowVolume {
            hiddenVolumeView()
            return
        }
        if isFilter {
            if isShowFilterParameter {
                hideFilterParameterView()
                return
            }
            videoView.stickerEnabled = true
            hiddenFilterView()
            videoView.canLookOriginal = false
        }
        if showChartlet {
            showChartlet = false
            videoView.stickerEnabled = true
            hiddenChartletView()
        }
        if isMusicState {
            videoView.stickerEnabled = true
            isMusicState = false
            updateMusicView()
        }
        if topView.isHidden == true {
            showTopView()
        }else {
            hidenTopView()
        }
    }
    func showTopView() {
        if let handler = bottomMenuHiddenHandler{
            handler(true)
        }
        if videoView.drawEnabled {
            showBrushColorView()
        }
        toolView.isHidden = false
        topView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 1
            self.topView.alpha = 1
            self.topMaskLayer.isHidden = false
        }
    }
    func hidenTopView() {
        if let handler = bottomMenuHiddenHandler{
            handler(false)
        }
        if videoView.drawEnabled {
            hiddenBrushColorView()
        }
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 0
            self.topView.alpha = 0
            self.topMaskLayer.isHidden = true
        } completion: { (isFinished) in
            if self.toolView.alpha == 0 {
                self.toolView.isHidden = true
                self.topView.isHidden = true
            }
        }
    }
}

// MARK: setup frame
extension VideoEditorView {
    
    func setChartletViewFrame() {
        var viewHeight = config.chartlet.viewHeight
        if viewHeight >  hx_height {
            viewHeight =  hx_height * 0.6
        }
        if showChartlet {
            chartletView.frame = CGRect(
                x: 0,
                y:  hx_height - viewHeight - UIDevice.bottomMargin,
                width:  hx_width,
                height: viewHeight + UIDevice.bottomMargin
            )
        }else {
            chartletView.frame = CGRect(
                x: 0,
                y:  hx_height,
                width:  hx_width,
                height: viewHeight + UIDevice.bottomMargin
            )
        }
    }
    /// 设置裁剪框frame
    func setCropViewFrame() {
        if !orientationDidChange {
            return
        }
        cropView.configData()
        if let rotateBeforeData = rotateBeforeData {
            cropView.layoutSubviews()
            cropView.rotateAfterSetData(
                offsetXScale: rotateBeforeData.0,
                validXScale: rotateBeforeData.1,
                validWithScale: rotateBeforeData.2
            )
            cropView.updateTimeLabels()
            if state == .cropTime || didEdited {
                videoView.playerView.playStartTime = cropView.getStartTime(real: true)
                videoView.playerView.playEndTime = cropView.getEndTime(real: true)
            }
            if let rotateBeforeStorageData = rotateBeforeStorageData {
                rotateAfterSetStorageData(
                    offsetXScale: rotateBeforeStorageData.0,
                    validXScale: rotateBeforeStorageData.1,
                    validWithScale: rotateBeforeStorageData.2
                )
            }
            if transitionCompletion {
                videoView.playerView.resetPlay()
                startPlayTimer()
            }
        }
        DispatchQueue.main.async {
            self.orientationDidChange = false
        }
    }
    func setMusicViewFrame() {
        let marginHeight: CGFloat = 190
        let musicY: CGFloat
        let musicHeight: CGFloat
        if !isMusicState {
            musicY =  hx_height
            musicHeight = marginHeight + UIDevice.bottomMargin
        }else {
            musicY =  hx_height - marginHeight - UIDevice.bottomMargin
            musicHeight = marginHeight + UIDevice.bottomMargin
        }
        musicView.frame = CGRect(
            x: 0,
            y: musicY,
            width:  hx_width,
            height: musicHeight
        )
    }
    func setFilterViewFrame() {
        let filterHeight: CGFloat
        #if canImport(Harbeth)
        filterHeight = 155 + UIDevice.bottomMargin
        #else
        filterHeight = 125 + UIDevice.bottomMargin
        #endif
        if isFilter {
            filterView.frame = CGRect(
                x: 0,
                y:  hx_height - filterHeight,
                width:  hx_width,
                height: filterHeight
            )
        }else {
            filterView.frame = CGRect(
                x: 0,
                y:  hx_height + 10,
                width:  hx_width,
                height: filterHeight
            )
        }
    }
    func setFilterParameterViewFrame() {
        let editHeight = max(CGFloat(filterParameterView.models.count) * 40 + 30 + UIDevice.bottomMargin, filterView.hx_height)
        if isShowFilterParameter {
            filterParameterView.frame = .init(
                x: 0,
                y:  hx_height - editHeight,
                width:  hx_width,
                height: editHeight
            )
        }else {
            filterParameterView.frame = .init(
                x: 0,
                y:  hx_height,
                width:  hx_width,
                height: editHeight
            )
        }
    }
    func setSearchMusicViewFrame() {
        var viewHeight: CGFloat =  hx_height * 0.75 + UIDevice.bottomMargin
        if !UIDevice.isPad && !UIDevice.isPortrait {
            viewHeight =  hx_height * 0.85 + UIDevice.bottomMargin
        }
        if !isSearchMusic {
            searchMusicView.frame = CGRect(x: 0, y:  hx_height, width:  hx_width, height: viewHeight)
        }else {
            searchMusicView.frame = CGRect(x: 0, y:  hx_height - viewHeight, width:  hx_width, height: viewHeight)
        }
    }
    func setVolumeViewFrame() {
        let marginHeight: CGFloat = 120
        let volumeY: CGFloat
        let volumeHeight: CGFloat
        if !isShowVolume {
            volumeY =  hx_height
            volumeHeight = marginHeight
        }else {
            volumeY =  hx_height - marginHeight - UIDevice.bottomMargin - 20
            volumeHeight = marginHeight
        }
        let marginWidth = UIDevice.leftMargin + UIDevice.rightMargin + 30
        volumeView.frame = CGRect(
            x: marginWidth * 0.5,
            y: volumeY,
            width:  hx_width - marginWidth,
            height: volumeHeight
        )
    }
    func rotateAfterSetStorageData(offsetXScale: CGFloat, validXScale: CGFloat, validWithScale: CGFloat) {
        let insert = cropView.collectionView.contentInset
        let offsetX = -insert.left + cropView.contentWidth * offsetXScale
        currentCropOffset = CGPoint(x: offsetX, y: -insert.top)
        let validInitialX = cropView.validRectX + cropView.imageWidth * 0.5
        let validMaxWidth = cropView.hx_width - validInitialX * 2
        let validX = validMaxWidth * validXScale + validInitialX
        let vaildWidth = validMaxWidth * validWithScale
        currentValidRect = CGRect(x: validX, y: 0, width: vaildWidth, height: cropView.itemHeight)
    }
}
