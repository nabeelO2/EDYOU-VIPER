//
//  PhotoPickerView+Editor.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/9/17.
//

import UIKit

//#if HXPICKER_ENABLE_EDITOR && HXPICKER_ENABLE_PICKER
extension PhotoPickerView: PhotoEditorViewControllerDelegate {
    
    public func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinishVideo result: VideoEditResult) {
        
    }
    
    public func photoEditorViewController(
        _ photoEditorViewController: PhotoEditorViewController,
        didFinish result: PhotoEditResult
    ) {
        let photoAsset = photoEditorViewController.photoAsset()
        photoAsset.photoEdit = result
        if !isMultipleSelect {
            if manager.canSelectAsset(for: photoAsset, showHUD: true) {
                manager.addedPhotoAsset(photoAsset: photoAsset)
                finishSelectionAsset([photoAsset])
            }
            return
        }
        if !photoAsset.isSelected {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
            if manager.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }else {
            reloadCell(for: photoAsset)
        }
    }
    public func photoEditorViewController(
        didFinishWithUnedited photoEditorViewController: PhotoEditorViewController
    ) {
        let photoAsset = photoEditorViewController.photoAsset()
        photoAsset.photoEdit = nil
        if !isMultipleSelect {
            if manager.canSelectAsset(for: photoAsset, showHUD: true) {
                manager.addedPhotoAsset(photoAsset: photoAsset)
                finishSelectionAsset([photoAsset])
            }
            return
        }
        let cell = getCell(for: photoAsset)
        cell?.photoAsset = photoAsset
        if !photoAsset.isSelected {
            if manager.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }
    }
    public func photoEditorViewController(
        _ photoEditorViewController: PhotoEditorViewController,
        loadTitleChartlet response: @escaping ([EditorChartlet]) -> Void) {
        guard let delegate = delegate else {
            #if canImport(Kingfisher)
            let titles = PhotoTools.defaultTitleChartlet()
            response(titles)
            #else
            response([])
            #endif
            return
        }
        delegate.photoPickerView(
            self,
            loadTitleChartlet: photoEditorViewController,
            response: response
        )
    }
    public func photoEditorViewController(
        _ photoEditorViewController: PhotoEditorViewController,
        titleChartlet: EditorChartlet,
        titleIndex: Int,
        loadChartletList response: @escaping (Int, [EditorChartlet]) -> Void) {
        guard let delegate = delegate else {
            #if canImport(Kingfisher)
            let chartletList = PhotoTools.defaultNetworkChartlet()
            response(titleIndex, chartletList)
            #else
            response(titleIndex, [])
            #endif
            return
        }
        delegate.photoPickerView(
            self,
            loadChartletList: photoEditorViewController,
            titleChartlet: titleChartlet,
            titleIndex: titleIndex,
            response: response
        )
    }
}

extension PhotoPickerView: VideoEditorViewControllerDelegate {
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        loadTitleChartlet response: @escaping EditorTitleChartletResponse) {
        guard let delegate = delegate else {
            #if canImport(Kingfisher)
            let titles = PhotoTools.defaultTitleChartlet()
            response(titles)
            #else
            response([])
            #endif
            return
        }
        delegate.photoPickerView(
            self,
            loadTitleChartlet: videoEditorViewController,
            response: response
        )
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        titleChartlet: EditorChartlet,
        titleIndex: Int,
        loadChartletList response: @escaping EditorChartletListResponse) {
        guard let delegate = delegate else {
            #if canImport(Kingfisher)
            let chartletList = PhotoTools.defaultNetworkChartlet()
            response(titleIndex, chartletList)
            #else
            response(titleIndex, [])
            #endif
            return
        }
        delegate.photoPickerView(
            self,
            loadChartletList: videoEditorViewController,
            titleChartlet: titleChartlet,
            titleIndex: titleIndex,
            response: response
        )
    }
    public func videoEditorViewController(
        shouldClickMusicTool videoEditorViewController: VideoEditorView
    ) -> Bool {
        if let shouldClick = delegate?.photoPickerView(
            self,
            videoEditorShouldClickMusicTool: videoEditorViewController
           ) {
            return shouldClick
        }
        return true
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        loadMusic completionHandler: @escaping ([VideoEditorMusicInfo]) -> Void
    ) -> Bool {
        guard let delegate = delegate else {
            completionHandler(PhotoTools.defaultMusicInfos())
            return false
        }
        return delegate.photoPickerView(
            self,
            videoEditor: videoEditorViewController,
            loadMusic: completionHandler
        )
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        didSearch text: String?,
        completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void
    ) {
        guard let delegate = delegate else {
            completionHandler([], false)
            return
        }
        delegate.photoPickerView(
            self,
            videoEditor: videoEditorViewController,
            didSearch: text,
            completionHandler: completionHandler
        )
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        loadMore text: String?,
        completionHandler: @escaping ([VideoEditorMusicInfo], Bool) -> Void
    ) {
        guard let delegate = delegate else {
            completionHandler([], false)
            return
        }
        delegate.photoPickerView(
            self,
            videoEditor: videoEditorViewController,
            loadMore: text,
            completionHandler: completionHandler
        )
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        didFinish result: VideoEditResult
    ) {
        let photoAsset = videoEditorViewController.photoAsset!
        photoAsset.videoEdit = result
        if (photoAsset.mediaType == .video && videoLoadSingleCell) || !isMultipleSelect {
            if manager.canSelectAsset(for: photoAsset, showHUD: true) {
                manager.addedPhotoAsset(photoAsset: photoAsset)
                finishSelectionAsset([photoAsset])
            }
            return
        }
        if !photoAsset.isSelected {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
            if manager.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }else {
            reloadCell(for: photoAsset)
        }
    }
    public func videoEditorViewController(
        didFinishWithUnedited videoEditorViewController: VideoEditorView
    ) {
        let photoAsset = videoEditorViewController.photoAsset!
        let beforeHasEdit = photoAsset.videoEdit != nil
        photoAsset.videoEdit = nil
        if (photoAsset.mediaType == .video && videoLoadSingleCell) || !isMultipleSelect {
            if manager.canSelectAsset(for: photoAsset, showHUD: true) {
                manager.addedPhotoAsset(photoAsset: photoAsset)
                finishSelectionAsset([photoAsset])
            }
            return
        }
        if beforeHasEdit {
            let cell = getCell(for: photoAsset)
            cell?.photoAsset = photoAsset
        }
        if !photoAsset.isSelected {
            if manager.addedPhotoAsset(photoAsset: photoAsset) {
                updateCellSelectedTitle()
            }
        }
    }
}

//#endif
