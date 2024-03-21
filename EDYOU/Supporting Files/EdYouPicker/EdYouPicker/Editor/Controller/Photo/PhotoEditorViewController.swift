//
//  PhotoEditorViewController.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/9.
//

import UIKit
import Photos
import Foundation
#if canImport(Kingfisher)
import Kingfisher
#endif
#if canImport(Harbeth)
import Harbeth
#endif
#if canImport(GiphyUISDK)
import GiphyUISDK
import SwiftUI
#endif

open class PhotoEditorViewController: BaseViewController {
    
    
    //MARK: - Video outlets
    
    //MARK: - bottom images Preview
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
       
        collectionView.register(
            PhotoEditorPreviewCell.self,
            forCellWithReuseIdentifier: NSStringFromClass(PhotoEditorPreviewCell.self)
        )
      
        return collectionView
    }()
    
    public var previewAssets: [PhotoAsset] = []{
        didSet{
            self.setupConfiguration()
        }
    }
    
    var assetCount: Int {
        if previewAssets.isEmpty {
            return numberOfPages?() ?? 0
        }
        return previewAssets.count
    }
    var numberOfPages: PhotoBrowser.NumberOfPagesHandler?
    var cellForIndex: PhotoBrowser.CellReloadContext?
    var assetForIndex: PhotoBrowser.RequiredAsset?
    public var configPreview: PreviewViewConfiguration
    var isExternalPickerPreview: Bool = false
    var orientationDidChange: Bool = false
    var statusBarShouldBeHidden: Bool = false
    var videoLoadSingleCell = false
    var viewDidAppear: Bool = false
    var firstLayoutSubviews: Bool = true
    public var currentPreviewIndex: Int = 0
    public var isExternalPreview: Bool = false
    var isMultipleSelect: Bool = false
    var allowLoadPhotoLibrary: Bool = true
    
    //    lazy var bottomView: PhotoPickerBottomView = {
    //        let bottomView = PhotoPickerBottomView(
    //            config: configPreview.bottomView,
    //            allowLoadPhotoLibrary: allowLoadPhotoLibrary,
    //            isMultipleSelect: isMultipleSelect,
    //            sourceType: isExternalPreview ? .browser : .preview
    //        )
    //        bottomView.hx_delegate = self
    //        if configPreview.bottomView.showSelectedView && (isMultipleSelect || isExternalPreview) {
    //            bottomView.selectedView.reloadData(
    //                photoAssets: pickerController!.selectedAssetArray
    //            )
    //        }
    //        if !isExternalPreview {
    //            bottomView.boxControl.isSelected = pickerController!.isOriginal
    //            bottomView.requestAssetBytes()
    //        }
    //       // bottomView.backgroundColor = .red
    //        return bottomView
    //    }()
    
    lazy var bottomBGV: UIView = {
        return bottomBGV
    }()
    
    lazy var publishBGV: UIView = {
        return publishBGV
    }()
    public weak var delegate: PhotoEditorViewControllerDelegate?
    
    /// 配置
    public var config: [PhotoEditorConfiguration] = []
    
    
    
    /// 当前编辑的图片
    public var image: UIImage!
    
    /// 来源
    public var sourceType: EditorController.SourceType
    
    /// 当前编辑状态
    public var state: State { pState }
    
    /// 上一次的编辑结果
    public var editResult: PhotoEditResult?
    
    /// 确认/取消之后自动退出界面
    public var autoBack: Bool = true
    
    public var finishHandler: FinishHandler?
    
    public var cancelHandler: CancelHandler?
    
    public typealias FinishHandler = (PhotoEditorViewController, [Any]?) -> Void
    public typealias CancelHandler = (PhotoEditorViewController) -> Void
    
    public var cameraCloseAction: (([UIView])->Void)?
    
    public var editedResults : [Any] {
        didSet{
            checkResult()
        }
    }
#if canImport(GiphyUISDK)
    var selectedContentType: GPHContentType?
    var showMoreByUser: String?
#endif
    /// 编辑image
    /// - Parameters:
    ///   - image: 对应的 UIImage
    ///   - editResult: 上一次编辑结果
    ///   - config: 编辑配置
    public init(
        image: UIImage,
        editResult: PhotoEditResult? = nil,
        config: PhotoEditorConfiguration
    ) {
        
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        sourceType = .local
        self.image = image
        
        self.editResult = editResult
        self.configPreview = PreviewViewConfiguration()
        self.editedResults = []
        super.init(nibName: nil, bundle: nil)
        self.setupConfiguration()
//        self.config[currentPreviewIndex] = config
        
        modalPresentationStyle = config.modalPresentationStyle
    }
    
    //    #if HXPICKER_ENABLE_PICKER
    /// 当前编辑的PhotoAsset对象
//    public var photoAsset: PhotoAsset!
    
    /// 编辑 PhotoAsset
    /// - Parameters:
    ///   - photoAsset: 对应数据的 PhotoAsset
    ///   - editResult: 上一次编辑结果
    ///   - config: 编辑配置
    public init(
        photoAsset: PhotoAsset,
        editResult: PhotoEditResult? = nil,
        config: PhotoEditorConfiguration
    ) {
        
            PhotoManager.shared.appearanceStyle = config.appearanceStyle
            PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
            sourceType = .picker
            requestType = 1
            needRequest = true
            self.editResult = editResult
          //  self.previewAssets[currentPreviewIndex] = photoAsset
            self.configPreview = PreviewViewConfiguration()
            self.editedResults = []
            super.init(nibName: nil, bundle: nil)
            self.setupConfiguration()
          //  self.config.append(config)
            modalPresentationStyle = config.modalPresentationStyle
        
    }
    
    func setupConfiguration(){
        for _ in previewAssets {
            config.append(PhotoEditorConfiguration())
            if image != nil {
                thumbnailImages.append(image)
            }
            else{
                thumbnailImages.append(UIImage())
            }
                
            
        }
    }
    //    #endif
    
    func photoAsset()->PhotoAsset{
        return previewAssets[currentPreviewIndex]
    }
#if canImport(Kingfisher)
    /// 当前编辑的网络图片地址
    public private(set) var networkImageURL: URL?
    
    /// 编辑网络图片
    /// - Parameters:
    ///   - networkImageURL: 对应的网络地址
    ///   - editResult: 上一次编辑结果
    ///   - config: 编辑配置
    public init(
        networkImageURL: URL,
        editResult: PhotoEditResult? = nil,
        config: PhotoEditorConfiguration
    ) {
        
        PhotoManager.shared.appearanceStyle = config.appearanceStyle
        PhotoManager.shared.createLanguageBundle(languageType: config.languageType)
        sourceType = .network
        requestType = 2
        needRequest = true
        self.networkImageURL = networkImageURL
        
        self.editResult = editResult
        self.configPreview = PreviewViewConfiguration()
        self.editedResults = []
        super.init(nibName: nil, bundle: nil)
        self.setupConfiguration()
        self.config[currentPreviewIndex] = config
        modalPresentationStyle = config.modalPresentationStyle
    }
#endif
    var pState: State = .normal
    var filterHDImages: [UIImage]?
    var mosaicImage: UIImage?
    
    func filterHDImage()->UIImage?{
        return filterHDImages?[currentPreviewIndex]
    }
#if canImport(Harbeth)
    var metalFilters: [PhotoEditorFilterEditModel.`Type`: C7FilterProtocol] = [:]
#endif
    
    var thumbnailImages: [UIImage] = [UIImage]()
        
    
    
    func thumbnailImage()->UIImage{
        return thumbnailImages[currentPreviewIndex]
    }
    var transitionalImage: UIImage?
    var transitionCompletion: Bool = true
    var isFinishedBack: Bool = false
     var needRequest: Bool = false
     var requestType: Int = 0
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imageViews: [UIView] = {
        
       var imgViews = [UIView]()
        for asset in previewAssets {
            if asset.mediaType == .photo{
                let imageView = PhotoEditorView(
                    editType: .image,
                    cropConfig: config[currentPreviewIndex].cropping,
                    mosaicConfig: config[currentPreviewIndex].mosaic,
                    brushConfig: config[currentPreviewIndex].brush,
                    exportScale: config[currentPreviewIndex].scale,
                    urlConfig: config[currentPreviewIndex].imageURLConfig
                )
                imageView.editorDelegate = self
                imageView.backgroundColor = .black
    //            imageView.backgroundColor = colors.randomElement() ?? .red
                imgViews.append(imageView)
            }
            else{

                
                lazy var videoPreviewView = UIView()
                   
                videoPreviewView.backgroundColor = .black
                videoPreviewView.isHidden = true
                imgViews.append(videoPreviewView)
            }
            
        }
        
        return imgViews
    }()
    
    let colors : [UIColor] =  [.secondaryLabel,.brown,.cyan,.darkText,.green,.opaqueSeparator,.magenta]
    
    
    lazy var videoPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        return view
    }()
    
    
    
    
    var topViewIsHidden: Bool = false
   
    
    lazy var finishBtn: UIButton = {
        let finishBtn = UIButton.init(type: .custom)
        finishBtn.setTitle("Publish".localized, for: .normal)
        finishBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        finishBtn.layer.cornerRadius = 3
        finishBtn.layer.masksToBounds = true
        finishBtn.isEnabled = true
        finishBtn.tag = 2 //1 for next screen // 2 for completion
        finishBtn.addTarget(self, action: #selector(didFinishButtonClick(button:)), for: .touchUpInside)
        return finishBtn
    }()
    @objc func didFinishButtonClick(button: UIButton) {
        if button.tag == 1 {
            
            //            hx_delegate?.bottomView(didEditButtonClick: self)
        }
        else{
         
//
            publishAction()
//            hx_delegate?.bottomView(didFinishButtonClick: self)
        }
        
    }
    func publishAction(){
        
        if  let picker = pickerController{
            dismiss(animated: true, completion: nil)
            picker.finishHandler?(imageViews, picker)
            
            
        }
        if finishHandler == nil, cameraCloseAction != nil {
            cameraCloseAction!(imageViews)
//            delegate?.photoEditorViewController(<#T##photoEditorViewController: PhotoEditorViewController##PhotoEditorViewController#>, didFinish: <#T##PhotoEditResult#>)
//            if let photoEdit = editedResults[0] as? PhotoEditResult{
//                delegate?.photoEditorViewController(self, didFinish: photoEdit)
//            }
//            else if let videoEdit = editedResults[0] as? VideoEditResult{
//                delegate?.photoEditorViewController(self, didFinishVideo: videoEdit)
//            }
//            else{
//                delegate?.photoEditorViewController(didCancel: self)
//            }
            
        }
        
        
        return
        
//        ProgressHUD.showLoading(addedTo: view, text: "Processing...".localized, animated: true)
        
        
//        imageViews.enumerated().forEach { (index,view) in
//            if let photoEditorView = view as? PhotoEditorView{//image
//                
//
////                editorToolViews.enumerated().forEach { (index,editorToolView) in
//                    editorToolViews[index].delegate?.toolView(didFinishButtonClick: editorToolViews[index], forIndex: index)
////                }
//                
//               
//                
//            }else{//video
//                let views = view.subviews
//                if views.count > 0, let videoEditorview = views[0] as? VideoEditorView{
//                    
//                    videoEditorview.toolView.delegate?.toolView(didFinishButtonClick: videoEditorview.toolView, forIndex: index)
//                    return
//
////                    if let url = videoEditorview.videoView.imageResizerView.urlConfig{
////                        print("url found")
////                    }
//                }
//                else{
//                    //video not edited
//                    changeCurrentAsset(index, previewAssets[index])
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
//                        let views = view.subviews
//                        if views.count > 0, let videoEditorview = views[0] as? VideoEditorView{
//                            videoEditorview.toolView.delegate?.toolView(didFinishButtonClick: videoEditorview.toolView, forIndex: index)
//                        }
//                         
//                    }
//                    print("video not found")
//                }
//            }
//        }
//        
//        return
//        
//        if let edit = editResult{
//            delegate?.photoEditorViewController(self, didFinish: edit)
//        }
//        //exportResources()
//       
//        guard let pickerController = pickerController else {
//            return
//        }
//        
////        pickerController.finishCallback()
//     //   delegate?.photoEditorViewController(self, didFinish: editResult!)
//        
//        if !pickerController.selectedAssetArray.isEmpty {
////            dele
//            
////            delegate?.previewViewController(didFinishButton: self)
//            pickerController.finishCallback()
//            return
//        }
//        if assetCount == 0 {
//            ProgressHUD.showWarning(
//                addedTo: view,
//                text: "No optional resources".localized,
//                animated: true,
//                delayHide: 1.5
//            )
//            return
//        }
//        guard let photoAsset = photoAsset(for: currentPreviewIndex) else {
//            return
//        }
////        #if HXPICKER_ENABLE_EDITOR
//        if photoAsset.mediaType == .video &&
//            pickerController.videoDurationExceedsTheLimit(photoAsset: photoAsset) &&
//            pickerController.config.editorOptions.isVideo {
//            if pickerController.canSelectAsset(
//                for: photoAsset,
//                showHUD: true
//            ) {
//                openEditor(photoAsset)
//            }
//            return
//        }
////        #endif
//        func addAsset() {
//            if !isMultipleSelect {
//                if pickerController.canSelectAsset(
//                    for: photoAsset,
//                    showHUD: true
//                ) {
//                    if isExternalPickerPreview {
////                        delegate?.previewViewController(
////                            self,
////                            didSelectBox: photoAsset,
////                            isSelected: true,
////                            updateCell: false
////                        )
//                    }
////                    delegate?.previewViewController(didFinishButton: self)
//                    pickerController.singleFinishCallback(
//                        for: photoAsset
//                    )
//                }
//            }else {
//                if videoLoadSingleCell {
//                    if pickerController.canSelectAsset(
//                        for: photoAsset,
//                        showHUD: true
//                    ) {
//                        if isExternalPickerPreview {
////                            delegate?.previewViewController(
////                                self,
////                                didSelectBox: photoAsset,
////                                isSelected: true,
////                                updateCell: false
////                            )
//                        }
////                        delegate?.previewViewController(didFinishButton: self)
//                        pickerController.singleFinishCallback(
//                            for: photoAsset
//                        )
//                    }
//                }else {
//                    if pickerController.addedPhotoAsset(
//                        photoAsset: photoAsset
//                    ) {
//                        if isExternalPickerPreview {
////                            delegate?.previewViewController(
////                                self,
////                                didSelectBox: photoAsset,
////                                isSelected: true,
////                                updateCell: false
////                            )
//                        }
////                        delegate?.previewViewController(didFinishButton: self)
//                        pickerController.finishCallback()
//                    }
//                }
//            }
//        }
//        let inICloud = photoAsset.checkICloundStatus(
//            allowSyncPhoto: pickerController.config.allowSyncICloudWhenSelectPhoto
//        ) { _, isSuccess in
//            if isSuccess {
//                addAsset()
//            }
//        }
//        if !inICloud {
//            addAsset()
//        }
    }
    func checkResult(){
        if editedResults.count == self.imageViews.count{
            //call finishHandler
            ProgressHUD.hide(forView: self.view)
            print("same resuls")
            finishHandler?(self,editedResults)
            if finishHandler == nil, delegate != nil {
                if let photoEdit = editedResults[0] as? PhotoEditResult{
                    delegate?.photoEditorViewController(self, didFinish: photoEdit)
                }
                else if let videoEdit = editedResults[0] as? VideoEditResult{
                    delegate?.photoEditorViewController(self, didFinishVideo: videoEdit)
                }
                else{
                    delegate?.photoEditorViewController(didCancel: self)
                }
                
            }
//            editedResults.forEach { editedRes in
//                if let edit = editedRes as? PhotoEditResult{
//                    print("edited image")
//                  //  self.delegate?.photoEditorViewController(self, didFinish: edit)
//
////                    if autoBack {
////                        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
////                            navigationController.popViewController(animated: true)
////                        }else {
////                            dismiss(animated: true, completion: nil)
////                        }
////                    }
//
//
//                }
//                else if let edit = editedRes as? VideoEditResult{
//                    print("video edited")
//                    print(edit.editedURL)
//                }
//
//
//            }
            
            if  let picker = pickerController{
                
//                let assets = previewAssets
//
//                let result = PickerResult(photoAssets: assets, isOriginal: picker.isOriginal)
                
//                picker.pickerDelegate?.pickerController(picker, didFinishMultipleSelection: editedResults)
                
                picker.finishHandler?(editedResults, picker)
                
                dismiss(animated: true, completion: nil)
                
            }
            
            
//            pickerController?.finishCallback()
        }
        
    }
    
    func updateFinishButtonFrame() {
        
        var finishWidth: CGFloat = finishBtn.currentTitle!.localized.width(
            ofFont: finishBtn.titleLabel!.font,
            maxHeight: 50
        ) + 20
        if finishWidth < 60 {
            finishWidth = 60
        }
        finishBtn.frame = CGRect(
            x: bottomBGV.hx_width - UIDevice.rightMargin - finishWidth - 12,
            y: 0,
            width: finishWidth,
            height: 33
        )
        finishBtn.centerY = 25
    }
    
    func imageView()->PhotoEditorView?{
        
       if let currentImageView = imageViews[currentPreviewIndex] as? PhotoEditorView{
           imageViews.forEach { imgV in
               imgV.isHidden = true
           }
           currentImageView.isHidden = false
          return currentImageView
        }
        return nil
        
    }
    
    @objc func singleTap() {
        if state == .cropping {
            return
        }
        imageView()?.deselectedSticker()
        func resetOtherOption() {
            if let option = currentToolOption {
                if option.type == .graffiti {
                    imageView()?.drawEnabled = true
                }else if option.type == .mosaic {
                    imageView()?.mosaicEnabled = true
                }
            }
            showTopView()
        }
        if let type = currentToolOption?.type {
            if type == .filter {
                if isShowFilterParameter {
                    hideFilterParameterView()
                    return
                }
                currentToolOption = nil
                resetOtherOption()
                hiddenFilterView()
                imageView()?.canLookOriginal = false
                return
            }else if type == .chartlet {
                currentToolOption = nil
                imageView()?.isEnabled = true
                resetOtherOption()
                hiddenChartletView()
                return
            }
        }
        if topViewIsHidden {
            showTopView()
        }else {
            hidenTopView()
        }
    }
    
    func configButtonColor(){
        
//       let config = PickerBottomViewConfiguration()
//        
//        let finishBtnBackgroundColor = PhotoManager.isDark ?
//            config.finishButtonDarkBackgroundColor :
//            config.finishButtonBackgroundColor
        
//        finishBtn.setTitleColor(
//            PhotoManager.isDark ?
//                .white :
//                    .white,
//            for: .normal
//        )
//        finishBtn.setTitleColor(
//            PhotoManager.isDark ?
//                .white :
//                    .white,
//            for: .disabled
//        )
//        finishBtn.setBackgroundImage(
//            UIImage.image(
//                for: finishBtnBackgroundColor,
//                havingSize: CGSize.zero
//            ),
//            for: .normal
//        )
//        finishBtn.setBackgroundImage(
//            UIImage.image(
//                for: PhotoManager.isDark ?
//                    finishBtnBackgroundColor.withAlphaComponent(0.5) :
//                        finishBtnBackgroundColor.withAlphaComponent(0.5),
//                havingSize: CGSize.zero
//            ),
//            for: .disabled
//        )
        
        let background = UIColor.init(red: 0.027450980392156862, green: 0.75686274509803919, blue: 0.37647058823529411, alpha: 1)
        
        finishBtn.backgroundColor = background
        
    }
    /// 裁剪确认视图
    public lazy var cropConfirmViews: [EditorCropConfirmView] = {//bottom view of crop when select cropping tool
        var cropConfirmViews = [EditorCropConfirmView]()
         for _ in previewAssets {
             let cropConfirmView = EditorCropConfirmView.init(config: config[currentPreviewIndex].cropConfimView, showReset: true)
             cropConfirmView.alpha = 0
             cropConfirmView.isHidden = true
             cropConfirmView.delegate = self
//             cropConfirmView.backgroundColor = colors.randomElement() ?? .red
             cropConfirmViews.append(cropConfirmView)
         }
        return cropConfirmViews
    }()
    
    public lazy var editorToolViews: [EditorToolView] = {//top view whose present all menu item
        var views = [EditorToolView]()
        for _ in previewAssets {
            let toolView = EditorToolView.init(config: config[currentPreviewIndex].toolView)
            toolView.delegate = self
//            toolView.backgroundColor = .red
//            toolView.backgroundColor = colors.randomElement() ?? .red
            views.append(toolView)
            
        }
        
        
        return views
    }()
    
    func editorToolView()->EditorToolView{//top view whose present all menu item
        
        return editorToolViews[currentPreviewIndex]
    }
    
    public lazy var topView: UIView = {//parent of editortoolview and cancel button
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        view.addSubview(cancelBtn)
        
        return view
    }()
    
    public lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 44))
        cancelBtn.setImage(UIImage.image(for: config[currentPreviewIndex].backButtonImageName), for: .normal)
        cancelBtn.addTarget(self, action: #selector(didBackButtonClick), for: .touchUpInside)
        return cancelBtn
    }()
    
    @objc func didBackButtonClick() {
        transitionalImage = image
        cancelHandler?(self)
        didBackClick(true)
        
    }
    
    func didBackClick(_ isCancel: Bool = false) {
        imageView()?.imageResizerView.stopShowMaskBgTimer()
        if let type = currentToolOption?.type {
            switch type {
            case .graffiti:
                hiddenBrushColorView()
            case .mosaic:
                hiddenMosaicToolView()
            default:
                break
            }
        }
        if isCancel {
            delegate?.photoEditorViewController(didCancel: self)
        }
        if autoBack {
            if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            }else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public lazy var topMaskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(true)
        return layer
    }()
    lazy var brushBlockView: PhotoEditorBrushSizeView = {//brush size view at right when selected pencil from top
        let view = PhotoEditorBrushSizeView.init(frame: .init(x: 0, y: 0, width: 30, height: 200))
        view.alpha = 0
        view.isHidden = true
        view.value = config[currentPreviewIndex].brush.lineWidth / (config[currentPreviewIndex].brush.maximumLinewidth - config[currentPreviewIndex].brush.minimumLinewidth)
        view.blockBeganChanged = { [weak self] _ in
            guard let self = self else { return }
            guard let imageView = self.imageView() else { return  }
            let lineWidth = imageView.brushLineWidth + 4
            self.brushSizeView.hx_size = CGSize(width: lineWidth, height: lineWidth)
            self.brushSizeView.center = CGPoint(x: self.view.hx_width * 0.5, y: self.view.hx_height * 0.5)
            self.brushSizeView.alpha = 0
            self.view.addSubview(self.brushSizeView)
            UIView.animate(withDuration: 0.2) {
                self.brushSizeView.alpha = 1
            }
        }
        view.blockDidChanged = { [weak self] in
            guard let self = self else { return }
            let config = self.config[currentPreviewIndex].brush
            let lineWidth = (
                config.maximumLinewidth -  config.minimumLinewidth
            ) * $0 + config.minimumLinewidth
            self.imageView()?.brushLineWidth = lineWidth
            self.brushSizeView.hx_size = CGSize(width: lineWidth + 4, height: lineWidth + 4)
            self.brushSizeView.center = CGPoint(x: self.view.hx_width * 0.5, y: self.view.hx_height * 0.5)
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
    lazy var brushSizeView: BrushSizeView = {//when change size of brush circle will present at center of screen
        guard let imageView = self.imageView() else { return  BrushSizeView()}
        let lineWidth = imageView.brushLineWidth + 10
        let view = BrushSizeView(frame: CGRect(origin: .zero, size: CGSize(width: lineWidth, height: lineWidth)))
        return view
    }()
    public lazy var brushColorView: PhotoEditorBrushColorView = {//present color for drawing when click on pencil
        let view = PhotoEditorBrushColorView(config: config[currentPreviewIndex].brush)
        view.delegate = self
        view.alpha = 0
        view.isHidden = true
//        view.backgroundColor = .red
        return view
    }()
    lazy var chartletView: EditorChartletView = {//background view for emojis
        let view = EditorChartletView(
            config: config[currentPreviewIndex].chartlet,
            editorType: .photo
        )
        view.delegate = self
        view.backgroundColor = .red
        return view
    }()
    
    public lazy var cropToolViews: [PhotoEditorCropToolView] = {//show cropping option when select crop tool
        
        var cropToolViews = [PhotoEditorCropToolView]()
         for _ in previewAssets {
             var showRatios = true
             if config[currentPreviewIndex].cropping.aspectRatios.isEmpty || config[currentPreviewIndex].cropping.isRoundCrop {
                 showRatios = false
             }
             let view = PhotoEditorCropToolView(
                 showRatios: showRatios,
                 scaleArray: config[currentPreviewIndex].cropping.aspectRatios,
                 defaultSelectedIndex: config[currentPreviewIndex].cropping.defaultSeletedIndex
             )
             view.delegate = self
             view.themeColor = config[currentPreviewIndex].cropping.aspectRatioSelectedColor
             view.alpha = 0
             view.isHidden = true
//             view.backgroundColor = colors.randomElement() ?? .red
             cropToolViews.append(view)
         }

        
        return cropToolViews
    }()
    lazy var mosaicToolView: PhotoEditorMosaicToolView = {//show blur menu option
        let view = PhotoEditorMosaicToolView(selectedColor: config[currentPreviewIndex].toolView.toolSelectedColor)
        view.delegate = self
        view.alpha = 0
        view.isHidden = true
        
        return view
    }()
    var filterImages: [UIImage]?
    
    lazy var filterViews: [PhotoEditorFilterView] = {//filter view
        var filterViews = [PhotoEditorFilterView]()
        for (index,_) in previewAssets.enumerated() {
            let view = PhotoEditorFilterView(
                filterConfig: config[index].filter,
                hasLastFilter: editResult?.editedData.hasFilter ?? false
            )
            view.delegate = self
            filterViews.append(view)
        }
       
        
        return filterViews
    }()
    var isShowFilterParameter = false
    lazy var filterParameterView: PhotoEditorFilterParameterView = {//when click on screen adjustment then click on brightness thne this view will appear
        let view = PhotoEditorFilterParameterView(sliderColor: config[currentPreviewIndex].filter.selectedColor)
        view.delegate = self
        
        return view
    }()
    
    
    
    func filterImage()->UIImage?{
        return filterImages?[currentPreviewIndex]
    }
    
    func filterView()->PhotoEditorFilterView{
        return filterViews[currentPreviewIndex]
    }
    
    
    var imageInitializeCompletion = false
    var imageViewDidChange: Bool = true
    var currentToolOption: EditorToolOptions?
    var toolOptions: EditorToolView.Options = []
    
    
    func cropToolView()->PhotoEditorCropToolView{
        
       let cropToolView = cropToolViews[currentPreviewIndex]
       return cropToolView
    }
    func cropConfirmView()->EditorCropConfirmView{
        
       let cropToolView = cropConfirmViews[currentPreviewIndex]
       return cropToolView
    }
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        for options in config[currentPreviewIndex].toolView.toolOptions {
            switch options.type {
            case .graffiti:
                toolOptions.insert(.graffiti)
            case .chartlet:
                toolOptions.insert(.chartlet)
            case .text:
                toolOptions.insert(.text)
            case .cropSize:
                toolOptions.insert(.cropSize)
            case .mosaic:
                toolOptions.insert(.mosaic)
            case .filter:
                toolOptions.insert(.filter)
            case .music:
                toolOptions.insert(.music)
            default:
                break
            }
        }
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap))
        singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
        view.isExclusiveTouch = true
        view.backgroundColor = .black
        view.clipsToBounds = true
                
        
        
//        self.view.addSubview(videoPreviewView)
        
        imageViews.forEach { imageView in
            view.addSubview(imageView)
        }
        view.addSubview(topView)
        
        editorToolViews.forEach { editorView in
            topView.addSubview(editorView)
        }
        
        
        if toolOptions.contains(.cropSize) {
            cropConfirmViews.forEach { cropConfirmView in
                view.addSubview(cropConfirmView)
            }
            cropToolViews.forEach { cropToolView in
                view.addSubview(cropToolView)
            }
            
        }
        if config[currentPreviewIndex].fixedCropState {
            pState = .cropping
            editorToolViews.forEach { editorView in
//                editorView.alpha = 0
                editorView.isHidden = true
            }
            
            topView.alpha = 0
            topView.isHidden = true
        }else {
            pState = config[currentPreviewIndex].state
            if toolOptions.contains(.graffiti) {
                view.addSubview(brushColorView)
                view.addSubview(brushBlockView)
            }
            if toolOptions.contains(.chartlet) {
                //view.addSubview(chartletView)
            }
            if toolOptions.contains(.mosaic) {
                view.addSubview(mosaicToolView)
            }
            if toolOptions.contains(.filter) {
                filterViews.forEach { filterView in
                    view.addSubview(filterView)
                }
                
                view.addSubview(filterParameterView)
            }
        }
        view.layer.addSublayer(topMaskLayer)
        
//                editorToolView.backgroundColor = .darkGray
//                topView.backgroundColor = .cyan
        if needRequest {
            if requestType == 1 {
                //                #if HXPICKER_ENABLE_PICKER
                
                
                if previewAssets[0].mediaType == .video {
                    
                    imageViews[0].frame = CGRect(x: 0, y: topView.hx_height+UIDevice.topMargin, width: view.hx_width, height: view.hx_height-topView.hx_height-UIDevice.bottomMargin-UIDevice.topMargin)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.001) {
                        self.changeCurrentAsset(0, self.previewAssets[0])
                        
                    }
                    
//
//                    viewDidLayoutSubviews()
                    
                    
                    
                }
                else{
                    requestImage()
                }
//                requestImages()
                //                #endif
            }else if requestType == 2 {
#if canImport(Kingfisher)
                requestNetworkImage()
#endif
            }
        }
        else {
            if !config[currentPreviewIndex].fixedCropState {
                localImageHandler()
            }
        }
        initView()
        
       
        
    }
    //MARK: - video function
    
    //MARK: - Video function end
    open override func deviceOrientationWillChanged(notify: Notification) {
        orientationDidChange = true
        imageViewDidChange = false
        
        if let type = currentToolOption?.type,
           type == .chartlet {
            singleTap()
        }
        imageView()?.undoAllDraw()
        if toolOptions.contains(.graffiti) {
            if let imageview = imageView(){
                brushColorView.canUndo = imageview.canUndoDraw
            }
            
        }
        imageView()?.undoAllMosaic()
        if toolOptions.contains(.mosaic) {
            if let imageview = imageView(){
                mosaicToolView.canUndo = imageview.canUndoMosaic
            }
           
        }
        imageView()?.undoAllSticker()
        imageView()?.reset(false)
        imageView()?.finishCropping(false)
        imageView()?.imageResizerView.isDidFinishedClick = false
        cropToolView().resetSelected()
        if config[currentPreviewIndex].fixedCropState {
            return
        }
        pState = .normal
        croppingAction()
    }
    open override func deviceOrientationDidChanged(notify: Notification) {
        //        orientationDidChange = true
        //        imageViewDidChange = false
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
       
        
        
       
        topView.hx_y = 0
        topView.hx_width = view.hx_width
        topView.hx_height = UIDevice.isPortrait ? 44 : 32
        cancelBtn.hx_height = topView.hx_height
        cancelBtn.hx_x = UIDevice.leftMargin
        let viewControllersCount = navigationController?.viewControllers.count ?? 0
        if let modalPresentationStyle = navigationController?.modalPresentationStyle,
           UIDevice.isPortrait {
            if (modalPresentationStyle == .fullScreen ||
                modalPresentationStyle == .custom ||
                viewControllersCount > 1) &&
                modalPresentationStyle != .pageSheet {
                topView.hx_y = UIDevice.generalStatusBarHeight + 8
            }
        }else if (
            modalPresentationStyle == .fullScreen ||
            modalPresentationStyle == .custom ||
            viewControllersCount > 1
        ) && UIDevice.isPortrait && modalPresentationStyle != .pageSheet {
            topView.hx_y = UIDevice.generalStatusBarHeight + 8
        }
        
        editorToolViews.forEach { editorToolView in
            editorToolView.frame = CGRect(
                x: topView.hx_width - cancelBtn.frame.width - 240,
                    y: 0,
                    width: 320,
                    height: 44
                )
            editorToolView.reloadContentInset()
        }
        
        
        topMaskLayer.frame = CGRect(x: 0, y: 0, width: view.hx_width, height: topView.frame.maxY + 10)
        
        let cropToolFrame = CGRect(x: 0, y: editorToolView().hx_y + 80, width: view.hx_width, height: 60)
        
        let cropConfirmViewFrame = CGRect(x: 0, y: view.hx_height - 80, width: view.hx_width, height: 60)
        
        //        cropConfirmView.backgroundColor = .blue
        if toolOptions.contains(.cropSize) {
            cropConfirmViews.enumerated().forEach { (index,cropConfirmView) in
                cropConfirmView.frame = cropConfirmViewFrame //editorToolView.frame
                cropToolViews[index].frame = cropToolFrame
                cropToolViews[index].updateContentInset()
            }
            
        }
        if toolOptions.contains(.graffiti) {
            brushColorView.frame = CGRect(x: 0, y: editorToolView().hx_y + 80, width: view.hx_width, height: 65)
            brushBlockView.hx_x = view.hx_width - 45 - UIDevice.rightMargin
            if UIDevice.isPortrait {
                brushBlockView.centerY = view.hx_height * 0.5
            }else {
                brushBlockView.hx_y = brushColorView.hx_y - brushBlockView.hx_height
            }
        }
        if toolOptions.contains(.mosaic) {
            mosaicToolView.frame = cropToolFrame
        }
        if toolOptions.isSticker {
            //setChartletViewFrame()
        }
        if toolOptions.contains(.filter) {
            setFilterViewFrame()
            setFilterParameterViewFrame()
        }
        
        imageViews.forEach { imageView in
            
            if let imageView = imageView as? PhotoEditorView{
                if !imageView.frame.equalTo(view.bounds) && !imageView.frame.isEmpty && !imageViewDidChange {
                    imageView.frame = view.bounds
                    imageView.reset(false)
                    imageView.finishCropping(false)
                    imageView.imageResizerView.isDidFinishedClick = false
                    cropToolView().resetSelected()
                    orientationDidChange = true
                }else {
                    imageView.frame = view.bounds
                }
                if !imageInitializeCompletion {
                    if !needRequest || image != nil {
                        imageView.setImage(image)
                        //                setFilterImage()
                        if let editedData = editResult?.editedData {
                            imageView.setEditedData(editedData: editedData)
                            if toolOptions.contains(.graffiti) {
                                brushColorView.canUndo = imageView.canUndoDraw
                            }
                            if toolOptions.contains(.mosaic) {
                                mosaicToolView.canUndo = imageView.canUndoMosaic
                            }
                        }
                        imageInitializeCompletion = true
                        if transitionCompletion {
                            initializeStartCropping()
                        }
                    }
                }
                if orientationDidChange {
                    imageView.orientationDidChange()
                    if config[currentPreviewIndex].fixedCropState {
                        imageView.startCropping(false)
                    }
                    orientationDidChange = false
                    imageViewDidChange = true
                }
                
                
            }
            else{
                imageView.frame = CGRect(x: 0, y: topView.hx_height+UIDevice.topMargin, width: view.hx_width, height: view.hx_height-topView.hx_height-UIDevice.bottomMargin-UIDevice.topMargin)
            }
            
            

        }
        
        //End
        didLayoutBottomSubviews()
        updateFinishButtonFrame()
        
//        videoPreviewView.frame = CGRect(x: 0, y: topView.hx_height+UIDevice.topMargin, width: view.hx_width, height: view.hx_height-topView.hx_height-UIDevice.bottomMargin-UIDevice.topMargin)
        
       
    }
    func didLayoutBottomSubviews(){
        let margin: CGFloat = 8
        let itemWidth = 40 + margin
        let cvSize = CGSize(width: 40, height: 48)
        collectionViewLayout.minimumLineSpacing = margin
        collectionViewLayout.itemSize = cvSize
        let contentWidth = (view.hx_width + itemWidth) * CGFloat(assetCount)
        
        bottomBGV.frame = CGRect(x: 0, y: view.hx_height - cvSize.height - UIDevice.bottomMargin - margin, width: view.hx_width, height: cvSize.height)
        
        
        collectionView.frame = CGRect(x: 0, y: 0 , width: bottomBGV.hx_width, height: bottomBGV.hx_height)
        
        collectionView.contentSize = CGSize(width: contentWidth, height: view.hx_height)
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentPreviewIndex) * itemWidth, y: 0), animated: false)
        
        
    }
    private func configureBottomBGV(){
        bottomBGV = UIView()
        bottomBGV.addSubview(collectionView)
        bottomBGV.addSubview(finishBtn)
        self.view.addSubview(bottomBGV)
//        self.view.bringSubviewToFront(finishBtn)
//        self.bottomBGV.sendSubviewToBack(collectionView)
        configButtonColor()
                
    }
    private func initView() {
        
        configureBottomBGV()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.selectFirstCell()
        }
        
    }
    
    private func selectFirstCell(){
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? PhotoEditorPreviewCell{
            
           // cell.isSelected = true
            
           // collectionView(collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        }
    }
    func initializeStartCropping() {
        if !imageInitializeCompletion || state != .cropping {
            return
        }
        imageView()?.startCropping(true)
        croppingAction()
    }
    func setChartletViewFrame() {
        var viewHeight = config[currentPreviewIndex].chartlet.viewHeight
        if viewHeight > view.hx_height {
            viewHeight = view.hx_height * 0.6
        }
        if let type = currentToolOption?.type,
           type == .chartlet {
            chartletView.frame = CGRect(
                x: 0,
                y: view.hx_height - viewHeight - UIDevice.bottomMargin,
                width: view.hx_width,
                height: viewHeight + UIDevice.bottomMargin
            )
        }else {
            chartletView.frame = CGRect(
                x: 0,
                y: view.hx_height,
                width: view.hx_width,
                height: viewHeight + UIDevice.bottomMargin
            )
        }
    }
    func setFilterViewFrame() {
        let filterHeight: CGFloat
#if canImport(Harbeth)
        filterHeight = 155 + UIDevice.bottomMargin
#else
        filterHeight = 125 + UIDevice.bottomMargin
#endif
        if let type = currentToolOption?.type,
           type == .filter {
            filterView().frame = CGRect(
                x: 0,
                y: view.hx_height - filterHeight,
                width: view.hx_width,
                height: filterHeight
            )
        }else {
            filterView().frame = CGRect(
                x: 0,
                y: view.hx_height + 10,
                width: view.hx_width,
                height: filterHeight
            )
        }
    }
    func setFilterParameterViewFrame() {
        let editHeight = max(CGFloat(filterParameterView.models.count) * 40 + 30 + UIDevice.bottomMargin, filterView().hx_height)
        if isShowFilterParameter {
            filterParameterView.frame = .init(
                x: 0,
                y: view.hx_height - editHeight,
                width: view.hx_width,
                height: editHeight
            )
        }else {
            filterParameterView.frame = .init(
                x: 0,
                y: view.hx_height,
                width: view.hx_width,
                height: editHeight
            )
        }
    }
    open override var prefersStatusBarHidden: Bool {
        return config[currentPreviewIndex].prefersStatusBarHidden
    }
    open override var prefersHomeIndicatorAutoHidden: Bool {
        false
    }
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .all
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController != self &&
            navigationController?.viewControllers.contains(self) == false {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.viewControllers.count == 1 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let isHidden = navigationController?.navigationBar.isHidden, !isHidden {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    func setImage(_ image: UIImage) {
        self.image = image
    }
    
    func photoAsset(for index: Int) -> PhotoAsset? {
        if !previewAssets.isEmpty && index > 0 || index < previewAssets.count {
            return previewAssets[index]
        }
        return assetForIndex?(index)
    }
    
//    func getCell(for item: Int) -> PhotoPreviewViewCell? {
//        if assetCount == 0 {
//            return nil
//        }
//        let cell = collectionView.cellForItem(
//            at: IndexPath(
//                item: item,
//                section: 0
//            )
//        ) as? PhotoPreviewViewCell
//        return cell
//    }
    
    func getEditorCell(for item: Int) -> PhotoEditorPreviewCell? {
        if assetCount == 0 {
            return nil
        }
        let cell = collectionView.cellForItem(
            at: IndexPath(
                item: item,
                section: 0
            )
        ) as? PhotoEditorPreviewCell
        return cell
    }

}
