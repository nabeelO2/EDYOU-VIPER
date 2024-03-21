//
//  LocationFeelingsAdapater.swift
//  EDYOU
//
//  Created by Masroor Elahi on 24/09/2022.
//

import Foundation
import UIKit

class LocationAndFeelingsAdapter: NSObject {
    var collectionView: UICollectionView
    var emojiAtIndex = Int()
    var tags = [String]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var parentController : NewPostController? {
        return collectionView.viewContainingController() as? NewPostController
    }
    init(collection: UICollectionView,emojiAtIndex: Int = -1) {
        self.collectionView = collection
        self.emojiAtIndex = emojiAtIndex
        super.init()
        self.registerCollectionCell()
        self.layoutCollection()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
        
    func registerCollectionCell() {
        collectionView.register(PostTagsCell.nib, forCellWithReuseIdentifier: PostTagsCell.identifier)
    }
    
    func layoutCollection() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView.collectionViewLayout = layout
    }
}

extension LocationAndFeelingsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemName = UILabel(frame: CGRect.zero)
        itemName.text = tags[indexPath.row]
        itemName.sizeToFit()
        var width: CGFloat = itemName.frame.width + 1
        if (width > 200) {
            width = width * 0.55
        } else {
            width += 15
        }
        return CGSize(width: width, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostTagsCell.identifier, for: indexPath) as! PostTagsCell
        cell.deleteTagButton.tag = indexPath.row
        cell.deleteTagButton.addTarget(self, action: #selector(didTapRemoveButton(_ :)), for: .touchUpInside)
        if (emojiAtIndex > -1 && indexPath.row == emojiAtIndex) {
            cell.designCell(forEmoji: true, tagText: tags[indexPath.row])
        } else {
            cell.designCell(tagText: tags[indexPath.row])
        }
        return cell
    }
}

extension LocationAndFeelingsAdapter {
    @objc func didTapRemoveButton(_ sender: UIButton) {
        if sender.tag < tags.count {
            if (self.emojiAtIndex == sender.tag) {
                self.emojiAtIndex = -1
            }
            tags.remove(at: sender.tag)
            collectionView.reloadData()
            if tags.count == 0 {
                collectionView.isHidden = true
            }
            if self.tags.count == 0{
                
                parentController?.constFeelingHeightContraint.constant = 0
            }
        }
    }
}
