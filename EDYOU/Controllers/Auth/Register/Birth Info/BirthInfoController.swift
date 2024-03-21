//
//  BirthInfoController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class BirthInfoController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtDateOfBirth: BorderedTextField!
    @IBOutlet weak var txtGender: BorderedTextField!
    @IBOutlet weak var btnNext: TransitionButton!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    var adapter: PickerViewAdapter!
    var dateOfBirth: Date?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        adapter = PickerViewAdapter(textField: txtGender.textField, data: ["Male", "Female", "Other"], selectedValue: { [weak self] value in
            self?.txtGender.text = value
        })
    }

}

// MARK: - Actions
extension BirthInfoController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapSkipButton(_ sender: Any) {
        let controller = InviteFriendsController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func didChangeDate() {
        dateOfBirth = startDatePicker.date
        txtDateOfBirth.text = startDatePicker.date.stringValue(format: "MMM dd, yyyy")
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        let validated  = validate()
        if validated {

            updateBirthlInfo()
        } else {
            btnNext.shake()
        }
    }
}

// MARK: - Utility Methods
extension BirthInfoController {
    func setupUI() {
        startDatePicker.minimumDate = nil
        startDatePicker.maximumDate = Date()
        startDatePicker.addTarget(self, action: #selector(didChangeDate), for: .allEvents)
        txtGender.validations = [.required]
        txtDateOfBirth.validations = [.required]
    }
    func validate() -> Bool {
        let genderValidated = txtGender.validate()
        let birthdayValidated = txtDateOfBirth.validate()
        return genderValidated && birthdayValidated
    }
}


// MARK: - Web APIs
extension BirthInfoController {
    
    func updateBirthlInfo() {
        
        
        let parameters: [String: Any] = [
            "gender": (txtGender.text ?? "").lowercased(),
            "date_of_birth": [
                "birth_year": dateOfBirth?.stringValue(format: "yyyy"),
                "birth_month": dateOfBirth?.stringValue(format: "MM"),
                "birth_date": dateOfBirth?.stringValue(format: "dd")
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
                let controller = InviteFriendsController()
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            
        }
        
    }
}
