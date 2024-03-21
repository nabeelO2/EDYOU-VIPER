//
//  YPImagePicker.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public protocol EDImagePickerDelegate: AnyObject {
    func imagePickerHasNoItemsInLibrary(_ picker: EDImagePicker)
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
}

open class EDImagePicker: UINavigationController {
    public typealias DidFinishPickingCompletion = (_ items: [EDMediaItem], _ cancelled: Bool) -> Void

    // MARK: - Public

    public weak var imagePickerDelegate: EDImagePickerDelegate?
    public func didFinishPicking(completion: @escaping DidFinishPickingCompletion) {
        _didFinishPicking = completion
    }

    /// Get a YPImagePicker instance with the default configuration.
    public convenience init() {
        self.init(configuration: EDImagePickerConfiguration.shared)
    }

    /// Get a YPImagePicker with the specified configuration.
    public required init(configuration: EDImagePickerConfiguration) {
        EDImagePickerConfiguration.shared = configuration
        picker = EDPickerVC()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen // Force .fullScreen as iOS 13 now shows modals as cards by default.
        picker.pickerVCDelegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return EDImagePickerConfiguration.shared.preferredStatusBarStyle
    }

    // MARK: - Private

    private var _didFinishPicking: DidFinishPickingCompletion?

    // This nifty little trick enables us to call the single version of the callbacks.
    // This keeps the backwards compatibility keeps the api as simple as possible.
    // Multiple selection becomes available as an opt-in.
    private func didSelect(items: [EDMediaItem]) {
        _didFinishPicking?(items, false)
    }
    
    private let loadingView = EDLoadingView()
    private let picker: EDPickerVC!

    override open func viewDidLoad() {
        super.viewDidLoad()
        picker.didClose = { [weak self] in
            self?._didFinishPicking?([], true)
        }
        viewControllers = [picker]
        setupLoadingView()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .ypLabel
        view.backgroundColor = .ypSystemBackground

        picker.didSelectItems = { [weak self] items in
            // Use Fade transition instead of default push animation
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            self?.view.layer.add(transition, forKey: nil)
            
            // Multiple items flow
            if items.count > 1 {
                if EDConfig.library.skipSelectionsGallery {
                    self?.didSelect(items: items)
                    return
                } else {
                    let selectionsGalleryVC = EDSelectionsGalleryVC(items: items) { _, items in
                        self?.didSelect(items: items)
                    }
                    self?.pushViewController(selectionsGalleryVC, animated: true)
                    return
                }
            }
            
            // One item flow
            let item = items.first!
            switch item {
            case .photo(let photo):
                let completion = { (photo: EDMediaPhoto) in
                    let mediaItem = EDMediaItem.photo(p: photo)
                    // Save new image or existing but modified, to the photo album.
                    if EDConfig.shouldSaveNewPicturesToAlbum {
                        let isModified = photo.modifiedImage != nil
                        if photo.fromCamera || (!photo.fromCamera && isModified) {
                            EDPhotoSaver.trySaveImage(photo.image, inAlbumNamed: EDConfig.albumName)
                        }
                    }
                    self?.didSelect(items: [mediaItem])
                }
                
                func showCropVC(photo: EDMediaPhoto, completion: @escaping (_ aphoto: EDMediaPhoto) -> Void) {
                    switch EDConfig.showsCrop {
                    case .rectangle, .circle:
                        let cropVC = EDCropVC(image: photo.image)
                        cropVC.didFinishCropping = { croppedImage in
                            photo.modifiedImage = croppedImage
                            completion(photo)
                        }
                        self?.pushViewController(cropVC, animated: true)
                    default:
                        completion(photo)
                    }
                }
                
                if EDConfig.showsPhotoFilters {
                    let filterVC = EDPhotoFiltersVC(inputPhoto: photo,
                                                    isFromSelectionVC: false)
                    // Show filters and then crop
                    filterVC.didSave = { outputMedia in
                        if case let EDMediaItem.photo(outputPhoto) = outputMedia {
                            //showCropVC(photo: outputPhoto, completion: completion)
                            completion(outputPhoto)
                        }
                    }
                    self?.pushViewController(filterVC, animated: false)
                } else {
                    showCropVC(photo: photo, completion: completion)
                }
            case .video(let video):
                if EDConfig.showsVideoTrimmer {
                    let videoFiltersVC = EDVideoFiltersVC.initWith(video: video,
                                                                   isFromSelectionVC: false)
                    videoFiltersVC.didSave = { [weak self] outputMedia in
                        self?.didSelect(items: [outputMedia])
                    }
                    self?.pushViewController(videoFiltersVC, animated: true)
                } else {
                    self?.didSelect(items: [EDMediaItem.video(v: video)])
                }
            }
        }
    }
    
    deinit {
        EDLog("Picker deinited 👍")
    }
    
    private func setupLoadingView() {
        view.subviews(
            loadingView
        )
        loadingView.fillContainer()
        loadingView.alpha = 0
    }
}

extension EDImagePicker: YPPickerVCDelegate {
    func libraryHasNoItems() {
        self.imagePickerDelegate?.imagePickerHasNoItemsInLibrary(self)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return self.imagePickerDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections)
            ?? true
    }
}
