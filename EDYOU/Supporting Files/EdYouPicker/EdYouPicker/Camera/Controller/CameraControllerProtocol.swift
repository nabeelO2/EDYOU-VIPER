//
//  CameraControllerProtocol.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/31.
//

import UIKit
import CoreLocation
import AVFoundation

public protocol CameraControllerDelegate: AnyObject {
    
    /// capture completed
    /// - Parameters:
    ///   - cameraController: Camera CameraController
    ///   - result: result
    ///   - locatoin: location
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithResult result: CameraController.Result,
        location: CLLocation?
    )
    
    /// cancel capture
    /// - Parameter cameraController: corresponding CameraController
    func cameraController(didCancel cameraController: CameraController)
    
    /// flash mode has changed
    func cameraController(
        _ cameraController: CameraController,
        flashModeDidChanged flashMode: AVCaptureDevice.FlashMode
    )
    
    /// switch between front and rear cameras
    func cameraController(
        _ cameraController: CameraController,
        didSwitchCameraCompletion position: AVCaptureDevice.Position
    )
    
    /// takePhotoMode = .click the photography mode has changed
    func cameraController(
        _ cameraController: CameraController,
        didChangeTakeType takeType: CameraBottomViewTakeType
    )
    
    
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithSelectedView result: [UIView]
    )
    
}

public extension CameraControllerDelegate {
    
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithResult result: CameraController.Result,
        location: CLLocation?
    ) {
        if !cameraController.autoDismiss {
            cameraController.dismiss(animated: true)
        }
    }
    func cameraController(didCancel cameraController: CameraController) {
        if !cameraController.autoDismiss {
            cameraController.dismiss(animated: true)
        }
    }
    func cameraController(
        _ cameraController: CameraController,
        flashModeDidChanged flashMode: AVCaptureDevice.FlashMode
    ) { }
    func cameraController(
        _ cameraController: CameraController,
        didSwitchCameraCompletion position: AVCaptureDevice.Position
    ) { }
    func cameraController(
        _ cameraController: CameraController,
        didChangeTakeType takeType: CameraBottomViewTakeType
    ) { }
}

public protocol CameraViewControllerDelegate: AnyObject {
    
    /// capture completed
    /// - Parameters:
    ///   - cameraViewController: Camera CameraViewController
    ///   - result: Result
    ///   - locatoin: Location
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithResult result: CameraController.Result,
        location: CLLocation?
    )
    
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithViews result: [UIView]
    )
    
    /// cancel capture
    /// - Parameter cameraViewController: corresponding CameraViewController
    func cameraViewController(didCancel cameraViewController: CameraViewController)
    
    /// the flash mode has changed
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        flashModeDidChanged flashMode: AVCaptureDevice.FlashMode
    )
    
    /// 切换前后摄像头
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didSwitchCameraCompletion position: AVCaptureDevice.Position
    )
    
    /// takePhotoMode = .click 拍照类型发生改变
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didChangeTakeType takeType: CameraBottomViewTakeType
    )
}

public extension CameraViewControllerDelegate {
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithResult result: CameraController.Result,
        location: CLLocation?
    ) {
        if !cameraViewController.autoDismiss {
            cameraViewController.dismiss(animated: true)
        }
    }
    func cameraViewController(didCancel cameraViewController: CameraViewController) {
        if !cameraViewController.autoDismiss {
            cameraViewController.dismiss(animated: true)
        }
    }
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        flashModeDidChanged flashMode: AVCaptureDevice.FlashMode
    ) { }
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didSwitchCameraCompletion position: AVCaptureDevice.Position
    ) { }
    func cameraViewController(
        _ cameraViewController: CameraViewController,
        didChangeTakeType takeType: CameraBottomViewTakeType
    ) { }
}

protocol CameraResultViewControllerDelegate: AnyObject {
    func cameraResultViewController(didDone cameraResultViewController: CameraResultViewController)
}
