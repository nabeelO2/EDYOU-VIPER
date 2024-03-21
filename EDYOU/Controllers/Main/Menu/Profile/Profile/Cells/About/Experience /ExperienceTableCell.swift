//
//  ExperienceTableCell.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class ExperienceTableCell: AboutSectionParentCell {

    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblCompanyLocation: UILabel!
    @IBOutlet weak var lblContractType: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var lblCompanyName: UILabel!
//    @IBOutlet weak var companyImg: UIImageView!
    @IBOutlet weak var lblStartEndDate: UILabel!
    @IBOutlet weak var lblWorkDescription: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnEdit.removeTarget(nil, action: nil, for: .allEvents)
        self.btnDelete.removeTarget(nil, action: nil, for: .allEvents)
        self.btnEdit.addTarget(self, action: #selector(editButtonTapped(sender:)), for: .touchUpInside)
        self.btnDelete.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(workExperience: WorkExperience, delegate: AboutSectionCellDelegate?){
        btnEdit.isHidden = delegate == nil
        btnDelete.isHidden = delegate == nil
        lblWorkDescription.text = workExperience.jobDescription
        lblDesignation.text = workExperience.jobTitle
        lblCompanyName.text = workExperience.companyName
        lblCompanyLocation.text = workExperience.companyLocation
        lblContractType.text = JobType(rawValue: workExperience.jobContractType ?? "")?.description
        lblStartEndDate.text = workExperience.completeDate
        self.delegate = delegate
    }

}
