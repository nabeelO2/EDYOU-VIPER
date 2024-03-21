//
//  FilterReusableShowResultsTableViewCell.swift
//  EDYOU
//
//  Created by admin on 31/08/2022.
//

import UIKit


class FilterReusableShowResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var showResultsBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    @IBAction func showResultTapped(_ sender: Any) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
