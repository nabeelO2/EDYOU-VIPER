//
//  EducationController.swift
//  EDYOU
//
//  Created by Admin on 06/06/2022.
//

import UIKit
import TransitionButton
class EducationController: BaseController {
    @IBOutlet weak var txtSchoolName: BorderedTextField!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var txtEndDate: BorderedTextField!
    @IBOutlet weak var txtDate: BorderedTextField!
    @IBOutlet weak var txtLocation: BorderedTextField!
    @IBOutlet weak var txtDegreeName: BorderedTextField!
    @IBOutlet weak var lblTitle: UILabel!
    var userEducation:Education
    @IBOutlet weak var txtMajor: BorderedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIValues()
        self.setupValidations()
        self.setupDatePicker()
    }
    
    init(userEducation: Education, tittle: String = "") {
        self.userEducation = userEducation
        super.init(nibName: EducationController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.userEducation = Education.nilProperties
        super.init(coder: coder)
    }
    deinit {
        print("[EducationController] deinit")
    }
    
    
    func setUIValues() {
        txtSchoolName.text = userEducation.instituteName
        txtDegreeName.text = userEducation.degreeFieldName
        txtLocation.text = userEducation.instituteLocation
        if !self.userEducation.instituteName.isStringEmpty() {
            self.lblTitle.text = "Edit Education"
        }
    }
    
    func setupDatePicker() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        guard let maximumDate = calendar.date(from: DateComponents(year: currentYear + 6))?.addingTimeInterval(-1) else {
            return
        }
        self.txtDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: self.userEducation.degreeStart?.toDate)
        self.txtEndDate.setupDatePicker(maximumDate: maximumDate, minimumDate: nil, selectedDate: self.userEducation.degreeEnd?.toDate)
        self.txtDate.textField.delegate = self
        self.txtEndDate.textField.delegate = self
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        goBack()
    }
    @IBAction func didTapSave(_ sender: Any) {
        if validate() {
            addEducation(animateButton: true)
        }
    }
    
   
}

extension EducationController {
    func validate() -> Bool {
        return self.txtSchoolName.validate() && self.txtDegreeName.validate() && self.txtMajor.validate() && self.txtLocation.validate() && self.txtDate.validate()
    }
    func addEducation(animateButton: Bool = true){
        let education: Education = Education(instituteName: self.txtSchoolName.text, degreeName: self.txtDegreeName.text, major: self.txtMajor.text, degreeFieldName: "", degreeStart: self.txtDate.selectedDate?.toUTC(), degreeEnd: self.txtEndDate.selectedDate?.toUTC(), instituteLocation: self.txtLocation.text)
        
        if let educationId = userEducation.educationId {
            education.educationId = educationId.isEmpty ? nil : educationId
        }
        education.isCurrent = true
        self.handleViewLoading(enable: false)
        btnSave.startAnimation()

        APIManager.social.addUpdateEducation(url: Routes.education.url()!, paramter: education.dictionary, id: education.educationId) { user, error in
            self.btnSave.stopAnimation()
            self.handleViewLoading(enable: true)
            if let err = error {
                self.handleError(error: err)
                return
            }
            self.goBack()
        }
    }
    func setupValidations() {
        self.txtSchoolName.validations = [.required]
        self.txtDegreeName.validations = [.required]
        self.txtMajor.validations = [.required]
        self.txtDate.validations = [.required]
        self.txtLocation.validations = [.required]
    }
}

extension EducationController: UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (textField == txtDate.textField || textField == txtEndDate.textField) {
            self.checkTxtFieldValidation()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == txtDate.textField || textField == txtEndDate.textField) {
            self.checkTxtFieldValidation()
//            if  (textField.checkTxtFieldValidation(startDate: self.txtDate.text, endDate: self.txtEndDate.text)) {
//                showValidationMesage()
//            }
        }
    }
 
 
    func checkTxtFieldValidation() {
        guard let startTxtDate = self.txtDate.text else {
            return
        }
        guard  let endTxtDate = self.txtEndDate.text else {
            return
        }

        guard let startDate = startTxtDate.toDate else {
            return
        }
        guard  let endDate = endTxtDate.toDate else {
            return
        }

        let isGreater = startDate.isGreaterThan(endDate)
        let isEqual = startDate.isEqualTo(endDate)
        if (isGreater || isEqual) {
            self.txtEndDate.text = nil
            self.showAlert(title: "Invalid Date", description: "End Date should be greater than start date")
        }
    }
    
}
