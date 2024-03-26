//
//  YYPPickerVC.swift
//  YPPickerVC
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos

protocol YPPickerVCDelegate: AnyObject {
    func libraryHasNoItems()
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
}

open class EDPickerVC: EDBottomPager, YPBottomPagerDelegate {
    
    let albumsManager = EDAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    weak var pickerVCDelegate: YPPickerVCDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && EDConfig.hidesStatusBar
    }
    
    /// Private callbacks to YPImagePicker
    public var didClose:(() -> Void)?
    public var didSelectItems: (([EDMediaItem]) -> Void)?
    
    enum Mode {
        case library
        case camera
        case video
    }
    
    private var libraryVC: EDLibraryVC?
    private var cameraVC: EDCameraVC?
    private var videoVC: EDVideoCaptureVC?
    
    var mode = Mode.camera
    
    var capturedImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = EDConfig.colors.safeAreaBackgroundColor
        
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if EDConfig.library.minNumberOfItems > 1 {
            EDImagePickerConfiguration.shared.screens = [.library]
        }
        
        // Library
        if EDConfig.screens.contains(.library) {
            libraryVC = EDLibraryVC()
            libraryVC?.delegate = self
        }
        
        // Camera
        if EDConfig.screens.contains(.photo) {
            cameraVC = EDCameraVC()
            cameraVC?.didCapturePhoto = { [weak self] img in
                self?.didSelectItems?([EDMediaItem.photo(p: EDMediaPhoto(image: img,
                                                                         fromCamera: true))])
            }
        }
        
        // Video
        if EDConfig.screens.contains(.video) {
            videoVC = EDVideoCaptureVC()
            videoVC?.didCaptureVideo = { [weak self] videoURL in
                self?.didSelectItems?([EDMediaItem
                                        .video(v: EDMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                                               videoURL: videoURL,
                                                               fromCamera: true))])
            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in EDConfig.screens {
            switch screen {
            case .library:
                if let libraryVC = libraryVC {
                    vcs.append(libraryVC)
                }
            case .photo:
                if let cameraVC = cameraVC {
                    vcs.append(cameraVC)
                }
            case .video:
                if let videoVC = videoVC {
                    vcs.append(videoVC)
                }
            }
        }
        controllers = vcs
        
        // Select good mode
        if EDConfig.screens.contains(EDConfig.startOnScreen) {
            switch EDConfig.startOnScreen {
            case .library:
                mode = .library
            case .photo:
                mode = .camera
            case .video:
                mode = .video
            }
        }
        
        // Select good screen
        if let index = EDConfig.screens.firstIndex(of: EDConfig.startOnScreen) {
            startOnPage(index)
        }
        
        EDHelper.changeBackButtonIcon(self)
        EDHelper.changeBackButtonTitle(self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraVC?.v.shotButton.isEnabled = true
        
        updateMode(with: currentController)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = true
        initialStatusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    func modeFor(vc: UIViewController) -> Mode {
        switch vc {
        case is EDLibraryVC:
            return .library
        case is EDCameraVC:
            return .camera
        case is EDVideoCaptureVC:
            return .video
        default:
            return .camera
        }
    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        updateMode(with: vc)
    }
    
    func updateMode(with vc: UIViewController) {
        stopCurrentCamera()
        
        // Set new mode
        mode = modeFor(vc: vc)
        
        // Re-trigger permission check
        if let vc = vc as? EDLibraryVC {
            vc.doAfterLibraryPermissionCheck { [weak vc] in
                vc?.initialize()
            }
        } else if let cameraVC = vc as? EDCameraVC {
            cameraVC.start()
        } else if let videoVC = vc as? EDVideoCaptureVC {
            videoVC.start()
        }

        updateUI()
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .library:
            libraryVC?.pausePlayer()
        case .camera:
            cameraVC?.stopCamera()
        case .video:
            videoVC?.stopCamera()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideStatusBar = false
    }
    
    deinit {
        stopAll()
        EDLog("YPPickerVC deinited ✅")
    }
    
    @objc
    func navBarTapped() {
        guard !(libraryVC?.isProcessing ?? false) else {
            return
        }
        
        let vc = EDAlbumVC(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.tintColor = .ypLabel
        
        vc.didSelectAlbum = { [weak self] album in
            self?.libraryVC?.setAlbum(album)
            self?.setTitleViewWithTitle(aTitle: album.title)
            navVC.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        let label = UILabel()
        label.text = aTitle
        // Use YPConfig font
        label.font = EDConfig.fonts.pickerTitleFont

        // Use custom textColor if set by user.
        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            label.textColor = navBarTitleColor
        }
        
        if EDConfig.library.options != nil {
            titleView.subviews(
                label
            )
            |-(>=8)-label.centerHorizontally()-(>=8)-|
            align(horizontally: label)
        } else {
            let arrow = UIImageView()
            arrow.image = EDConfig.icons.arrowDownIcon
            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = .ypLabel
            
            let attributes = UINavigationBar.appearance().titleTextAttributes
            if let attributes = attributes, let foregroundColor = attributes[.foregroundColor] as? UIColor {
                arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
                arrow.tintColor = foregroundColor
            }
            
            let button = UIButton()
            button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
            button.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), forState: .highlighted)
            
            titleView.subviews(
                label,
                arrow,
                button
            )
            button.fillContainer()
            |-(>=8)-label.centerHorizontally()-arrow-(>=8)-|
            align(horizontally: label-arrow)
        }
        
        label.firstBaselineAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14).isActive = true
        
        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.titleView = titleView
    }
    
    func updateUI() {
        if !EDConfig.hidesCancelButton {
            // Update Nav Bar state.
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: EDConfig.wordings.cancel,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(close))
        }
        switch mode {
        case .library:
            setTitleViewWithTitle(aTitle: libraryVC?.title ?? "")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: EDConfig.wordings.next,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(done))
            navigationItem.rightBarButtonItem?.tintColor = EDConfig.colors.tintColor

            // Disable Next Button until minNumberOfItems is reached.
            navigationItem.rightBarButtonItem?.isEnabled =
                libraryVC!.selectedItems.count >= EDConfig.library.minNumberOfItems

        case .camera:
            navigationItem.titleView = nil
            title = cameraVC?.title
            navigationItem.rightBarButtonItem = nil
        case .video:
            navigationItem.titleView = nil
            title = videoVC?.title
            navigationItem.rightBarButtonItem = nil
        }

        navigationItem.rightBarButtonItem?.setFont(font: EDConfig.fonts.rightBarButtonFont, forState: .normal)
        navigationItem.rightBarButtonItem?.setFont(font: EDConfig.fonts.rightBarButtonFont, forState: .disabled)
        navigationItem.leftBarButtonItem?.setFont(font: EDConfig.fonts.leftBarButtonFont, forState: .normal)
    }
    
    @objc
    func close() {
        // Cancelling exporting of all videos
        if let libraryVC = libraryVC {
            libraryVC.mediaManager.forseCancelExporting()
        }
        self.didClose?()
    }
    
    // When pressing "Next"
    @objc
    func done() {
        guard let libraryVC = libraryVC else { EDLog("YPLibraryVC deallocated"); return }
        
        if mode == .library {
            libraryVC.selectedMedia(photoCallback: { photo in
                self.didSelectItems?([EDMediaItem.photo(p: photo)])
            }, videoCallback: { video in
                self.didSelectItems?([EDMediaItem
                                        .video(v: video)])
            }, multipleItemsCallback: { items in
                self.didSelectItems?(items)
            })
        }
    }
    
    func stopAll() {
        libraryVC?.v.assetZoomableView.videoView.deallocate()
        videoVC?.stopCamera()
        cameraVC?.stopCamera()
    }
}

extension EDPickerVC: EDLibraryViewDelegate {
    
    public func libraryViewDidTapNext() {
        libraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = false
            self.libraryVC?.v.fadeInLoader()
            self.navigationItem.rightBarButtonItem = EDLoaders.defaultLoader
        }
    }
    
    public func libraryViewStartedLoadingImage() {
        // TODO remove to enable changing selection while loading but needs cancelling previous image requests.
        libraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.libraryVC?.v.fadeInLoader()
        }
    }
    
    public func libraryViewFinishedLoading() {
        libraryVC?.isProcessing = false
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = EDConfig.isScrollToChangeModesEnabled
            self.libraryVC?.v.hideLoader()
            self.updateUI()
        }
    }
    
    public func libraryViewDidToggleMultipleSelection(enabled: Bool) {
        var offset = v.header.frame.height
        if #available(iOS 11.0, *) {
            offset += v.safeAreaInsets.bottom
        }
        
        v.header.bottomConstraint?.constant = enabled ? offset : 0
        v.layoutIfNeeded()
        updateUI()
    }
    
    public func libraryViewHaveNoItems() {
        pickerVCDelegate?.libraryHasNoItems()
    }
    
    public func libraryViewShouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return pickerVCDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections) ?? true
    }
}