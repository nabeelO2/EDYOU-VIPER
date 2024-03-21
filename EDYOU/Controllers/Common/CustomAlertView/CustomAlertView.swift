//
//  CustomAlertViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 22/10/2022.
//

import Foundation
import UIKit
class CustomAlertView: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        
        // for using CustomView in code
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        commonInit()
    }
    
    required init? (coder aDecoder: NSCoder)
    {// for using CustomView in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
     
    }
}
