//
//  MarketplaceItemCell.swift
//  EDYOU
//
//  Created by  Mac on 22/10/2021.
//

import UIKit

class MarketplaceItemCell: UICollectionViewCell {

    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblProductDetails: UILabel!
    @IBOutlet weak var imgIconLocation: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(ad: MarketProductAd) {
        endSkeltonAnimation()
        
        imgProduct.setImage(url: ad.assets?.images?.first, placeholderColor: R.color.image_placeholder())
        lblPrice.text = "\(ad.currency ?? "") \(ad.price ?? "")".trimmed
        let isLiked = ad.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
        imgLike.image = isLiked == true ? R.image.heart_selected() : R.image.heart_unselected()
        lblProductDetails.text = ad.title
        lblLocation.text = ad.locationName
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        imgLike.isHidden = true
        let views: [UIView] = [imgProduct, lblPrice, lblProductDetails, lblLocation, imgIconLocation]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        imgLike.isHidden = false
        let views: [UIView] = [imgProduct, lblPrice, lblProductDetails, lblLocation, imgIconLocation]
        views.forEach { $0.stopSkelting() }
    }
    
    
}
