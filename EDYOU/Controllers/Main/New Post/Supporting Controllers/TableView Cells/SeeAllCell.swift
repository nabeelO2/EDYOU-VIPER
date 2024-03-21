//
//  SeeAllCell.swift
//  EDYOU
//
//  Created by Aksa on 24/08/2022.
//

import UIKit

class SeeAllCell: UITableViewCell {
    @IBOutlet weak var deleteImageBtn: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var videoLengthLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
