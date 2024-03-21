//
//  
//  SelectFriendCollectionViewAdapter.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//
//

import UIKit

class SelectFriendCollectionViewAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: SelectFriendsController? {
        return collectionView.viewContainingController() as? SelectFriendsController
    }
    var friends = [User]()
    var didRemoveUser: ((_ user: User) -> Void)?
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, didRemoveUser: @escaping (_ user: User) -> Void) {
        super.init()
        
        self.collectionView = collectionView
        configure()
        self.didRemoveUser = didRemoveUser
    }
    func configure() {
        collectionView.register(UserImageCell.nib, forCellWithReuseIdentifier: UserImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension SelectFriendCollectionViewAdapter {
    @objc func didTapRemoveButton(_ sender: UIButton) {
        if let user = friends.object(at: sender.tag) {
            friends.remove(at: sender.tag)
            collectionView.reloadData()
            didRemoveUser?(user)
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension SelectFriendCollectionViewAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserImageCell.identifier, for: indexPath) as! UserImageCell
        cell.imgProfile.setImage(url: friends[indexPath.row].profileImage, placeholder: R.image.profile_image_dummy())
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
