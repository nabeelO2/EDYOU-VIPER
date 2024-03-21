//
//  PickerControllerTransition.swift
//  EdYouPicker
//
//  Created by imac3 on 2022/5/23.
//

import UIKit

class PickerControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public enum TransitionType {
        case push
        case pop
        case dismiss
    }
    let type: TransitionType
    
    init(type: TransitionType) {
        self.type = type
        super.init()
    }
    
    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        if type == .push {
            return 0.3
        }else if type == .dismiss {
            return 0.2
        }
        return 0.25
    }
    
    public func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        let containerView = transitionContext.containerView
        let bgView = UIView(frame: containerView.bounds)
        bgView.backgroundColor = .black.withAlphaComponent(0.1)
        if type == .push {
            bgView.alpha = 0
            containerView.addSubview(fromVC.view)
            containerView.addSubview(bgView)
            containerView.addSubview(toVC.view)
        }else {
            containerView.addSubview(toVC.view)
            containerView.addSubview(bgView)
            containerView.addSubview(fromVC.view)
        }
        let duration = transitionDuration(using: transitionContext)
        let options: UIView.AnimationOptions
        switch self.type {
        case .push:
            toVC.view.hx_x = toVC.view.hx_width
            options = .curveEaseOut
        case .pop:
            toVC.view.hx_x = -(toVC.view.hx_width * 0.3)
            options = .curveLinear
        default:
            options = .curveLinear
            break
        }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options
        ) {
            switch self.type {
            case .push:
                fromVC.view.hx_x = -(fromVC.view.hx_width * 0.3)
                toVC.view.hx_x = 0
                bgView.alpha = 1
            case .pop:
                fromVC.view.hx_x = fromVC.view.hx_width
                toVC.view.hx_x = 0
                bgView.alpha = 0
            case .dismiss:
                fromVC.view.hx_y = fromVC.view.hx_height
                bgView.alpha = 0
            }
        } completion: { _ in
            bgView.removeFromSuperview()
            switch self.type {
            case .pop, .dismiss:
                fromVC.view.removeFromSuperview()
            default:
                break
            }
            transitionContext.completeTransition(true)
        }
    }
}
