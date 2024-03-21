//
//  AddEmailController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class AddEmailController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtEmail: BorderedTextField!
    @IBOutlet weak var btnNext: TransitionButton!
    
    var institute: Institute
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(institute: Institute) {
        self.institute = institute
        super.init(nibName: AddEmailController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.institute = Institute(name: "", emailSuffix: "", icon: "", schoolID: "")
        super.init(coder: coder)
    }

    
}



// MARK: - Actions
extension AddEmailController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        let validated  = validate()
        if validated {
            
            view.endEditing(true)
            btnNext.startAnimation()
//            APIManager.auth.signup(email: txtEmail.text ?? "") { [weak self] oneTimeToken, error in
//                guard let self = self else { return }
//                self.btnNext.stopAnimation()
//
//                if error == nil {
//                    let controller = VerifyEmailController(institute: self.institute)
//                    self.navigationController?.pushViewController(controller, animated: true)
//                } else {
//                    self.showErrorWith(message: error?.message ?? "Invalid response")
//                }
//
//            }
            
        } else {
            btnNext.shake()
        }
    }
}

// MARK: - Utility Methods
extension AddEmailController {
    func setupUI() {
        txtEmail.placeholder = "email\(institute.emailSuffix)"
        txtEmail.textField.keyboardType = .emailAddress
        txtEmail.textField.autocorrectionType = .no
        txtEmail.validations = [.required, .email]
    }
    func validate() -> Bool {
        let emailValidated = txtEmail.validate()
        let suffix = txtEmail.text?.components(separatedBy: "@").last ?? ""
        
        if emailValidated && ("@\(suffix)" != institute.emailSuffix && "@\(suffix)" != "@yopmail.com") {
            txtEmail.setError("Invalid institute email")
            return false
        }
        
        return emailValidated
    }
}
