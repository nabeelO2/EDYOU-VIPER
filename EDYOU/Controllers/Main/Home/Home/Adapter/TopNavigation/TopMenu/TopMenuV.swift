//
//  TopMenuV.swift
//  EDYOU
//
//  Created by imac3 on 22/01/2024.
//

import UIKit

class TopMenuV: UIView {

    @IBOutlet var tabImages: [UIImageView]!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet var tabSeperators: [UIView]!
    @IBOutlet weak var scrollViewTabs: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabsStack: UIStackView!
    
    
    var didTap : ((Int)->Void)!
    
    class func instanceFromNib() -> TopMenuV {
        return UINib(nibName: "TopMenuV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TopMenuV
       
    }

    @IBAction func didTapTabButton(_ sender: UIButton) {
        
        didTap(sender.tag)

        
        tabLabels.forEach { $0.textColor = R.color.sub_title() }
        tabImages.forEach { $0.isHidden = true }
        tabSeperators.forEach{ $0.isHidden = true }
        tabLabels.first { $0.tag == sender.tag }?.textColor = R.color.buttons_green()
        tabImages.first { $0.tag == sender.tag }?.isHidden = false
        let sepView = tabSeperators.first { $0.tag == sender.tag }
        sepView?.isHidden = false
       
    }
}
