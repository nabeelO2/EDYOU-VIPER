//
//  FriendsListCell.swift
//  EDYOU
//
//  Created by Mudassir Asghar on 03/01/2022.
//

import UIKit

class FriendsListCell: UITableViewCell {

    @IBOutlet weak var stNoFriendsYet: UIStackView!
    @IBOutlet weak var lblFriendsCount: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnFriendsCount: UIButton!
    
    var friends = [User]()
    var isLoading = true
    var parent: UIViewController? {
        return self.viewContainingController()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        
    }
    func configure() {
        collectionView.register(FriendCell.nib, forCellWithReuseIdentifier: FriendCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setData(friends: [User], isLoading: Bool) {
        let f = friends.count == 1 ? "Friend" : "Friends"
        lblFriendsCount.text = isLoading ? "0 Friends" : "\(friends.count) \(f)"
        self.friends = friends
        self.isLoading = isLoading
        collectionView.reloadData()
    }

}


// MARK: - CollectionView DataSource and Delegates
extension FriendsListCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 42 : friends.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 62, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendCell.identifier, for: indexPath) as! FriendCell

        if isLoading {
            cell.imageView.startSkelting()
            cell.lblName.startSkelting()
        } else {
            cell.imageView.stopSkelting()
            cell.lblName.stopSkelting()
            cell.imageView.setImage(url: friends[indexPath.row].profileImage, placeholderColor: R.color.image_placeholder())
            cell.lblName.text = friends[indexPath.row].name?.firstName?.trimmed
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let user = friends.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
        }
    }
}
