//
//  ExperienceDetailCell.swift
//  EDYOU
//
//  Created by Admin on 13/06/2022.
//

import UIKit

class ExperienceDetailCell: UICollectionViewCell {
    @IBOutlet weak var imgWork: UIImageView!
    @IBOutlet weak var lblWorkLocation: UILabel!
    @IBOutlet weak var lblWorkTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(work: WorkExperience){
        lblWorkTitle.text = work.jobTitle
        lblWorkLocation.text = work.companyName
    }
}
