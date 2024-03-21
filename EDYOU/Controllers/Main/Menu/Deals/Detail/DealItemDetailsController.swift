//
//  DealItemDetailsController.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//

import UIKit

class DealItemDetailsController: BaseController {
    
    
    @IBOutlet weak var viewBgNavBar: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgMore: UIImageView!
    
    
    @IBOutlet weak var clvImages: UICollectionView!
    @IBOutlet weak var clvItems: UICollectionView!
    
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblDiscountedPrice: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var viewPriceCross: UIView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblSellerName: UILabel!
    @IBOutlet weak var lblSellerDetails: UILabel!
    @IBOutlet weak var imgSellerProfile: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    
    var imagesAdapter: DealsItemsImagesAdapter!
    var itemsAdapter: DealItemDetailsAdapter!
    
    var adItem: MarketProductAd
    var relatedItems: [MarketProductAd] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesAdapter = DealsItemsImagesAdapter(collectionView: clvImages)
        itemsAdapter = DealItemDetailsAdapter(collectionView: clvItems)
        
        setData()
    }
    
    init(ad: MarketProductAd) {
        adItem = ad
        super.init(nibName: DealItemDetailsController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        adItem = MarketProductAd()
        super.init(coder: coder)
    }
    


}

extension DealItemDetailsController {
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        guard let id = adItem.id else { return }
        let isLiked = adItem.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
        
        if isLiked {
            itemsAdapter.unlike(adId: id) { [weak self] status in
                guard let self = self else { return }
                
                if status {
                    if let index = self.adItem.likes?.firstIndex(of: Cache.shared.user?.userID ?? "") {
                        self.adItem.likes?.remove(at: index)
                    }
                }
                let isLiked = self.adItem.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
                self.imgLike.image = isLiked == true ? R.image.heart_selected() : R.image.heart_unselected()
                
            }
        } else {
            itemsAdapter.like(adId: id) { [weak self] status in
                guard let self = self else { return }
                
                if status {
                    self.adItem.likes?.append(Cache.shared.user?.userID ?? "")
                }
                let isLiked = self.adItem.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
                self.imgLike.image = isLiked == true ? R.image.heart_selected() : R.image.heart_unselected()
                
            }
        }
    }
    @IBAction func didTapViewOnMapButton(_ sender: UIButton) {
        guard let lat = adItem.latitude, let lng = adItem.longitude else { return }
        Utilities.openLocationInMap(latitude: lat, longitude: lng, locationName: adItem.locationName)
    }
}


extension DealItemDetailsController {
    func setData() {
        imagesAdapter.images = adItem.assets?.images ?? []
        itemsAdapter.ads = relatedItems
        lblPrice.text = "\(adItem.currency ?? "") \(adItem.price ?? "")".trimmed
        let isLiked = adItem.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
        imgLike.image = isLiked == true ? R.image.heart_selected() : R.image.heart_unselected()
        lblProductName.text = adItem.title
        lblDescription.text = adItem.description
        lblLocation.text = adItem.locationName
        if let cat = MarketplaceCategory(rawValue: adItem.category ?? "") {
            lblCategory.text = cat.name
        } else {
            lblCategory.text = adItem.category
        }
        lblSellerName.text = adItem.user?.name?.completeName
        lblSellerDetails.text = adItem.user?.instituteName
        imgSellerProfile.setImage(url: adItem.user?.profileImage, placeholderColor: R.color.image_placeholder())
        
    }
}

extension DealItemDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
//        if scrollView.contentOffset.y > 40 {
//            let alpha = min((scrollView.contentOffset.y - 40) / 230, 1)
//            self.viewBgNavBar.alpha = alpha
//            self.imgBack.tintColor = (R.color.sub_title() ?? UIColor.gray).withAlphaComponent(alpha)
//            self.imgMore.tintColor = (R.color.sub_title() ?? UIColor.gray).withAlphaComponent(alpha)
//        } else {
//            self.viewBgNavBar.alpha = 0
//            self.imgBack.tintColor = UIColor.white
//            self.imgMore.tintColor = UIColor.white
//        }
//        
    }
}
