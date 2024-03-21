//
//  TopHeaderV.swift
//  EDYOU
//
//  Created by imac3 on 22/01/2024.
//

import UIKit

class TopHeaderV: UIView {

    var didTapNotification : (()->Void)!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var viewBadgeNotifications: UIView!
    @IBOutlet weak var lblBadgeNotifications: UILabel!
    
    
    class func instanceFromNib() -> TopHeaderV {
        return UINib(nibName: "TopHeaderV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopHeaderV
       
    }

    @IBAction func didTapNotification(_ sender: Any) {
        didTapNotification()
        
    }
}
