//
//  EmojisAdapter.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 22/03/2022.
//
//

import UIKit

class EmojisAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: EmojisController? {
        return collectionView.viewContainingController() as? EmojisController
    }
    
    var emojis = [EmojiVal]()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        emojis = Utilities.getEmojis()
        configure()
    }
    func configure() {
        collectionView.register(EmojiCell.nib, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension EmojisAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension EmojisAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.width - 20) / 6
        return CGSize(width: w, height: w)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as! EmojiCell
        cell.lblEmoji.text = emojis[indexPath.row].value
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let e = String(emojis[indexPath.row].value.unicodeScalars)
        parent?.completion?(e)
        parent?.dismiss(animated: true, completion: nil)
    }
}



