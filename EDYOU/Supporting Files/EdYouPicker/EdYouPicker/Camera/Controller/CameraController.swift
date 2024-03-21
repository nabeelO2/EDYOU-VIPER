//
//  CameraController.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/8/30.
//

import UIKit
import CoreLocation
import AVFoundation

open class CameraController: UINavigationController {
    
    public enum CameraType {
        case normal
    }
    
    /// camera shooting type
    public enum CaptureType {
        // take a photo
        case photo
        // record video
        case video
        // take photos and record
        case all
    }
    
    /// shooting result
    public enum Result {
        /// image
        case image(UIImage)
        /// video URL
        case video(URL)
        
        case any(Any)
    }
    
    public weak var cameraDelegate: CameraControllerDelegate?
    
    /// autodismiss
    public var autoDismiss: Bool = true {
        didSet {
            let vc = viewControllers.first as? CameraViewController
            vc?.autoDismiss = autoDismiss
        }
    }
    
    /// camera configuration
    public let config: CameraConfiguration
    
    /// camera initialization
    /// - Parameters:
    ///   - config:  configuration
    ///   - type: type
    ///   - delegate: proxy
    public init(
        config: CameraConfiguration,
        type: CaptureType,
        delegate: CameraControllerDelegate? = nil
    ) {
        self.config = config
        cameraDelegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = config.modalPresentationStyle
        let cameraVC = CameraViewController(
            config: config,
            type: type,
            delegate: self
        )
        viewControllers = [cameraVC]
    }
    
    public typealias CaptureCompletion = (Result, CLLocation?) -> Void
    
    /// jump to camera
    /// - Parameters:
    ///   - config: camera configuration
    ///   - type: type
    ///   - completion: shooting completed
    /// - Returns: return to the CameraController
    @discardableResult
    public class func capture(
        config: CameraConfiguration,
        type: CaptureType = .all,
        fromVC: UIViewController? = nil,
        completion: @escaping CaptureCompletion
    ) -> CameraController {
        let controller = CameraController(
            config: config,
            type: type
        )
        controller.completion = completion
        (fromVC ?? UIViewController.topViewController)?.present(controller, animated: true)
        return controller
    }
    
    public var completion: CaptureCompletion?
    
    open override var prefersStatusBarHidden: Bool {
        config.prefersStatusBarHidden
    }
    open override var shouldAutorotate: Bool {
        config.shouldAutorotate
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        config.supportedInterfaceOrientations
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraController: CameraViewControllerDelegate {
    
    public func cameraViewController(_ cameraViewController: CameraViewController, didFinishWithViews result: [UIView]) {
        cameraDelegate?.cameraController(self, didFinishWithSelectedView: result)
        
    }
    
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        didFinishWithResult result: CameraController.Result,
        location: CLLocation?
    ) {
        completion?(result, location)
        cameraDelegate?.cameraController(
            self,
            didFinishWithResult: result,
            location: location
        )
    }
    
    public func cameraViewController(didCancel cameraViewController: CameraViewController) {
        cameraDelegate?.cameraController(didCancel: self)
    }
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        flashModeDidChanged flashMode: AVCaptureDevice.FlashMode
    ) {
        cameraDelegate?.cameraController(self, flashModeDidChanged: flashMode)
    }
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        didSwitchCameraCompletion position: AVCaptureDevice.Position
    ) {
        cameraDelegate?.cameraController(self, didSwitchCameraCompletion: position)
    }
    public func cameraViewController(
        _ cameraViewController: CameraViewController,
        didChangeTakeType takeType: CameraBottomViewTakeType
    ) {
        cameraDelegate?.cameraController(self, didChangeTakeType: takeType)
    }
}
