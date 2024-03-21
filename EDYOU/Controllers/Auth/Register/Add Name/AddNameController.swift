//
//  AddNameController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class AddNameController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtFirstName: BorderedTextField!
    @IBOutlet weak var txtLastName: BorderedTextField!
    @IBOutlet weak var btnNext: TransitionButton!
    
    var university: Education
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(university: Education) {
        self.university = university
        super.init(nibName: AddNameController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.university = Education.nilProperties
        super.init(coder: coder)
    }

    
}



// MARK: - Actions
extension AddNameController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        let validated  = validate()
        if validated {
            updateName()
        } else {
            btnNext.shake()
        }
    }
}

// MARK: - Utility Methods
extension AddNameController {
    func setupUI() {
        txtFirstName.textField.autocorrectionType = .no
        txtFirstName.textField.autocapitalizationType = .words
        txtFirstName.validations = [.required]
        
        txtLastName.textField.autocorrectionType = .no
        txtLastName.textField.autocapitalizationType = .words
        txtLastName.validations = [.required]
    }
    func validate() -> Bool {
        let firstNameValidated = txtFirstName.validate()
        let lastNameValidated = txtLastName.validate()
        return firstNameValidated && lastNameValidated
    }
}

// MARK: - Web APIs
extension AddNameController {
    func updateName() {
        
        let parameters: [String: Any] = [
            "name": [
                "first_name": txtFirstName.text ?? "",
                "last_name": txtLastName.text ?? ""
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
                //let controller = SelectPhotoController(university: self.university)
               // self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            
        }
        
    }
}
