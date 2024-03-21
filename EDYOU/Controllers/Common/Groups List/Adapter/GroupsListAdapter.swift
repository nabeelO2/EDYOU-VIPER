//
//  
//  UsersListAdapter.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//
//

import UIKit

class GroupsListAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: GroupsListController? {
        return collectionView.viewContainingController() as? GroupsListController
    }
    var isLoading = true
    var groups = [Group]()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(GroupCell.nib, forCellWithReuseIdentifier: GroupCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}

// MARK: - CollectionView DataSource and Delegates
extension GroupsListAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.restore()
        if groups.count == 0 {
            collectionView.addEmptyView("No Groups", "You have no Groups in list", EmptyCellConfirguration.group.image)
        }
        collectionView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : groups.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 84)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCell.identifier, for: indexPath) as! GroupCell
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.viewAcceptReject.isHidden = true
            cell.btnAccept.isHidden = true
            cell.btnReject.isHidden = true
            cell.activityIndicator.isHidden = true
            cell.setData(groups[indexPath.row])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let g = groups.object(at: indexPath.row), isLoading == false {
            let controller = GroupDetailsController(group: g)
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}


