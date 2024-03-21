//
//  CameraViewController+Editor.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/31.
//

import UIKit

//#if HXPICKER_ENABLE_EDITOR
extension CameraViewController: PhotoEditorViewControllerDelegate {
    func openPhotoEditor(_ image: UIImage) {
        let local = LocalImageAsset(image: image)
        let photoasset = PhotoAsset(localImageAsset: local)
        let vc = PhotoEditorViewController(
            image: image,
            config: config.photoEditor
        )
        vc.previewAssets = [photoasset]
        vc.autoBack = autoDismiss
        vc.delegate = self
        vc.cameraCloseAction = { views in
            self.dismiss(animated: true)
            self.delegate?.cameraViewController(self, didFinishWithViews: views)
            
        }
        
         
        navigationController?.pushViewController(vc, animated: false)
    }
    public func photoEditorViewController(
        _ photoEditorViewController: PhotoEditorViewController,
        didFinish result: PhotoEditResult
    ) {

//         if let image = UIImage(contentsOfFile: result.editedImageURL.path) {
            didFinish(withResult: result)
//        }
    }
    
    public func photoEditorViewController(_ photoEditorViewController: PhotoEditorViewController, didFinishVideo result: VideoEditResult) {

        didFinish(withResult: result)
        
//        didFinish(withVideo: result.editedURL)
    }
    
    public func photoEditorViewController(didFinishWithUnedited photoEditorViewController: PhotoEditorViewController) {
        if let picker = pickerController {
//            picker.finishHandler?([result], picker)
//            picker.dismiss(animated: true)
        }
        
        didFinish(withImage: photoEditorViewController.image)
    }
}
extension CameraViewController: VideoEditorViewControllerDelegate {
    func openVideoEditor(_ videoURL: URL) {
//        let vc = VideoEditorViewController(
//            videoURL: videoURL,
//            config: config.videoEditor
//        )
//        vc.autoBack = autoDismiss
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: false)
        
        
//        if let image = videoURL.getThumbnailImage(){
//            let local = LocalVideoAsset(videoURL: videoURL)
//            let photoasset = PhotoAsset(localVideoAsset: local)
//
//            let vc = PhotoEditorViewController(
//                image: image,
//                config: config.photoEditor
//            )
//            vc.previewAssets = [photoasset]
//            vc.autoBack = autoDismiss
//            vc.delegate = self
//            vc.cameraCloseAction = { views in
//                self.dismiss(animated: true)
//                self.delegate?.cameraViewController(self, didFinishWithViews: views)
//
//            }
//
//
//            navigationController?.pushViewController(vc, animated: false)
//        }
//        else{
            
            
            let local = LocalVideoAsset(videoURL: videoURL)
            let photoasset = PhotoAsset(localVideoAsset: local)
            
            let vc = PhotoEditorViewController(
                photoAsset: photoasset, config: config.photoEditor
            )
            
            vc.previewAssets = [photoasset]
            vc.autoBack = autoDismiss
            vc.delegate = self
            
            vc.cameraCloseAction = { views in
                self.dismiss(animated: true)
                self.delegate?.cameraViewController(self, didFinishWithViews: views)
                
            }
            
            navigationController?.pushViewController(vc, animated: false)
            
//        }
        
        
        
    }
    public func videoEditorViewController(
        _ videoEditorViewController: VideoEditorView,
        didFinish result: VideoEditResult
    ) {
        didFinish(withVideo: result.editedURL)
    }
    
    public func videoEditorViewController(didFinishWithUnedited videoEditorViewController: VideoEditorView) {
        if let videoURL = videoEditorViewController.videoURL {
            didFinish(withVideo: videoURL)
        }
    }
}
//#endif

