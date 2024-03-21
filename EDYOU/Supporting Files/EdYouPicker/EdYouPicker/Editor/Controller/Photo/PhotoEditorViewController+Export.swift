//
//  PhotoEditorViewController+Export.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/7/14.
//

import UIKit

extension PhotoEditorViewController {
    func exportResources(_ index : Int) {
        let imageView = imageViews[index]
            if let imageView = imageView as? PhotoEditorView{
                if imageView.canReset() ||
                    imageView.imageResizerView.hasCropping ||
                    imageView.canUndoDraw ||
                    imageView.canUndoMosaic ||
                    imageView.hasFilter ||
                    imageView.hasSticker {
                    imageView.deselectedSticker()
                    
                    imageView.cropping { [weak self] in
                        guard let self = self else { return }
                        if let result = $0 {
                            //                        ProgressHUD.hide(forView: self.view, animated: false)
                            self.isFinishedBack = true
                            self.transitionalImage = result.editedImage
                            self.editedResults.append(result)
                            
                            //                        self.delegate?.photoEditorViewController(self, didFinish: result)
                            //                        self.finishHandler?(self, result)
                            //                        self.didBackClick()
                        }else {
                            
                            self.editedResults.append("image not found")
                            //                        ProgressHUD.hide(forView: self.view, animated: true)
                            //                        ProgressHUD.showWarning(
                            //                            addedTo: self.view,
                            //                            text: "Processing failed".localized,
                            //                            animated: true,
                            //                            delayHide: 1.5
                            //                        )
                        }
                    }
                } else {
                    imageView.cropping { result in
                        if let res = result{
                            print(res)
                            self.transitionalImage = res.editedImage
                          
                            self.editedResults.append(res)
                        }
                        else {
                            //return original image
//                            let img = (self.previewAssets[index].originalImage ?? self.image)!
                            guard  let img = imageView.imageResizerView.imageView.originalImage else { return}
                            self.transitionalImage = img
                            let photoEditResult = PhotoEditResult(editedImage: img, urlConfig: EditorURLConfig(fileName: "", type: .caches), imageType: .normal, editedData: PhotoEditData(isPortrait: true, cropData: nil, brushData: [], hasFilter: false, filterImageURL: nil, mosaicData: [], stickerData: nil))
                            self.editedResults.append(photoEditResult)
                        }
                    }
                    
                    
                }
            
        }
        
        
        
        
    }
}
