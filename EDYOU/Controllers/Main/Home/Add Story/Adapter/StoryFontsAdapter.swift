//
//  
//  StoryFontsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//
//

import UIKit

class StoryFontsAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
//    var parent: UIViewController {
//        return collectionView.viewContainingController()
//    }
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(StoryFontCell.nib, forCellWithReuseIdentifier: StoryFontCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension StoryFontsAdapter {
}


// MARK: - CollectionView DataSource and Delegates
extension StoryFontsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryFontCell.identifier, for: indexPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
