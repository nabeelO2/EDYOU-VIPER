//
//  EducationalInfoController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class EducationalInfoController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtUniversity: BorderedTextField!
    @IBOutlet weak var txtDegree: BorderedTextField!
    @IBOutlet weak var txtFieldOfStudy: BorderedTextField!
    @IBOutlet weak var txtStartDate: BorderedTextField!
    @IBOutlet weak var txtEndDate: BorderedTextField!
    @IBOutlet weak var btnNext: TransitionButton!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var startDate: Date?
    var endDate: Date?
    
    var university: Education
    var degrees = [DataPickerItem<Any>]()
    var fieldsOfStudy = [DataPickerItem<Any>]()
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        txtUniversity.text = university.instituteName
        getMajorSubjects()
    }
    init(university: Education) {
        self.university = university
        super.init(nibName: EducationalInfoController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.university = Education.nilProperties
        super.init(coder: coder)
    }
}

// MARK: - Actions
extension EducationalInfoController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapSkipButton(_ sender: Any) {
        let controller = BirthInfoController()
        navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func didTapDegreeButton(_ sender: Any) {
        let controller = DataPickerController(title: "Degree", data: degrees, singleSelection: true) { [weak self] selectedItems in
            self?.txtDegree.text = selectedItems.first?.title
        }
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func didTapFieldButton(_ sender: Any) {
        let controller = DataPickerController(title: "Field of Study", data: fieldsOfStudy, singleSelection: true) { [weak self] selectedItems in
            self?.txtFieldOfStudy.text = selectedItems.first?.title
        }
        self.present(controller, animated: true, completion: nil)
    }
    @objc func didChangeStartDate() {
        startDate = startDatePicker.date
        txtStartDate.text = startDatePicker.date.stringValue(format: "MMM dd, yyyy")
    }
    @objc func didChangeEndDate() {
        endDate = endDatePicker.date
        txtEndDate.text = endDatePicker.date.stringValue(format: "MMM dd, yyyy")
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        let validated  = validate()
        if validated {
            updateEducationalInfo()
        } else {
            btnNext.shake()
        }
    }
}

// MARK: - Utility Methods
extension EducationalInfoController {
    func setupUI() {
        txtUniversity.validations = [.required]
        txtDegree.validations = [.required]
        txtFieldOfStudy.validations = [.required]
        txtStartDate.validations = [.required]
        txtEndDate.validations = [.required]
        
//        startDatePicker.minimumDate = Date()
//        endDatePicker.minimumDate = Date()
        startDatePicker.addTarget(self, action: #selector(didChangeStartDate), for: .allEvents)
        endDatePicker.addTarget(self, action: #selector(didChangeEndDate), for: .allEvents)
        self.degrees = DataPickerItem<Any>.from(strings: ["BS", "MS", "MPhil", "Phd"])
        self.fieldsOfStudy = DataPickerItem<Any>.from(strings: ["Computer Science", "Physics", "Chemistry", "Mathematice", "Biology", "Engineering"])
    }
    
    func validate() -> Bool {
        let universityValidated = txtUniversity.validate()
        let degreeValidated = txtDegree.validate()
        let fieldValidated = txtFieldOfStudy.validate()
        let fromDateValidated = txtStartDate.validate()
        let toDateValidated = txtEndDate.validate()
        var validated = universityValidated && degreeValidated && fieldValidated && fromDateValidated && toDateValidated
        if let s = startDate, let e = endDate, s >= e, validated == true {
            validated = false
            self.showErrorWith(message: "Start date must be greater than end date")
        }
        
        return validated
    }
}



// MARK: - Web APIs
extension EducationalInfoController {
    func getMajorSubjects() {
        APIManager.auth.getMajorSubjects { (subjects, error) in
            if error == nil {
                self.fieldsOfStudy = DataPickerItem<Any>.from(strings: subjects)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func updateEducationalInfo() {
        let parameters: [String: Any] = [
            "institute_name": txtUniversity.text ?? "",
            "education": [
                [
                    "institute_name": txtUniversity.text ?? "",
                    "degree_name": txtDegree.text ?? "",
                    "degree_field_name": txtFieldOfStudy.text ?? "",
                    "degree_start": startDate?.stringValue(format: "yyyy-MM-dd'T'HH:mm:ss"),
                    "degree_end": endDate?.stringValue(format: "yyyy-MM-dd'T'HH:mm:ss")
                ]
            ]
        ]
        view.endEditing(true)
        btnNext.startAnimation()
        view.isUserInteractionEnabled = false
        APIManager.social.updateProfile(parameters) { [weak self] response, error in
            guard let self = self else { return }
            self.btnNext.stopAnimation()
            self.view.isUserInteractionEnabled = true
            
            if error == nil {
                let controller = BirthInfoController()
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            
        }
        
    }
}
