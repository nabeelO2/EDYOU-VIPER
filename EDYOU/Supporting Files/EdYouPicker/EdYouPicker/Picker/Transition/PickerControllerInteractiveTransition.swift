//
//  PickerControllerInteractiveTransition.swift
//  EdYouPicker
//
//  Created by imac3 on 2022/5/23.
//

import UIKit

class PickerControllerInteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    enum TransitionType {
        case pop
        case dismiss
    }
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(panGestureRecognizerAction(panGR:))
        )
        return panGestureRecognizer
    }()
    weak var bgView: UIView?
    var pickerControllerBackgroundColor: UIColor?
    var beganPoint: CGPoint = .zero
    var canInteration: Bool = false
    let triggerRange: CGFloat
    weak var transitionContext: UIViewControllerContextTransitioning?
    weak var pickerController: PhotoPickerController?
    let type: TransitionType
    init(
        panGestureRecognizerFor pickerController: PhotoPickerController,
        type: TransitionType,
        triggerRange: CGFloat
    ) {
        self.pickerController = pickerController
        self.type = type
        self.triggerRange = triggerRange
        super.init()
        panGestureRecognizer.delegate = self
        pickerController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let pickerController = transitionContext.viewController(forKey: .from) as! PhotoPickerController
        let toVC = transitionContext.viewController(forKey: .to)!
        pickerControllerBackgroundColor = pickerController.view.backgroundColor
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let bgView = UIView(frame: containerView.bounds)
        bgView.backgroundColor = .black.withAlphaComponent(0.1)
        containerView.addSubview(bgView)
        self.bgView = bgView
        containerView.addSubview(pickerController.view)
        if type == .pop {
            toVC.view.hx_x = -(toVC.view.hx_width * 0.3)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pickerController = pickerController,
              let topViewController = pickerController.topViewController,
              topViewController is PhotoPickerViewController else {
            return false
        }
        let point = gestureRecognizer.location(in: pickerController.view)
        if point.x > triggerRange {
            return false
        }
        return true
    }
    
    @objc
    func panGestureRecognizerAction(panGR: UIPanGestureRecognizer) {
        guard let pickerController = pickerController else {
            return
        }
        
        switch panGR.state {
        case .began:
            if canInteration {
                return
            }
            beganPoint = pickerController.view.frame.origin
            canInteration = true
            pickerController.dismiss(animated: true)
        case .changed:
            if !canInteration {
                return
            }
            let point = panGR.translation(in: pickerController.view)
            var scale = (point.x / pickerController.view.hx_width)
            if scale < 0 {
                scale = 0
            }
            if type == .pop {
                if let transitionContext = transitionContext,
                   let toVC = transitionContext.viewController(forKey: .to) {
                    let toScale = toVC.view.hx_width * 0.3 * scale
                    toVC.view.hx_x = -(toVC.view.hx_width * 0.3) + toScale
                }
                pickerController.view.hx_x = pickerController.view.hx_width * scale
            }else {
                pickerController.view.hx_y = beganPoint.y + scale * pickerController.view.hx_height
                if pickerController.view.hx_y < 0 {
                    pickerController.view.hx_y = 0
                }
            }
            bgView?.alpha = 1 - scale
            update(scale)
        case .ended, .cancelled, .failed:
            if !canInteration {
                return
            }
            let isFinish: Bool
            let velocity = panGR.velocity(in: pickerController.view)
            if type == .pop {
                if velocity.x > pickerController.view.hx_width {
                    isFinish = true
                }else {
                    isFinish = pickerController.view.hx_x > pickerController.view.hx_width * 0.6
                }
            }else {
                isFinish = pickerController.view.hx_y > pickerController.view.hx_height * 0.4
            }
            if isFinish {
                finish()
                var duration: TimeInterval = 0.2
                if type == .pop {
                    if velocity.x > pickerController.view.hx_width {
                        duration *= pickerController.view.hx_width / velocity.x
                    }
                }
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: .curveEaseIn
                ) {
                    if self.type == .pop {
                        if let transitionContext = self.transitionContext,
                           let toVC = transitionContext.viewController(forKey: .to) {
                            toVC.view.hx_x = 0
                        }
                        pickerController.view.hx_x = pickerController.view.hx_width
                    }else {
                        pickerController.view.hx_y = pickerController.view.hx_height
                    }
                    self.bgView?.alpha = 0
                } completion: { _ in
                    self.pickerController?.view.removeFromSuperview()
                    self.pickerController = nil
                    self.bgView?.removeFromSuperview()
                    self.bgView = nil
                    self.canInteration = false
                    self.transitionContext?.completeTransition(true)
                    self.transitionContext = nil
                }
            }else {
                cancel()
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseOut
                ) {
                    if self.type == .pop {
                        if let transitionContext = self.transitionContext,
                           let toVC = transitionContext.viewController(forKey: .to) {
                            toVC.view.hx_x = -(toVC.view.hx_width * 0.3)
                        }
                        pickerController.view.hx_x = 0
                    }else {
                        pickerController.view.hx_y = 0
                    }
                    self.bgView?.alpha = 1
                } completion: { _ in
                    self.bgView?.removeFromSuperview()
                    self.bgView = nil
                    self.canInteration = false
                    self.transitionContext?.completeTransition(false)
                    self.transitionContext = nil
                }
            }
        default:
            break
        }
    }
}
