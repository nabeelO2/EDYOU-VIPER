//
//  CreatePostCell.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

class CreatePostCell: UITableViewCell {

    
    @IBOutlet weak var btnAddStory: UIButton!
    @IBOutlet weak var stNoPhotos: UIStackView!
    @IBOutlet weak var viewMediaCollection: UIView!
    @IBOutlet weak var lblPhotosCount: UILabel!
    @IBOutlet weak var viewCreatePost: UIView!
    @IBOutlet weak var viewPosts: UIView!
    @IBOutlet weak var btnMyPosts: UIButton!
    @IBOutlet weak var btnGroupPosts: UIButton!
    @IBOutlet weak var btnCreatePost: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnImages: UIButton!
    @IBOutlet weak var btnPhotosCount: UIButton!
        
    var parent: UIViewController? {
        return self.viewContainingController()
    }
    
    var media = [String]()
    var isLoading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func configure() {
        collectionView.register(ImageCell.nib, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    func setData(media: [String], isLoading: Bool) {
        let f = media.count == 1 ? "Photo" : "Photos"
        lblPhotosCount.text = isLoading ? "0 Photos" : "\(media.count) \(f)"
        self.media = media
        self.isLoading = isLoading
        collectionView.reloadData()
    }
}

// MARK: - CollectionView DataSource and Delegates
extension CreatePostCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 42 : media.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.imageView.cornerRadius = 4
        if isLoading {
            cell.imageView.startSkelting()
        } else {
            cell.imageView.stopSkelting()
            cell.imageView.setImage(url: media[indexPath.row], placeholderColor: R.color.image_placeholder())
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let  m = media.map { ChatMedia(url: $0, type: .image, fileName: "") }
        let controller = MediaViewerController(media: m, selectedIndex: indexPath.row)
        self.parent?.present(controller, animated: false, completion: nil)
        
    }
}
