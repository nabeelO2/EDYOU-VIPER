//
//  PostSettingsDescriptionCell.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class PostSettingsDescriptionCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
