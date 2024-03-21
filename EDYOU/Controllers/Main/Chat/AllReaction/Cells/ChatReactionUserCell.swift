//
//  ChatReactionUserCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 11/08/2022.
//

import UIKit

class ChatReactionUserCell: UITableViewCell {

    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(emoji: EmojiModelProtocol)
    {
        emojiLabel.text = emoji.emoji
        nameLabel.text = emoji.userName
//        userImageView.setImage(url: emoji.userPicture, placeholderColor: R.color.image_placeholder())
        userImageView.setImage(url: emoji.userPicture, placeholder: R.image.profile_image_dummy()!)
        universityLabel.text = emoji.userUniversity
    }

}
