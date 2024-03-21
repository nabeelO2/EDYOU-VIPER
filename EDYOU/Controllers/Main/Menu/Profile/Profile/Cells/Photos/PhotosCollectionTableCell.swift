//
//  PhotosCollectionTableCell.swift
//  EDYOU
//
//  Created by Admin on 20/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class PhotosCollectionTableCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var adapter: PhotoCollectionAdapter!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(photos: [MediaAsset], videos: [MediaAsset],isLoading:Bool){
        adapter = PhotoCollectionAdapter(collectionView: collectionView, photos: photos, videos: videos, isLoading: isLoading)
    }
}
