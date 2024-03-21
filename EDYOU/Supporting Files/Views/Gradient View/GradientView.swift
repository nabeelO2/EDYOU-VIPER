//
//  GradientView.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit

public class GradientView: UIView {
    
    var startPoint = CGPoint(x: 1, y: 0) { didSet { updatePoints() }}
    var endPoint = CGPoint(x: 0, y: 1) { didSet { updatePoints() }}
    var colors = [UIColor.black, UIColor.white] { didSet { updateColors() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint   = endPoint
    }
    func updateColors() {
        gradientLayer.colors = colors.map({ $0.cgColor })
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateColors()
    }

}
