//
//  CallPopup.swift
//  EDYOU
//
//  Created by Ali Pasha on 22/08/2022.
//

import UIKit
import AVFoundation

class CallPopup: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var callerImageView: UIImageView!
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var callTypeLabel: UILabel!
    @IBOutlet weak var rejectCallButton: UIButton!
    @IBOutlet weak var accpetCallButton: UIButton!
  
    
   
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
