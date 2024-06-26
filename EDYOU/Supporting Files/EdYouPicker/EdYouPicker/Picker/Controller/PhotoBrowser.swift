//
//  PhotoBrowser.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/6.
//

import UIKit

open class PhotoBrowser: PhotoPickerController {
    
    /// 当前页面
    public var pageIndex : Int {
        get { currentPreviewIndex }
        set { previewViewController?.scrollToItem(newValue) }
    }
    
    /// 页面数
    public var pageCount: Int {
        if previewAssets.isEmpty {
            return numberOfPages?() ?? 0
        }else {
            return previewAssets.count
        }
    }
    
    /// 当前页面对应的 PhotoAsset 对象
    public var currentAsset: PhotoAsset? {
        if previewAssets.isEmpty {
            return assetForIndex?(pageIndex)
        }else {
            return previewAssets[pageIndex]
        }
    }
    
    /// 初始转场动画中显示的 image
    public var transitionalImage: UIImage?
    
    /// 转场动画时触发
    public var transitionAnimator: TransitionAnimator?
    
    /// 删除预览资源时触发
    public var deleteAssetHandler: AssetHandler?
    
    /// 长按时触发
    public var longPressHandler: AssetHandler?
    
    /// 页面指示器，nil则不显示
    public var pageIndicator: PhotoBrowserPageIndicator? = PhotoBrowserDefaultPageIndicator(frame: .init(origin: .zero, size: .init(width: 100, height: 30)))
    
    /// 获取页数
    /// 动态设置数据时必须实现（assets.isEmpty）
    public var numberOfPages: NumberOfPagesHandler? {
        didSet { previewViewController?.numberOfPages = numberOfPages }
    }
    
    /// 当内部需要用到 PhotoAsset 对象时触发
    /// 动态设置数据时必须实现（assets.isEmpty）
    public var assetForIndex: RequiredAsset? {
        didSet { previewViewController?.assetForIndex = assetForIndex }
    }
    
    /// Cell刷新显示，`func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell`调用时触发
    public var cellForIndex: CellReloadContext? {
        didSet { previewViewController?.cellForIndex = cellForIndex }
    }
    
    /// cell即将展示
    public var cellWillDisplay: ContextUpdate?
    
    /// cell已经消失
    public var cellDidEndDisplaying: ContextUpdate?
    
    /// 界面发生滚动时触发
    public var viewDidScroll: ContextUpdate?
    
    /// 界面停止滚动时触发
    public var viewDidEndDecelerating: ContextUpdate?
    
    public var viewWillAppear: ViewLifeCycleHandler?
    public var viewDidAppear: ViewLifeCycleHandler?
    public var viewWillDisappear: ViewLifeCycleHandler?
    public var viewDidDisappear: ViewLifeCycleHandler?
    
    /// 初始化浏览器
    /// - Parameters:
    ///   - config: 浏览器配置
    ///   - pageIndex: 当前预览的页面
    ///   - assets: 预览的数据，如果为空则会通过 `numberOfPages、assetForIndex` 闭包动态获取
    ///   - transitionalImage: 初始转场动画显示的image
    public init(
        _ config: Configuration = .init(),
        pageIndex: Int = 0,
        assets: [PhotoAsset] = [],
        transitionalImage: UIImage? = nil
    ) {
        let _config = PhotoBrowser.getConfig(config)
        hideSourceView = _config.browserConfig.hideSourceView
        self.transitionalImage = transitionalImage
        super.init(
            preview: _config.previeConfig,
            previewAssets: assets,
            currentIndex: pageIndex,
            modalPresentationStyle: _config.browserConfig.modalPresentationStyle
        )
        isShowDelete = _config.browserConfig.showDelete
        pickerDelegate = self
    }
    
    @discardableResult
    public class func show(
        _ config: Configuration = .init(),
        pageIndex: Int = 0,
        fromVC: UIViewController? = nil,
        transitionalImage: UIImage? = nil,
        numberOfPages: @escaping NumberOfPagesHandler,
        assetForIndex: @escaping RequiredAsset,
        transitionAnimator: TransitionAnimator? = nil,
        cellForIndex: CellReloadContext? = nil,
        cellWillDisplay: ContextUpdate? = nil,
        cellDidEndDisplaying: ContextUpdate? = nil,
        viewDidScroll: ContextUpdate? = nil,
        deleteAssetHandler: AssetHandler? = nil,
        longPressHandler: AssetHandler? = nil
    ) -> PhotoBrowser {
        let browser = PhotoBrowser(
            config,
            pageIndex: pageIndex,
            transitionalImage: transitionalImage
        )
        browser.transitionAnimator = transitionAnimator
        browser.numberOfPages = numberOfPages
        browser.assetForIndex = assetForIndex
        browser.cellWillDisplay = cellWillDisplay
        browser.cellDidEndDisplaying = cellDidEndDisplaying
        browser.viewDidScroll = viewDidScroll
        browser.deleteAssetHandler = deleteAssetHandler
        browser.longPressHandler = longPressHandler
        browser.show(fromVC)
        return browser
    }
    
    /// 显示图片浏览器
    /// - Parameters:
    ///   - previewAssets: 对应 PhotoAsset 的数组
    ///   - pageIndex: 当前预览的位置
    ///   - config: 相关配置
    ///   - fromVC: 来源控制器
    ///   - transitionalImage: 初始转场动画时展示的 UIImage
    ///   - transitionHandler: 转场过渡
    ///   - deleteAssetHandler: 删除资源
    ///   - longPressHandler: 长按事件
    /// - Returns: 对应的 PhotoBrowser
    @discardableResult
    public class func show(
        _ previewAssets: [PhotoAsset],
        pageIndex: Int = 0,
        config: Configuration = .init(),
        fromVC: UIViewController? = nil,
        transitionalImage: UIImage? = nil,
        transitionHandler: TransitionAnimator? = nil,
        deleteAssetHandler: AssetHandler? = nil,
        longPressHandler: AssetHandler? = nil
    ) -> PhotoBrowser {
        let browser = PhotoBrowser(
            config,
            pageIndex: pageIndex,
            assets: previewAssets,
            transitionalImage: transitionalImage
        )
        browser.transitionAnimator = transitionHandler
        browser.deleteAssetHandler = deleteAssetHandler
        browser.longPressHandler = longPressHandler
        browser.show(fromVC)
        return browser
    }
    
    /// UICollectionView insertItems
    public func insertIndex(_ index: Int) {
        previewViewController?.insert(at: index)
    }
    public func insertAsset(_ asset: PhotoAsset, at index: Int) {
        previewViewController?.insert(asset, at: index)
    }
    
    /// UICollectionView deleteItems
    public func deleteIndexs(_ indexs: [Int]) {
        previewViewController?.deleteItems(at: indexs)
    }
    
    /// 获取对应 index 的 cell 对象
    public func getCell(for index: Int) -> PhotoPreviewViewCell? {
        previewViewController?.getCell(for: index)
    }
    
    /// UICollectionView reloadData
    public func reloadData() {
        previewViewController?.collectionView.reloadData()
    }
    public func reloadData(for index: Int) {
        previewViewController?.reloadCell(for: index)
    }
    
    public func show(
        _ fromVC: UIViewController? = nil,
        animated flag: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        (fromVC ?? UIViewController.topViewController)?.present(
            self,
            animated: flag,
            completion: completion
        )
    }
    
    private static func getConfig(
        _ config: Configuration?
    ) -> (previeConfig: PickerConfiguration, browserConfig: Configuration) {
        let previewConfig = PickerConfiguration()
        previewConfig.prefersStatusBarHidden = true
        previewConfig.statusBarStyle = .lightContent
        previewConfig.adaptiveBarAppearance = false
        
        var pConfig = PreviewViewConfiguration()
        pConfig.singleClickCellAutoPlayVideo = false
        pConfig.showBottomView = false
        pConfig.cancelType = .image
        pConfig.cancelPosition = .left
        
        let browserConfig: Configuration = config ?? .init()
        pConfig.loadNetworkVideoMode = browserConfig.loadNetworkVideoMode
        pConfig.customVideoCellClass = browserConfig.customVideoCellClass
        pConfig.backgroundColor = browserConfig.backgroundColor
        pConfig.livePhotoPlayType = browserConfig.livePhotoPlayType
        pConfig.videoPlayType = browserConfig.videoPlayType
        
        previewConfig.previewView = pConfig
        previewConfig.navigationTintColor = browserConfig.tintColor
        
        return (previewConfig, browserConfig)
    }
    
    let hideSourceView: Bool
    
    fileprivate lazy var gradualShadowImageView: UIImageView = {
        let navHeight = navigationBar.hx_height
        let view = UIImageView(
            image: UIImage.gradualShadowImage(
                CGSize(
                    width: view.hx_width,
                    height: UIDevice.isAllIPhoneX ? navHeight + 60 : navHeight + 30
                )
            )
        )
        view.alpha = 0
        return view
    }()
    
    fileprivate var didHidden: Bool = false
    
    @objc func deletePreviewAsset() {
        if pageCount == 0 {
            return
        }
        guard let asset = currentAsset else {
            return
        }
        deleteAssetHandler?(
            pageIndex,
            asset,
            self
        )
    }
    
    private var isShowDelete: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if previewAssets.isEmpty {
            assert(
                numberOfPages != nil &&
                assetForIndex != nil,
                "previewAssets为空时，numberOfPages、assetForIndex 必须实现"
            )
        }
        if isShowDelete {
            previewViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Delete".localized,
                style: .done,
                target: self,
                action: #selector(deletePreviewAsset)
            )
        }
        navigationBar.shadowImage = UIImage.image(
            for: UIColor.clear,
            havingSize: .zero
        )
        navigationBar.barTintColor = .clear
        navigationBar.backgroundColor = .clear
        view.insertSubview(gradualShadowImageView, belowSubview: navigationBar)
        pageIndicator?.reloadData(numberOfPages: pageCount, pageIndex: currentPreviewIndex)
        previewViewController?.navigationItem.titleView = pageIndicator
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageHeight = UIDevice.isAllIPhoneX ? navigationBar.hx_height + 54 : navigationBar.hx_height + 30
        gradualShadowImageView.frame = CGRect(origin: .zero, size: CGSize(width: view.hx_width, height: imageHeight))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoBrowser {
    
    /// Cell刷新显示，`func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell`调用时触发
    /// (刷新对应的Cell，cell对应的index，当前界面显示的index)
    public typealias CellReloadContext = (PhotoPreviewViewCell, Int, Int) -> Void
    /// 当内部需要用到 PhotoAsset 对象时触发
    /// (对应的index) -> index对应的 PhotoAsset 对象
    public typealias RequiredAsset = (Int) -> PhotoAsset?
    /// 获取总页数 -> 总页数
    public typealias NumberOfPagesHandler = () -> Int
    /// (当前界面显示的Cell，当前界面显示的index)
    public typealias ContextUpdate = (PhotoPreviewViewCell, Int, PhotoBrowser) -> Void
    /// (当前转场动画对应的index) -> 动画开始/结束位置对应的View，用于获取坐标
    public typealias TransitionAnimator = (Int) -> UIView?
    /// (当前界面显示的index，对应的 PhotoAsset 对象，照片浏览器对象)
    public typealias AssetHandler = (Int, PhotoAsset, PhotoBrowser) -> Void
    /// (当前界面显示的index，照片浏览器对象)
    public typealias ViewLifeCycleHandler = (PhotoBrowser) -> Void
    
    public struct Configuration {
        /// 导航栏 删除、取消 按钮颜色
        public var tintColor: UIColor = .white
        /// 网络视频加载方式
        public var loadNetworkVideoMode: PhotoAsset.LoadNetworkVideoMode = .play
        /// 自定义视频Cell，默认带有滑动条
        public var customVideoCellClass: PreviewVideoViewCell.Type? = PreviewVideoControlViewCell.self
        /// 视频播放类型
        public var videoPlayType: PhotoPreviewViewController.PlayType = .normal
        /// LivePhoto播放类型
        public var livePhotoPlayType: PhotoPreviewViewController.PlayType = .once
        /// 背景颜色
        public var backgroundColor: UIColor = .black
        /// 显示删除按钮
        public var showDelete: Bool = false
        /// 转场动画过程中是否隐藏原视图
        public var hideSourceView: Bool = true
        /// 跳转样式
        public var modalPresentationStyle: UIModalPresentationStyle = .custom
        
        public init() { }
    }
}

extension PhotoBrowser: PhotoPickerControllerDelegate {
    public func pickerController(_ pickerController: PhotoPickerController, didFinishMultipleSelection result: [Any]) {
        print(result.count)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        viewControllersWillAppear viewController: UIViewController
    ) {
        navigationBar
            .setBackgroundImage(
                UIImage.image(for: UIColor.clear, havingSize: .zero),
                for: .default
            )
        viewWillAppear?(self)
    }
    
    public func pickerController(_ pickerController: PhotoPickerController, viewControllersDidAppear viewController: UIViewController) {
        viewDidAppear?(self)
    }
    
    public func pickerController(_ pickerController: PhotoPickerController, viewControllersWillDisappear viewController: UIViewController) {
        viewWillDisappear?(self)
    }
    
    public func pickerController(_ pickerController: PhotoPickerController, viewControllersDidDisappear viewController: UIViewController) {
        viewDidDisappear?(self)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewSingleClick photoAsset: PhotoAsset,
        atIndex: Int
    ) {
        if photoAsset.mediaType == .photo {
            pickerController.dismiss(animated: true, completion: nil)
        }else {
            didHidden = !didHidden
            UIView.animate(withDuration: 0.25) {
                self.gradualShadowImageView.alpha = self.didHidden ? 0 : 1
            } completion: { _ in
                self.gradualShadowImageView.alpha = self.didHidden ? 0 : 1
            }
        }
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewUpdateCurrentlyDisplayedAsset photoAsset: PhotoAsset,
        atIndex: Int
    ) {
        if let cell = previewViewController?.getCell(for: atIndex) {
            viewDidScroll?(cell, atIndex, self)
        }
        pageIndicator?.didChanged(pageIndex: atIndex)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewDidDeleteAssets photoAssets: [PhotoAsset],
        at indexs: [Int]
    ) {
        pageIndicator?.reloadData(numberOfPages: pageCount, pageIndex: pageIndex)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewLongPressClick photoAsset: PhotoAsset,
        atIndex: Int
    ) {
        longPressHandler?(atIndex, photoAsset, self)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewCellWillDisplay photoAsset: PhotoAsset,
        at index: Int
    ) {
        if let cell = getCell(for: index) {
            cellWillDisplay?(cell, index, self)
        }
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewCellDidEndDisplaying photoAsset: PhotoAsset,
        at index: Int
    ) {
        if let cell = getCell(for: index) {
            cellDidEndDisplaying?(cell, index, self)
        }
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        previewDidEndDecelerating photoAsset: PhotoAsset,
        at index: Int
    ) {
        if let cell = getCell(for: index) {
            viewDidEndDecelerating?(cell, index, self)
        }
    }
    
    // MARK: 单独预览时的自定义转场动画
    /// present预览时展示的image
    /// - Parameters:
    ///   - pickerController: 对应的 PhotoPickerController
    ///   - index: 预览资源对应的位置
    public func pickerController(
        _ pickerController: PhotoPickerController,
        presentPreviewImageForIndexAt index: Int
    ) -> UIImage? {
        transitionalImage
    }
    
    /// present 预览时起始的视图，用于获取位置大小。与 presentPreviewFrameForIndexAt 一样
    public func pickerController(
        _ pickerController: PhotoPickerController,
        presentPreviewViewForIndexAt index: Int
    ) -> UIView? {
        transitionAnimator?(index)
    }
    
    /// dismiss 结束时对应的视图，用于获取位置大小。与 dismissPreviewFrameForIndexAt 一样
    public func pickerController(
        _ pickerController: PhotoPickerController,
        dismissPreviewViewForIndexAt index: Int
    ) -> UIView? {
        transitionAnimator?(index)
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        animateTransition type: PickerTransitionType
    ) {
        gradualShadowImageView.alpha = type == .present ? 1 : 0
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        interPercentUpdate scale: CGFloat,
        type: PickerInteractiveTransitionType
    ) {
        if didHidden { return }
        gradualShadowImageView.alpha = scale
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        interPercentDidFinishAnimation type: PickerInteractiveTransitionType
    ) {
        gradualShadowImageView.alpha = 0
    }
    
    public func pickerController(
        _ pickerController: PhotoPickerController,
        interPercentDidCancelAnimation type: PickerInteractiveTransitionType
    ) {
        if !didHidden {
            gradualShadowImageView.alpha = 1
        }
    }
}

public protocol PhotoBrowserPageIndicator: UIView {
    
    /// 刷新指示器
    /// - Parameters:
    ///   - numberOfPages: 页面总数
    ///   - pageIndex: 当前显示的页面下标
    func reloadData(numberOfPages: Int, pageIndex: Int)
    
    /// 当前页面发生改变
    /// - Parameter pageIndex: 当前显示的页面下标
    func didChanged(pageIndex: Int)
}

open class PhotoBrowserDefaultPageIndicator: UIView, PhotoBrowserPageIndicator {
    
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.semiboldPingFang(ofSize: 17)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    public var numberOfPages: Int = 0
    public var pageIndex: Int = 0 {
        didSet {
            titleLabel.text = String(pageIndex + 1) + "/" + String(numberOfPages)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData(numberOfPages: Int, pageIndex: Int) {
        self.numberOfPages = numberOfPages
        self.pageIndex = pageIndex
    }
    
    public func didChanged(pageIndex: Int) {
        self.pageIndex = pageIndex
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
}
