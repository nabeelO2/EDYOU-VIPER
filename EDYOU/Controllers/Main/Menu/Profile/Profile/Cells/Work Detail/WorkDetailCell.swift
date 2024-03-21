//
//  WorkDetailCell.swift
//  EDYOU
//
//  Created by Admin on 27/05/2022.
//

import UIKit

class WorkDetailCell: UITableViewCell {

    @IBOutlet weak var imgWork: UIImageView!
    @IBOutlet weak var lblWorkLocation: UILabel!
    @IBOutlet weak var lblWorkTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(user: User){
        lblWorkTitle.text = user.education.description
        lblWorkLocation.text = user.languages[0]
    }
}
