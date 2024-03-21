//
//  SearchCategoryCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 27/10/2022.
//

import UIKit

class SearchCategoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with title: String)
    {
        self.titleLabel.text = title
        
        var icon = title == "Friends" ? "people" : title.lowercased()
        
        if title.lowercased() == "groups"{
            icon = "u communities"
        }
        
        self.iconImageView.image = UIImage(named: icon.lowercased() == "u events" ? "events":icon)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
