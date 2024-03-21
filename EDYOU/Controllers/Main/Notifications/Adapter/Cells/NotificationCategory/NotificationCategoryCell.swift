//
//  NotificationCategoryCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/11/2022.
//

import UIKit

class NotificationCategoryCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vSelector: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(category: PropertyDescriptionProtocol, selected:Bool) {
        self.lblTitle.text = category.propertyDescription
        self.lblTitle.textColor = selected ? R.color.buttons_green()!: R.color.sub_title()!
        self.vSelector.isHidden = !selected
    }
}
