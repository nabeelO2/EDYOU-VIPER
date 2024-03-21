//
//  PostFileCell.swift
//  EDYOU
//
//  Created by Aksa on 25/08/2022.
//

import UIKit

class PostFileCell: UITableViewCell {
    @IBOutlet weak var documentTypeImage: UIImageView!
    @IBOutlet weak var documentNameLbl: UILabel!
    @IBOutlet weak var documentTypeLbl: UILabel!
    @IBOutlet weak var documentSizeLbl: UILabel!
    @IBOutlet weak var deleteDocumentBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
