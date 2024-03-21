//
//  EventsSubNavBarCellItem.swift
//  EDYOU
//
//  Created by Aksa on 07/08/2022.
//

import UIKit

class EventsSubNavBarCellItem: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leadingIcon: UIImageView!
    @IBOutlet weak var dropDownIcon: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    internal func design(showWithIcons showIcons: Bool, text: String) {
        self.itemTitle.text = text
        
        if (showIcons) {
            leadingIcon.isHidden = false
            dropDownIcon.isHidden = false
        } else {
            leadingIcon.isHidden = true
            dropDownIcon.isHidden = true
        }
    }
}
