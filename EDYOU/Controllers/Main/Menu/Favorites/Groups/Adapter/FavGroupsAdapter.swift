//
//  
//  FavFriendsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//
//

import UIKit
import EmptyDataSet_Swift

class FavGroupsAdapter: NSObject {
    
    weak var collectionView: UICollectionView!
    var parent: FavGroupsController? {
        return collectionView.viewContainingController() as? FavGroupsController
    }
    var isLoading = true
    var searchedGroups = [Group]()
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
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = groups.filter { $0.groupName?.lowercased().contains(t) == true }
            self.searchedGroups = f
        } else {
            self.searchedGroups = groups
        }
        collectionView.reloadData()
        
    }
}

extension FavGroupsAdapter {
    
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let groupId = searchedGroups.object(at: sender.tag)?.groupID else { return }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Remove from Favourite", style: .default, handler: { (_) in
            self.unfavorite(groupId: groupId)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.parent?.present(actionSheet, animated: true, completion: nil)
    }
}


// MARK: - CollectionView DataSource and Delegates
extension FavGroupsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : searchedGroups.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 84)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCell.identifier, for: indexPath) as! GroupCell
        if isLoading {
            cell.viewMore.isHidden = true
            cell.btnMore.isHidden = true
            cell.beginSkeltonAnimation()
        } else {
            cell.viewMore.isHidden = false
            cell.btnMore.isHidden = false
            cell.viewAcceptReject.isHidden = true
            cell.setData(searchedGroups[indexPath.row])
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let g = searchedGroups.object(at: indexPath.row), isLoading == false {
            let controller = GroupDetailsController(group: g)
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

extension FavGroupsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Group(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have no favourite group", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
    }
}


extension FavGroupsAdapter {
    func unfavorite(groupId: String) {
        collectionView.isUserInteractionEnabled = false
        APIManager.social.removeFromFavorite(type: .groups, id: groupId) { [weak self] error in
            if error == nil {
                let searchedIndex = self?.searchedGroups.firstIndex(where: { $0.groupID == groupId })
                let index = self?.groups.firstIndex(where: { $0.groupID == groupId })
                if let i = searchedIndex {
                    self?.searchedGroups.remove(at: i)
                }
                if let i = index {
                    self?.groups.remove(at: i)
                }
                self?.collectionView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
            self?.collectionView.isUserInteractionEnabled = true
        }
    }
}
