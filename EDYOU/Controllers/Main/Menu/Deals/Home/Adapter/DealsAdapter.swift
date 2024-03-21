//
//  
//  DealsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 22/10/2021.
//
//

import UIKit

class DealsAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: UIViewController? {
        return collectionView.viewContainingController()
    }
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(DealItemCell.nib, forCellWithReuseIdentifier: DealItemCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension DealsAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension DealsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 30) / 2
        let h = ((120/91) * w) + 94
        return CGSize(width: w, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DealItemCell.identifier, for: indexPath) as! DealItemCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = DealItemDetailsController(ad: MarketProductAd())
        parent?.navigationController?.pushViewController(controller, animated: true)
    }
}
