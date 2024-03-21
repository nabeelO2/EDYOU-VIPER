//
//  ReelCategoryTableViewCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/08/2022.
//

import UIKit

class ReelCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: ReelsCategories) {
        self.lblTitle.text = data.description
    }
}
