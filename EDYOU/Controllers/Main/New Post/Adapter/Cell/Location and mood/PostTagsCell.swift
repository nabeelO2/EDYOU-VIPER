//
//  PostTagsCell.swift
//  EDYOU
//
//  Created by Aksa on 24/08/2022.
//

import UIKit

class PostTagsCell: UICollectionViewCell {
    @IBOutlet weak var deleteTagButton: UIButton!
    @IBOutlet weak var customTagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func designCell(forEmoji emoji: Bool = false, tagText: String) {
        if (emoji) {
            customTagImageView.isHidden = true
        } else {
            customTagImageView.isHidden = false
        }
        
        tagLabel.text = tagText
    }
}
