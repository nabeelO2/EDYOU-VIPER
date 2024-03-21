//
//  LocationCell.swift
//  Carzly
//
//  Created by Zuhair Hussain on 28/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCompleteAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ data: LocationModel) {
        lblTitle.text = data.country
        lblCompleteAddress.text = data.formattAdaddress
    }
    
}
