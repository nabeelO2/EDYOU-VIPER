//
//  PhotoEditorViewController+ToolView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/9/16.
//

import UIKit

extension PhotoEditorViewController: EditorToolViewDelegate {
    func toolView(didFinishButtonClick toolView: EditorToolView, forIndex : Int) {
        exportResources(forIndex)
    }
    func toolView(_ toolView: EditorToolView, didSelectItemAt model: EditorToolOptions) {
        switch model.type {
        case .graffiti:
            currentToolOption = nil
            imageView()?.mosaicEnabled = false
            hiddenMosaicToolView()
            if let imageView = imageView(){
                imageView.drawEnabled = !imageView.drawEnabled
                toolView.stretchMask = imageView.drawEnabled
                if imageView.drawEnabled {
                    imageView.stickerEnabled = false
                    showBrushColorView()
                    currentToolOption = model
                }else {
                    imageView.stickerEnabled = true
                    hiddenBrushColorView()
                }
            }
           
            
            
            toolView.layoutSubviews()
            
        case .chartlet:
            deselectedDraw()
            chartletView.firstRequest()
            imageView()?.deselectedSticker()
            disableImageSubView()
            imageView()?.isEnabled = false
            currentToolOption = model
            hidenTopView()
            showChartletView()
           
        case .text:
            deselectedDraw()
            imageView()?.deselectedSticker()
            presentText()
        case .cropSize:
            disableImageSubView()
            pState = .cropping
            imageView()?.startCropping(true)
            croppingAction()
        case .mosaic:
            currentToolOption = nil
            imageView()?.drawEnabled = false
            hiddenBrushColorView()
            if let imageView = imageView(){
                imageView.mosaicEnabled = !imageView.mosaicEnabled
                toolView.stretchMask = imageView.mosaicEnabled
                if imageView.mosaicEnabled {
                    imageView.stickerEnabled = false
                    showMosaicToolView()
                    currentToolOption = model
                }else {
                    imageView.stickerEnabled = true
                    hiddenMosaicToolView()
                }
            }
            
            toolView.layoutSubviews()
            
        case .filter:
            deselectedDraw()
            disableImageSubView()
            hidenTopView()
            currentToolOption = model
            showFilterView()
            imageView()?.canLookOriginal = true
        default:
            break
        }
    }
    
    func deselectedDraw() {
        currentToolOption = nil
        imageView()?.drawEnabled = false
        hiddenBrushColorView()
        imageView()?.mosaicEnabled = false
        hiddenMosaicToolView()
        editorToolView().deselected()
    }
    
    func disableImageSubView() {
        imageView()?.drawEnabled = false
        imageView()?.mosaicEnabled = false
        imageView()?.stickerEnabled = false
        bottomBGV.isHidden = true
    }
    
    func presentText() {
        let textVC = EditorStickerTextViewController(config: config[currentPreviewIndex].text)
        textVC.delegate = self
        let nav = EditorStickerTextController(rootViewController: textVC)
        nav.modalPresentationStyle = config[currentPreviewIndex].text.modalPresentationStyle
        present(nav, animated: true, completion: nil)
    }
}
