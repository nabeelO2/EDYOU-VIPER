//
//  PhotosSegmentTableCell.swift
//  EDYOU
//
//  Created by Admin on 20/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

protocol PhotoHeaderActions : AnyObject {
    func photoSegmentChanged(type: ProfilePhotosType)
}

class PhotosSegmentTableCell: UITableViewCell {
    
    @IBOutlet weak var tabsStack: UIStackView!
    @IBOutlet weak var cstViewIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet var tablabels: [UILabel]!
    weak var delegate: PhotoHeaderActions?
    var type : ProfilePhotosType = .all
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func DidTapSegmentButtons(_ sender: UIButton) {
        tablabels.forEach { $0.textColor = R.color.sub_title() }
        let labels = tablabels.first { $0.tag == sender.tag }
        labels?.textColor = R.color.buttons_green()
        for views in tabsStack.arrangedSubviews {
            if views.tag == sender.tag {
                cstViewIndicatorLeading.constant = views.frame.origin.x + 15
                cstViewIndicatorWidth.constant = views.frame.size.width
            }
        }
        type = ProfilePhotosType(rawValue: sender.tag) ?? .all
        self.delegate?.photoSegmentChanged(type: type)
    }
}
