//
//  EducationTableCell.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class EducationTableCell: AboutSectionParentCell {
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
//    @IBOutlet weak var imgInstitute: UIImageView!
    @IBOutlet weak var lblDegree: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
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
    
    func setData(education: Education, delegate: AboutSectionCellDelegate?){
        lblDuration.text = education.completeDate
        lblInstituteName.text = education.instituteName
        lblDegree.text = education.completeName
        btnEdit.isHidden = delegate == nil
        btnDelete.isHidden = delegate == nil
        self.lblLocation.text = education.instituteLocation
        self.delegate = delegate
    }
    
}
