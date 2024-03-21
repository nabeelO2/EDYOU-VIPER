//
//  MenuCell.swift
//  EDYOU
//
//  Created by  Mac on 08/09/2021.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var imgRightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
