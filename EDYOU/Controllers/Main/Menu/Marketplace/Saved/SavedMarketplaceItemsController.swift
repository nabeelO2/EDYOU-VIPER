//
//  SavedMarketplaceItemsController.swift
//  EDYOU
//
//  Created by  Mac on 22/10/2021.
//

import UIKit

class SavedMarketplaceItemsController: BaseController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblNumberOfItems: UILabel!
    
    var adapter: SavedMarketplaceItemsAdapter!
    var selectedCategory = MarketplaceCategory.fashion
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = SavedMarketplaceItemsAdapter(collectionView: collectionView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSavedItems()
        
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstCollectionViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstCollectionViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }

}

// MARK: TextField Delegate
extension SavedMarketplaceItemsController {
    func getSavedItems() {
        APIManager.social.getSavedAds { ads, error in
            self.adapter.isLoading = false
            if error == nil {
                self.adapter.ads = ads
            } else {
                self.showErrorWith(message: error!.message)
            }
            let i = ads.count == 1 ? "item" : "items"
            self.lblNumberOfItems.text = "\(ads.count) \(i) found"
            self.lblNumberOfItems.isHidden = false
            self.collectionView.reloadData()
            
        }
    }
}

