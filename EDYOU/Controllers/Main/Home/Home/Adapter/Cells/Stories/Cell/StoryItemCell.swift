//
//  StoryItemCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit

class StoryItemCell: UICollectionViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var vGradientContainer: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgProfile.round()
        imgProfile.borderWidth = 2.0
        imgProfile.borderColor = R.color.background()
        self.vGradientContainer.round()
        let gradient = GradientShades.getRandom()
        self.vGradientContainer.colors = [ gradient.start, gradient.end]
    }

}
