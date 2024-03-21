//
//  MarketplaceAdapter.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//

import UIKit

class MarketplaceAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    var ads = [MarketProductAd]()
    var isLoading = true
    
    var parent: MarketplaceController? {
        return collectionView.viewContainingController() as? MarketplaceController
    }
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(MarketplaceItemCell.nib, forCellWithReuseIdentifier: MarketplaceItemCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Actions
extension MarketplaceAdapter {
    @objc func didTapLikeButton(_ sender: UIButton) {
        guard let ad = ads.object(at: sender.tag), let id = ad.id else { return }
        let isLiked = ad.likes?.contains(Cache.shared.user?.userID ?? "") ?? false
        
        if isLiked {
            unlike(adId: id) { status in
                
                if status {
                    if let index = self.ads[sender.tag].likes?.firstIndex(of: Cache.shared.user?.userID ?? "") {
                        self.ads[sender.tag].likes?.remove(at: index)
                    }
                }
                self.collectionView.reloadData()
                
            }
        } else {
            like(adId: id) { status in
                
                if status {
                    self.ads[sender.tag].likes?.append(Cache.shared.user?.userID ?? "")
                }
                self.collectionView.reloadData()
                
            }
        }
        
    }
}


// MARK: - CollectionView DataSource and Delegates
extension MarketplaceAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 20 : ads.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 30) / 2
        let h = ((120/91) * w) + 94
        return CGSize(width: w, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarketplaceItemCell.identifier, for: indexPath) as! MarketplaceItemCell
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(ad: ads[indexPath.row])
        }
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = ads.object(at: indexPath.row) {
            let controller = DealItemDetailsController(ad: item)
            controller.relatedItems = ads
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}



// MARK: - Utility Methods
extension MarketplaceAdapter {
    func like(adId: String, completion: @escaping (_ status: Bool) -> Void) {
        
        APIManager.social.likeAd(adId: adId) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
        
    }
    func unlike(adId: String, completion: @escaping (_ status: Bool) -> Void) {
        
        APIManager.social.unLikeAd(adId: adId) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
        
    }
}
