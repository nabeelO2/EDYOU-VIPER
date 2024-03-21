//
//  CertificateController.swift
//  EDYOU
//
//  Created by Admin on 07/06/2022.
//

import UIKit
import TransitionButton
class CertificateController: BaseController {
    
    @IBOutlet weak var lblVCTittle: UILabel!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var txtName: BorderedTextField!
    @IBOutlet weak var txtOrganization: BorderedTextField!
    @IBOutlet weak var txtIssueDate: BorderedTextField!
    @IBOutlet weak var txtExpirationDate: BorderedTextField!
    @IBOutlet weak var txtCredentialID: BorderedTextField!
    var media = [Media]()
    var tittle:String!
    var isSelected = false
    var userCertificate:UserCertification
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIValues()
        self.setupValidation()
    }
    init(userCertificate: UserCertification) {
        self.userCertificate = userCertificate
        super.init(nibName: CertificateController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.userCertificate = UserCertification.nilCertificate
        super.init(coder: coder)
    }
    deinit {
        print("[ExperienceController] deinit")
    }
    
    func setUIValues() {
        txtName.text = userCertificate.certificationTitle
        txtOrganization.text = userCertificate.issuingOrganization
        txtIssueDate.text = userCertificate.issuingDate
        txtExpirationDate.text = userCertificate.expiryDate
        txtCredentialID.text = userCertificate.credentialURL
        self.txtIssueDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: userCertificate.issuingDate?.toDate)
        self.txtExpirationDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: userCertificate.expiryDate?.toDate)
        if !self.userCertificate.certificationTitle.isStringEmpty() {
            lblVCTittle.text = "Edit Certification"
        }
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        if validate() {
            addCertificate()
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        goBack()
    }
    @IBAction func didTapExpire(_ sender: UIButton) {
        if isSelected {
            sender.setImage(R.image.roundCheck(), for: .normal)
            isSelected = false
        }
        else{
            sender.setImage(R.image.roundUNCheck(), for: .normal)
            isSelected = true
        }
    }
}

extension CertificateController {
    func addCertificate(animateButton: Bool = true){
        self.handleViewLoading(enable: false)
        self.userCertificate.certificationTitle = txtName.text
        self.userCertificate.issuingOrganization = txtOrganization.text
        self.userCertificate.issuingDate = txtIssueDate.selectedDate?.toUTC()
        self.userCertificate.expiryDate = txtExpirationDate.selectedDate?.toUTC()
        self.userCertificate.credentialURL = txtCredentialID.text
        btnSave.startAnimation()
        APIManager.social.addUpdateUserProfile(url: Routes.certifications.url()!, paramter: self.userCertificate.dictionary, id: self.userCertificate.certificationID) { user, error in
            self.btnSave.stopAnimation()
            if let err = error {
                self.handleError(error: err)
                return
            }
            self.goBack()
        }
    }
    func validate() -> Bool {
        return self.txtName.validate() && self.txtOrganization.validate() && self.txtIssueDate.validate() && self.txtExpirationDate.validate() && self.txtCredentialID.validate()
    }
    func setupValidation() {
        self.txtName.validations = [.required]
        self.txtOrganization.validations = [.required]
        self.txtIssueDate.validations = [.required]
        self.txtExpirationDate.validations = [.required]
        self.txtCredentialID.validations = [.required]
    }
    
}
