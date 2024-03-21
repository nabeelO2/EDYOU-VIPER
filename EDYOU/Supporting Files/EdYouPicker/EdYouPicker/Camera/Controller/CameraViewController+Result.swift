//
//  CameraViewController+Result.swift
//  CameraViewController+Result
//
//  Created by imac3 on 2021/10/19.
//

import UIKit
import CoreLocation

extension CameraViewController: CameraResultViewControllerDelegate {
    
    func cameraResultViewController(
        didDone cameraResultViewController: CameraResultViewController
    ) {
        let vc = cameraResultViewController
        didFinish(withResult: vc.result)
//        switch vc.type {
//        case .photo:
//            if let image = vc.image {
//                didFinish(withImage: image)
//            }
//        case .video:
//            if let videoURL = vc.videoURL {
//                didFinish(withVideo: videoURL)
//            }
//        }
    }
    
    func didFinish(withResult result: Any) {
        var location: CLLocation?
//        #if HXPICKER_ENABLE_CAMERA_LOCATION
        location = currentLocation
//        #endif
        delegate?.cameraViewController(
            self,
            didFinishWithResult: .any(result),
            location: location
        )
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didFinish(withImage image: UIImage) {
        var location: CLLocation?
//        #if HXPICKER_ENABLE_CAMERA_LOCATION
        location = currentLocation
//        #endif
        delegate?.cameraViewController(
            self,
            didFinishWithResult: .image(image),
            location: location
        )
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    func didFinish(withVideo videoURL: URL) {
        var location: CLLocation?
//        #if HXPICKER_ENABLE_CAMERA_LOCATION
        location = currentLocation
//        #endif
        delegate?.cameraViewController(
            self,
            didFinishWithResult: .video(videoURL),
            location: location
        )
        if autoDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
    func saveCameraImage(_ image: UIImage) {
        let previewSize = previewView.hx_size
        DispatchQueue.global().async {
            let thumbImage = image.scaleToFillSize(size: previewSize)
            PhotoManager.shared.cameraPreviewImage = thumbImage
        }
    }
    func saveCameraVideo(_ videoURL: URL) {
        PhotoTools.getVideoThumbnailImage(
            url: videoURL,
            atTime: 0.1
        ) { _, image, _ in
            if let image = image {
                PhotoManager.shared.cameraPreviewImage = image
            }
        }
    }
}
