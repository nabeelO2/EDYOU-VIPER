//
//  VideoEditorViewController+PlayerView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/6.
//

import UIKit
import AVKit

// MARK: VideoEditorPlayerViewDelegate
extension VideoEditorView: VideoEditorPlayerViewDelegate {
    func playerView(_ playerViewReadyForDisplay: VideoEditorPlayerView) {
        if firstPlay {
            if state == .cropTime {
                pState = .normal
                toolCropTimeClick()
            }
            firstPlay = false
        }
    }
    
    func playerView(_ playerView: VideoEditorPlayerView, didPlayAt time: CMTime) {
        if state == .cropTime {
            cropView.startLineAnimation(at: time)
        }
    }
    
    func playerView(_ playerView: VideoEditorPlayerView, didPauseAt time: CMTime) {
        if state == .cropTime {
            cropView.stopLineAnimation()
        }
    }
    func playerView(beganDrag playerView: VideoEditorPlayerView) {
        if !topView.isHidden {
            hidenTopView()
        }
    }
    func playerView(endDrag playerView: VideoEditorPlayerView) {
        if topView.isHidden {
            showTopView()
        }
    }
    func playerView(_ playerView: VideoEditorPlayerView, updateStickerText item: EditorStickerItem) {
        if config.text.modalPresentationStyle == .fullScreen {
            isPresentText = true
        }
        let textVC = EditorStickerTextViewController(
            config: config.text,
            stickerItem: item
        )
        textVC.delegate = self
        let nav = EditorStickerTextController(rootViewController: textVC)
        nav.modalPresentationStyle = config.text.modalPresentationStyle
//        present(nav, animated: true, completion: nil)
    }
}

// MARK: PhotoEditorViewDelegate
extension VideoEditorView: PhotoEditorViewDelegate {
    func checkResetButton() {
        cropConfirmView.resetButton.isEnabled = videoView.canReset()
    }
    func editorView(willBeginEditing editorView: PhotoEditorView) {
    }
    
    func editorView(didEndEditing editorView: PhotoEditorView) {
        checkResetButton()
    }
    
    func editorView(willAppearCrop editorView: PhotoEditorView) {
        cropToolView.reset(animated: false)
        cropConfirmView.resetButton.isEnabled = false
    }
    
    func editorView(didAppear editorView: PhotoEditorView) {
        checkResetButton()
    }
    
    func editorView(willDisappearCrop editorView: PhotoEditorView) {
    }
    
    func editorView(didDisappearCrop editorView: PhotoEditorView) {
    }
    
    func editorView(drawViewBeganDraw editorView: PhotoEditorView) {
        hidenTopView()
    }
    
    func editorView(drawViewEndDraw editorView: PhotoEditorView) {
        showTopView()
        brushColorView.canUndo = editorView.canUndoDraw
    }
    func editorView(_ editorView: PhotoEditorView, updateStickerText item: EditorStickerItem) {
        let textVC = EditorStickerTextViewController(
            config: config.text,
            stickerItem: item
        )
        textVC.delegate = self
        let nav = EditorStickerTextController(rootViewController: textVC)
        nav.modalPresentationStyle = config.text.modalPresentationStyle
//        present(nav, animated: true, completion: nil)
    }
    func editorView(didRemoveAudio editorView: PhotoEditorView) {
        musicView.showLyricButton.isSelected = false
    }
}

extension VideoEditorView: PhotoEditorBrushColorViewDelegate {
    func brushColorView(didUndoButton colorView: PhotoEditorBrushColorView) {
        videoView.undoDraw()
        brushColorView.canUndo = videoView.canUndoDraw
    }
    func brushColorView(_ colorView: PhotoEditorBrushColorView, changedColor colorHex: String) {
        videoView.drawColorHex = colorHex
    }
    func brushColorView(_ colorView: PhotoEditorBrushColorView, changedColor color: UIColor) {
        videoView.drawColor = color
    }
}

extension VideoEditorView: EditorChartletViewDelegate {
    func chartletView(backClick chartletView: EditorChartletView) {
        singleTap()
    }
    
    func chartletView(
        _ chartletView: EditorChartletView,
        loadTitleChartlet response: @escaping EditorTitleChartletResponse
    ) {
        if let editorDelegate = delegate {
            editorDelegate.videoEditorViewController(
                self,
                loadTitleChartlet: response
            )
        }else {
            #if canImport(Kingfisher)
            let titles = PhotoTools.defaultTitleChartlet()
            response(titles)
            #else
            response([])
            #endif
        }
    }
    
    func chartletView(
        _ chartletView: EditorChartletView,
        titleChartlet: EditorChartlet,
        titleIndex: Int,
        loadChartletList response: @escaping EditorChartletListResponse
    ) {
        if let editorDelegate = delegate {
            editorDelegate.videoEditorViewController(
                self,
                titleChartlet: titleChartlet,
                titleIndex: titleIndex,
                loadChartletList: response
            )
        }else {
            // 默认加载这些贴图
            #if canImport(Kingfisher)
            let chartletList = PhotoTools.defaultNetworkChartlet()
            response(titleIndex, chartletList)
            #else
            response(titleIndex, [])
            #endif
        }
    }
    
    func chartletView(
        _ chartletView: EditorChartletView,
        didSelectImage image: UIImage,
        imageData: Data?
    ) {
        let item = EditorStickerItem(
            image: image,
            imageData: imageData,
            text: nil
        )
        videoView.addSticker(item: item, isSelected: false)
        singleTap()
    }
}
