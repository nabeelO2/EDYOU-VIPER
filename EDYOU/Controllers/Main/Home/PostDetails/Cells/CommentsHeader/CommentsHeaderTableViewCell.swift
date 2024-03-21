//
//  CommentsHeaderTableViewCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 26/07/2022.
//

import UIKit

class CommentsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var topView : UIView!
    @IBOutlet weak var closeBtn : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
