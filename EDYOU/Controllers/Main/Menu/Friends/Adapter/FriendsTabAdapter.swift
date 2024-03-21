//
//  FriendsFilterAdapter.swift
//  EDYOU
//
//  Created by admin on 16/09/2022.
//

import Foundation
import UIKit

class FriendsTabAdapter: NSObject {
    
    weak var collectionView: UICollectionView!
    
    var filters = ["Requests", "My Friends", "Suggestions"]
    var parent: FriendsController? {
        return collectionView.viewContainingController() as? FriendsController
    }
    var isLoading = true
    
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        configure()
        
    }

    func configure() {
        collectionView.register(EventsSubNavBarCellItem.nib, forCellWithReuseIdentifier: EventsSubNavBarCellItem.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}
// MARK: - CollectionView DataSource and Delegates
extension FriendsTabAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //collectionView.isUserInteractionEnabled = !isLoading
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemName = UILabel(frame: CGRect.zero)
        itemName.text = filters[indexPath.row]
        itemName.sizeToFit()
        var width: CGFloat = 0
        width = itemName.frame.width + 20
        
        return CGSize(width: width, height: 35)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsSubNavBarCellItem.identifier, for: indexPath) as! EventsSubNavBarCellItem
        let row = indexPath.row
        cell.containerView.backgroundColor = UIColor(hexString: "F3F5F8")
            cell.design(showWithIcons: false, text: self.filters[row])
        
            if (parent?.selectedTab == .requests && row == 0) {
                cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
            } else if (parent?.selectedTab == .friends && row == 1) {
                cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
            } else if (parent?.selectedTab == .suggestions && row == 2) {
                cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        parent?.selectTab(index: row, animated: true)
        if (row == 0) {
            parent?.selectedTab = .requests
        } else if row == 1 {
            parent?.selectedTab = .friends
        } else {
            parent?.selectedTab = .suggestions
        }
        self.collectionView.reloadData()

    }
    
}
