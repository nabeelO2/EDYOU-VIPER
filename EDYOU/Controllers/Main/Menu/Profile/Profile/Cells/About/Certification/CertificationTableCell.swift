//
//  CertificationTableCell.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class CertificationTableCell: AboutSectionParentCell {
    @IBOutlet weak var lblIssueDate: UILabel!
    @IBOutlet weak var lblCertificateDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var certificateImg: UIImageView!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblIssuingOrganization: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
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
    func setData(certficate: UserCertification,delegate: AboutSectionCellDelegate?){
      //  certificateImg.setImage(url: certficate.certificationImage)
        lblTitle.text = certficate.certificationTitle
        lblIssueDate.text = certficate.issuingDate?.toDate?.toYYYYMMDD()
        lblCertificateDescription.text = certficate.credentialURL
        lblExpireDate.text = certficate.expiryDate?.toDate?.toYYYYMMDD()
        lblIssuingOrganization.text = certficate.issuingOrganization
        btnEdit.isHidden = delegate == nil
        btnDelete.isHidden = delegate == nil
        self.delegate = delegate
    }
    
}
