//
//  UniversityCell.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit

class DataPickerCell: UITableViewCell {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCheckMark: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setData(data: DataPickerItem<Any>) {
        if let img = data.image {
            imgLogo.image = img
            imgLogo.isHidden = false
        } else if let imgURL = data.imageURL {
            imgLogo.setImage(url: imgURL, placeholder: nil)
            imgLogo.isHidden = false
        } else {
            imgLogo.isHidden = true
        }
        layoutIfNeeded()
        lblTitle.text = data.title
        imgCheckMark.image = data.isSelected ? UIImage(named: "selectedCheck") : UIImage(systemName: "")
         
    }
}
