//
//  ChatReactionEmojiCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 11/08/2022.
//

import UIKit

class ChatReactionEmojiCell: UICollectionViewCell {
  
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    
    func setupUI(emoji: String?, totalCount: Int?, isSelected: Bool)
    {
        if isSelected
        {
            bottomView.isHidden = false
        }
        else
        {
            bottomView.isHidden = true
        }
        emojiLabel.text =  emoji
        countLabel.text = String(format: "%d", totalCount!)
    }
}
