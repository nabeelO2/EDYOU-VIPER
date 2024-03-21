//
//  PhotoEditorViewController+EditorView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/11/15.
//

import UIKit

// MARK: PhotoEditorViewDelegate
extension PhotoEditorViewController: PhotoEditorViewDelegate {
    func checkResetButton() {
        if let imageView = imageView(){
            cropConfirmView().resetButton.isEnabled = imageView.canReset()
        }
        
    }
    func editorView(willBeginEditing editorView: PhotoEditorView) {
    }
    
    func editorView(didEndEditing editorView: PhotoEditorView) {
        checkResetButton()
    }
    
    func editorView(willAppearCrop editorView: PhotoEditorView) {
        cropToolView().reset(animated: false)
        cropConfirmView().resetButton.isEnabled = false
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
        mosaicToolView.canUndo = editorView.canUndoMosaic
    }
    func editorView(_ editorView: PhotoEditorView, updateStickerText item: EditorStickerItem) {
        let textVC = EditorStickerTextViewController(
            config: config[currentPreviewIndex].text,
            stickerItem: item
        )
        textVC.delegate = self
        let nav = EditorStickerTextController(rootViewController: textVC)
        nav.modalPresentationStyle = config[currentPreviewIndex].text.modalPresentationStyle
        present(nav, animated: true, completion: nil)
    }
    func editorView(didRemoveAudio editorView: PhotoEditorView) {
        
    }
}
