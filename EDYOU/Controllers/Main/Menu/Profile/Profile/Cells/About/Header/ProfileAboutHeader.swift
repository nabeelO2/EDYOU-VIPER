//
//  ProfileAboutHeader.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class ProfileAboutHeader: UITableViewCell {

    @IBOutlet weak var vSeperator: UIView!
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpView(section: AboutSections, user: User){
        lblTittle.text = section.descrption
        section == .about ? (btnAdd.isHidden = true) : (btnAdd.isHidden = false)
        self.vSeperator.isHidden = section == .about
        switch section {
        case .about:
            let userAbout = user.about ?? ""
            self.btnEdit.isHidden = userAbout.isEmpty
        case .experiences:
            self.btnEdit.isHidden = user.workExperiences.count == 0
        case .education:
            self.btnEdit.isHidden = user.education.count == 0
        case .certificates:
            self.btnEdit.isHidden = user.userCertifications.count == 0
        case .skills:
            self.btnEdit.isHidden = user.skills.count == 0
        case .documents:
            self.btnEdit.isHidden = user.userDocuments.count == 0
        }
        //For other sections show add and edit options
        self.btnAdd.isHidden = false
        //for about section if text is present show edit otherwise add
        if section == .about , let userAbout = user.about {
            self.btnAdd.isHidden = !userAbout.isEmpty
        }
        if user.userID != Cache.shared.user?.userID {
            self.btnEdit.isHidden = true
            self.btnAdd.isHidden = true
        }
    }
    
    
    func setupHeader(title: String, isAbout: Bool) {
        lblTittle.text = title
        isAbout ? (btnAdd.isHidden = true) : (btnAdd.isHidden = false)
        self.vSeperator.isHidden = isAbout
    }
}
