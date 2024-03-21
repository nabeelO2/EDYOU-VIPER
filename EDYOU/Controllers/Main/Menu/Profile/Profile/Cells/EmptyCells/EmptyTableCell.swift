//
//  EmptyEventTableCell.swift
//  EDYOU
//
//  Created by Admin on 21/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class EmptyTableCell: UITableViewCell {

    @IBOutlet weak var imgEmpty: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setConfiguration(configuration: EmptyCellConfirguration) {
        self.imgEmpty.image = configuration.image
        self.lblTitle.text = configuration.title
        self.lblDescription.text = configuration.shortDescription
    }
}
