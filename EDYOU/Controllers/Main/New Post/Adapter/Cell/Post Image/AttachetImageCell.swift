//
//  AttachetImageCell.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit

class AttachetImageCell: UICollectionViewCell {

    @IBOutlet weak var imgAttachment: UIImageView!
    @IBOutlet weak var lblOtherAttachmentsCount: UILabel!
    @IBOutlet weak var btnShowAll: UIButton!
    @IBOutlet weak var viewContainerShowAll: UIView!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var viewContainerBtnRemove: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadData(data: PhoneMediaAssets, indexPath: IndexPath, totalCount: Int) {
        self.imgAttachment.image = data.image ?? data.thumbnailImage ?? UIImage()
        self.viewContainerShowAll.isHidden = true
        self.viewContainerBtnRemove.isHidden = false
        if (indexPath.row == 3 && totalCount > 4) {
            self.viewContainerShowAll.isHidden = false
            self.viewContainerBtnRemove.isHidden = true
            self.lblOtherAttachmentsCount.text = "+" + (totalCount - 4).description
        }
        self.btnRemove.tag = indexPath.row
        self.btnShowAll.tag = indexPath.row
    }
}
