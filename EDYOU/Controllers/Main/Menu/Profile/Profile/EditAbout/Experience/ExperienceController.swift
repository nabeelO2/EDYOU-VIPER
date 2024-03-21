//
//  ExperienceController.swift
//  EDYOU
//
//  Created by Admin on 06/06/2022.
//

import UIKit
import TransitionButton
class ExperienceController: BaseController {
    
    var startDatePicker: UIDatePicker!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtEndDate: BorderedTextField!
    @IBOutlet weak var txtDate: BorderedTextField!
    @IBOutlet weak var txtLocation: BorderedTextField!
    @IBOutlet weak var txtCompanyName: BorderedTextField!
    @IBOutlet weak var txtEmploymentType: BorderedTextField!
    @IBOutlet weak var txtTitle: BorderedTextField!
    @IBOutlet weak var btnCurrentJob: UIButton!
    @IBOutlet weak var vEndDateView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    var userExperience: WorkExperience
    var jobType: JobType?
    var media = [Media]()
    var tittle:String!
    var isCurrentWorking = false
    let placeHolderText = "Short group description..."
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    func setUpView(){
        self.setupValidations()
        self.handleJobEndUI()
        txtTitle.text = userExperience.jobTitle
        //Job Start End Handling and Display
        txtLocation.text = userExperience.companyIndustry
        
        txtCompanyName.text = userExperience.companyName
        self.txtDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: userExperience.jobStart?.toDate)
        self.txtEndDate.setupDatePicker(maximumDate: Date(), minimumDate: nil, selectedDate: userExperience.jobEnd?.toDate)
        self.jobType = JobType(rawValue: userExperience.jobContractType ?? "")
        txtEmploymentType.text = self.jobType?.description
        txtDescription.text = (userExperience.jobDescription?.isEmpty ?? true) ? placeHolderText : userExperience.jobDescription
        if !userExperience.jobTitle.isStringEmpty() {
            self.lblTitle.text = "Edit Experience"
        }
    }
    init(userExperience: WorkExperience) {
        self.userExperience = userExperience
        super.init(nibName: ExperienceController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userExperience = WorkExperience.nilWorkExperince
        super.init(coder: coder)
    }
    deinit {
        print("[ExperienceController] deinit")
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        addWorkExperience()
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        goBack()
    }
    
    @IBAction func didTapCurrentlyWorking(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.handleJobEndUI()
    }
    
    @IBAction func didTapType(_ sender: Any) {
       let experienceType = ExperienceTypeViewController(jobType: jobType, delegate: self)
        self.presentPanModal(experienceType)
    }
    
}

extension ExperienceController : ExperienceTypeSelectedProtocol {
    func experienceTypeSelected(type: JobType) {
        self.jobType = type
        self.txtEmploymentType.text = type.description
    }
}

extension ExperienceController {
    private func handleJobEndUI() {
        if let jobEnd = userExperience.jobEnd , !jobEnd.isEmpty {
            txtEndDate.text = userExperience.jobEnd
            self.btnCurrentJob.isSelected = false
        }
        self.vEndDateView.alpha = self.btnCurrentJob.isSelected ? 0.5 : 1.0
        self.txtEndDate.text = self.btnCurrentJob.isSelected ? "Present" : ""
        self.vEndDateView.isUserInteractionEnabled = !self.btnCurrentJob.isSelected
    }
}

extension ExperienceController {
    
    func addWorkExperience(animateButton: Bool = true){
        self.view.endEditing(true)
        if !validate() {
            self.showErrorWith(message: "Please provide all fields")
            return
        }
        self.handleViewInteraction(enable: false)
        self.userExperience.companyName = txtCompanyName.text
        self.userExperience.jobTitle = txtTitle.text
        self.userExperience.jobContractType = self.jobType!.rawValue
        self.userExperience.companyLocation = self.txtLocation.text
        self.userExperience.jobStart = self.txtDate.selectedDate?.toUTC()
        if !self.btnCurrentJob.isSelected {
            self.userExperience.jobEnd = self.txtEndDate.selectedDate?.toUTC()
        }
        self.userExperience.jobDescription = self.txtDescription.text
        self.btnSave.startAnimation()
        APIManager.social.addUpdateUserProfile(url: Routes.work.url()!, paramter: self.userExperience.dictionary, id: self.userExperience.companyID) { user, error in
            self.btnSave.stopAnimation()
            if let err = error {
                self.handleError(error: err)
                return
            }
            self.goBack()
        }
    }
    
    func validate() -> Bool {
        if !self.btnCurrentJob.isSelected {
            self.txtEndDate.validations = [.required]
        }
        return txtTitle.validate() && txtEmploymentType.validate() && txtCompanyName.validate() && txtLocation.validate() && txtDate.validate() && txtEndDate.validate() && txtLocation.validate() && txtDescription.text.count > 0 && txtDescription.text != placeHolderText
    }
    
    func setupValidations() {
        self.txtTitle.validations = [.required]
        self.txtEmploymentType.validations = [.required]
        self.txtCompanyName.validations = [.required]
        self.txtLocation.validations = [.required]
        self.txtDate.validations = [.required]
        
    }
    func handleViewInteraction(enable: Bool) {
        if !enable {
            self.btnSave.startAnimation()
        } else {
            self.btnSave.stopAnimation()
        }
        self.view.isUserInteractionEnabled = enable
    }
}

extension ExperienceController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
        }
    }
}


