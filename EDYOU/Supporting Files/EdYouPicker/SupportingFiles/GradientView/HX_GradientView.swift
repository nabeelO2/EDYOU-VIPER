//
//  HX_Gradient.swift
//  ustories
//
//  Created by imac3 on 27/06/2023.
//

import Foundation
import UIKit

public class HX_GradientView: UIView {
    
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
