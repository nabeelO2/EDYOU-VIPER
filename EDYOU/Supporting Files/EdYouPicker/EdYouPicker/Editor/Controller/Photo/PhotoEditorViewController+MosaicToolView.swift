//
//  PhotoEditorViewController+MosaicToolView.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/11/15.
//

import UIKit

extension PhotoEditorViewController: PhotoEditorMosaicToolViewDelegate {
    func mosaicToolView(
        _ mosaicToolView: PhotoEditorMosaicToolView,
        didChangedMosaicType type: PhotoEditorMosaicView.MosaicType
    ) {
        imageView()?.mosaicType = type
    }
    
    func mosaicToolView(didUndoClick mosaicToolView: PhotoEditorMosaicToolView) {
        imageView()?.undoMosaic()
        if let imageView = imageView(){
            mosaicToolView.canUndo = imageView.canUndoMosaic
        }
       
    }
}
