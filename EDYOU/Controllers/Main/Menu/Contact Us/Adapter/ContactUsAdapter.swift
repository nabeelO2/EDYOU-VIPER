//
//  
//  ContactUsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//
//

import UIKit

class ContactUsAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: UIViewController? {
        return collectionView.viewContainingController()
    }
    
    var images = [UIImage]()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(AttachetImageCell.nib, forCellWithReuseIdentifier: AttachetImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Actions
extension ContactUsAdapter {
    @objc func didTapRemoveButton(_ sender: UIButton) {
        if sender.tag < images.count {
            images.remove(at: sender.tag)
            collectionView.reloadData()
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension ContactUsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachetImageCell.identifier, for: indexPath) as! AttachetImageCell
        if indexPath.row < images.count {
            cell.imgAttachment.image = images[indexPath.row]
            cell.imgAttachment.cornerRadius = 12
            cell.viewContainerBtnRemove.isHidden = false
        } else {
            cell.imgAttachment.image = R.image.add_attachment_icon()
            cell.imgAttachment.cornerRadius = 0
            cell.viewContainerBtnRemove.isHidden = true
        }
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let p = parent, indexPath.row >= images.count {
            
            ImagePicker.shared.openGalleryWithType(from: p, mediaType: Constants.imageMediaType) {[weak self] imageData in
                guard let self = self , let image = imageData.image else { return }
                self.images.append(image)
                collectionView.reloadData()
                let indexPath = IndexPath(row: self.images.count, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }
}
