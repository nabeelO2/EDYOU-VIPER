//
//  SelectionsGalleryVC.swift
//  YPImagePicker
//
//  Created by Nik Kov || nik-kov.com on 09.04.18.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

public class EDSelectionsGalleryVC: UIViewController, EDSelectionsGalleryCellDelegate {
    
    override public var prefersStatusBarHidden: Bool { return EDConfig.hidesStatusBar }
    
    public var items: [EDMediaItem] = []
    public var didFinishHandler: ((_ gallery: EDSelectionsGalleryVC, _ items: [EDMediaItem]) -> Void)?
    private var lastContentOffsetX: CGFloat = 0
    
    var v = EDSelectionsGalleryView()
    public override func loadView() { view = v }

    public required init(items: [EDMediaItem],
                         didFinishHandler:
        @escaping ((_ gallery: EDSelectionsGalleryVC, _ items: [EDMediaItem]) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.didFinishHandler = didFinishHandler
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Register collection view cell
        v.collectionView.register(EDSelectionsGalleryCell.self, forCellWithReuseIdentifier: "item")
        v.collectionView.dataSource = self
        v.collectionView.delegate = self
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: EDConfig.wordings.next,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done))
        navigationItem.rightBarButtonItem?.tintColor = EDConfig.colors.tintColor
        navigationItem.rightBarButtonItem?.setFont(font: EDConfig.fonts.rightBarButtonFont, forState: .disabled)
        navigationItem.rightBarButtonItem?.setFont(font: EDConfig.fonts.rightBarButtonFont, forState: .normal)
        navigationController?.navigationBar.setTitleFont(font: EDConfig.fonts.navigationBarTitleFont)
        
        EDHelper.changeBackButtonIcon(self)
        EDHelper.changeBackButtonTitle(self)
    }

    @objc
    private func done() {
        // Save new images to the photo album.
        if EDConfig.shouldSaveNewPicturesToAlbum {
            for m in items {
                if case let .photo(p) = m, let modifiedImage = p.modifiedImage {
                    EDPhotoSaver.trySaveImage(modifiedImage, inAlbumNamed: EDConfig.albumName)
                }
            }
        }
        didFinishHandler?(self, items)
    }
    
    public func selectionsGalleryCellDidTapRemove(cell: EDSelectionsGalleryCell) {
        if let indexPath = v.collectionView.indexPath(for: cell) {
            items.remove(at: indexPath.row)
            v.collectionView.performBatchUpdates({
                v.collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in })
        }
    }
}

// MARK: - Collection View
extension EDSelectionsGalleryVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item",
                                                            for: indexPath) as? EDSelectionsGalleryCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let item = items[indexPath.row]
        switch item {
        case .photo(let photo):
            cell.imageView.image = photo.image
            cell.setEditable(EDConfig.showsPhotoFilters)
        case .video(let video):
            cell.imageView.image = video.thumbnail
            cell.setEditable(EDConfig.showsVideoTrimmer)
        }
        cell.removeButton.isHidden = EDConfig.gallery.hidesRemoveButton
        return cell
    }
}

extension EDSelectionsGalleryVC: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        var mediaFilterVC: IsMediaFilterVC?
        switch item {
        case .photo(let photo):
            if !EDConfig.filters.isEmpty, EDConfig.showsPhotoFilters {
                mediaFilterVC = EDPhotoFiltersVC(inputPhoto: photo, isFromSelectionVC: true)
            }
        case .video(let video):
            if EDConfig.showsVideoTrimmer {
                mediaFilterVC = EDVideoFiltersVC.initWith(video: video, isFromSelectionVC: true)
            }
        }
        
        mediaFilterVC?.didSave = { outputMedia in
            self.items[indexPath.row] = outputMedia
            collectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        mediaFilterVC?.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        if let mediaFilterVC = mediaFilterVC as? UIViewController {
            let navVC = UINavigationController(rootViewController: mediaFilterVC)
            navVC.navigationBar.isTranslucent = false
            navVC.navigationBar.backgroundColor = EDConfig.colors.defaultNavigationBarColor
            present(navVC, animated: true, completion: nil)
        }
    }
    
    // Set "paging" behaviour when scrolling backwards.
    // This works by having `targetContentOffset(forProposedContentOffset: withScrollingVelocity` overriden
    // in the collection view Flow subclass & using UIScrollViewDecelerationRateFast
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingBackwards = scrollView.contentOffset.x < lastContentOffsetX
        scrollView.decelerationRate = isScrollingBackwards
            ? UIScrollView.DecelerationRate.fast
            : UIScrollView.DecelerationRate.normal
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
