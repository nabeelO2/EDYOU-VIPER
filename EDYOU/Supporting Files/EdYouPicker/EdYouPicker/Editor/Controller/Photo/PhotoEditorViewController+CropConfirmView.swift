//
//  PhotoEditorViewController+CropConfirmView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/11/15.
//

import UIKit

// MARK: EditorCropConfirmViewDelegate
extension PhotoEditorViewController: EditorCropConfirmViewDelegate {
    
    /// 点击完成按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didFinishButtonClick cropConfirmView: EditorCropConfirmView) {
        if config[currentPreviewIndex].fixedCropState {
            imageView()?.imageResizerView.finishCropping(false, completion: nil, updateCrop: false)
            if config[currentPreviewIndex].cropping.isRoundCrop {
                imageView()?.imageResizerView.layer.cornerRadius = 1
            }
            exportResources(currentPreviewIndex)
            return
        }
        pState = .normal
        cropToolView().tmpLastSelectedModel = cropToolView().currentSelectedModel
        cropToolView().resetLast()
        imageView()?.finishCropping(true)
        croppingAction()
    }
    
    /// 点击还原按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didResetButtonClick cropConfirmView: EditorCropConfirmView) {
        cropConfirmView.resetButton.isEnabled = false
        imageView()?.reset(true)
        cropToolView().lastSelectedModel = nil
        cropToolView().reset(animated: true)
    }
    
    /// 点击取消按钮
    /// - Parameter cropConfirmView: 裁剪视图
    func cropConfirmView(didCancelButtonClick cropConfirmView: EditorCropConfirmView) {
        if config[currentPreviewIndex].fixedCropState {
            transitionalImage = image
            cancelHandler?(self)
            didBackClick(true)
            return
        }
        pState = .normal
        imageView()?.cancelCropping(true)
        cropToolView().resetLast()
        croppingAction()
    }
}
