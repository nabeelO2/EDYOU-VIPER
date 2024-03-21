//
//  EditProfileCoverPhotoCell.swift
//  EDYOU
//
//  Created by Admin on 13/06/2022.
//

import UIKit
import SDWebImage

class EditProfileCoverPhotoCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgCover: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCoverImage(coverImage: CoverPhoto) {
        if let localImage = coverImage.localImage {
            self.imgCover.image = UIImage(data: localImage)
        } else {
            imgCover.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgCover.sd_setImage(with: coverImage.coverImageURL)
        }
    }
    
    
}
