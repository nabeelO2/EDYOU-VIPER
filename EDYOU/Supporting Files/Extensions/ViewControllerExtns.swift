//
//  ViewControllerExtns.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit
import AVKit
import AVFoundation

extension UIViewController {
    var isBeingClosed: Bool {
        return self.isBeingDismissed || self.isMovingFromParent || self.navigationController?.isBeingDismissed ?? false
    }
    func startLoading(title: String) {
        
        let controller = LoadingController(title: title)
        self.present(controller, animated: true, completion: nil)
        
    }
    func stopLoading() {
        if let controller =  self.presentedViewController as? LoadingController {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func present(_ viewController: UIViewController, presentationStyle: UIModalPresentationStyle) {
        viewController.modalPresentationStyle = presentationStyle
        self.present(viewController, animated: true)
    }
    
    @IBAction func goBack() {
        if (self.navigationController?.viewControllers.count ?? 0) > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func addBlurView(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat, style: UIBlurEffect.Style = .extraLight) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.6
        let h = view.bounds.height - top - bottom
        let w = view.bounds.width - left - right
        blurEffectView.frame = CGRect(x: left, y: top, width: w, height: h)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        
        
        NSLayoutConstraint(item: blurEffectView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: left).isActive = true
        NSLayoutConstraint(item: blurEffectView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: right).isActive = true
        NSLayoutConstraint(item: blurEffectView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: top).isActive = true
        NSLayoutConstraint(item: blurEffectView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottom).isActive = true

    }
    func removeBlurView() {
        for v in self.view.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
    }
    var embedInNavigationController: UINavigationController {
        let nav = UINavigationController(rootViewController: self)
        nav.isNavigationBarHidden = true
        return nav
    }
    

    func playVideo(url urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
//    func getVideoDuration(url: URL) -> Int {
//        let asset = AVURLAsset(url: url)
//        let durationInSeconds = asset.duration.seconds
//        return Int(durationInSeconds)
//    }
    
    func presentInKeyWindow(animated: Bool = true, completion: (() -> Void)? = nil) {
          DispatchQueue.main.async {
              UIApplication.shared.keyWindow?.rootViewController?
                  .present(self, animated: animated, completion: completion)
          }
      }
      
      func presentInKeyWindowPresentedController(animated: Bool = true, completion: (() -> Void)? = nil) {
          DispatchQueue.main.async {
              UIApplication.shared.keyWindowPresentedController?
                  .present(self, animated: animated, completion: completion)
          }
      }
    
}

//extension UIViewController: UIGestureRecognizerDelegate {
//
////    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
////        return (navigationController?.viewControllers.count ?? 0) > 1 ? true : false
////    }
//    
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return (navigationController?.viewControllers.count ?? 0) > 1 ? true : false
//    }
//    
//}


extension UIApplication {
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        // If root `UIViewController` is a `UITabBarController`
        if let presentedController = viewController as? UITabBarController {
            // Move to selected `UIViewController`
            viewController = presentedController.selectedViewController
        }
        
        // Go deeper to find the last presented `UIViewController`
        while let presentedController = viewController?.presentedViewController {
            // If root `UIViewController` is a `UITabBarController`
            if let presentedController = presentedController as? UITabBarController {
                // Move to selected `UIViewController`
                viewController = presentedController.selectedViewController
            } else {
                // Otherwise, go deeper
                viewController = presentedController
            }
        }
        
        return viewController
    }
    
}


