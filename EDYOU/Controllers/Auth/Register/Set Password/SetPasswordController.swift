//
//  SetPasswordController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class SetPasswordController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtPassword: BorderedTextField!
    @IBOutlet weak var txtConfirmPassword: BorderedTextField!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnShowConfirmPassword: UIButton!
    @IBOutlet weak var btnNext: TransitionButton!
    
    var code = ""
    var institute: Institute
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(institute: Institute, code: String) {
        self.institute = institute
        self.code = code
        super.init(nibName: SetPasswordController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.institute = Institute(name: "", emailSuffix: "", icon: "", schoolID: "")
        super.init(coder: coder)
    }

}


// MARK: - Actions
extension SetPasswordController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapShowPasswordButton(_ sender: Any) {
        txtPassword.textField.isSecureTextEntry = !txtPassword.textField.isSecureTextEntry
        btnShowPassword.setTitle(txtPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapShowConfirmPasswordButton(_ sender: Any) {
        txtConfirmPassword.textField.isSecureTextEntry = !txtConfirmPassword.textField.isSecureTextEntry
        btnShowConfirmPassword.setTitle(txtConfirmPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        
        let validated  = validate()
        if validated {
            setPassword()
        } else {
            btnNext.shake()
        }
    }
}

// MARK: - Utility Methods
extension SetPasswordController {
    func setupUI() {
        txtPassword.textField.isSecureTextEntry = true
        txtPassword.validations = [.required, .min(length: 8)]
        txtPassword.textField.delegate = self
        
        txtConfirmPassword.textField.isSecureTextEntry = true
        txtConfirmPassword.validations = [.required, .min(length: 8)]
        txtConfirmPassword.textField.delegate = self
    }
    func validate() -> Bool {
        let passwordValidated = txtPassword.validate()
        let confirmPasswordValidated = txtConfirmPassword.validate()
        if passwordValidated && confirmPasswordValidated && txtPassword.text != txtConfirmPassword.text {
            txtConfirmPassword.setError("Password and confirm password does not match")
        }
        return passwordValidated && confirmPasswordValidated && txtPassword.text == txtConfirmPassword.text
    }
    
    
    
}


// MARK: - TextField Delegate
extension SetPasswordController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        if let text = textField.text {
            let oldText = text
            let inputString = string as NSString
            if range.location > 0 && range.length == 1 && inputString.length == 0 {//Backspace pressed
                textField.deleteBackward()
                
                if let updatedText = textField.text as NSString? {
                    if updatedText.length != oldText.count - 1 {
                        expectedText = ""
                    }
                }
            }
        }
        
        
        if textField == txtPassword.textField {
            btnShowPassword.isHidden = expectedText.count == 0
        } else if textField == txtConfirmPassword.textField {
            btnShowConfirmPassword.isHidden = expectedText.count == 0
        }
        
        return true
    }
}



// MARK: - Web APIs
extension SetPasswordController {
    
    func setPassword() {
        
        view.endEditing(true)
        btnNext.startAnimation()
        APIManager.auth.set(password: txtPassword.text ?? "", verificationCode: code) { [weak self] token, error in
            guard let self = self else { return }
            self.btnNext.stopAnimation()
            
            if error == nil {
                self.updateEducationalInfo()
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
        
    }
    func updateEducationalInfo() {
        let parameters: [String: Any] = [
            "education": [
                [
                    "institute_name": institute.name,
                ]
            ],
            "institute_name": institute.name
        ]
        view.endEditing(true)
        btnNext.startAnimation()
        view.isUserInteractionEnabled = false
        APIManager.social.updateProfile(parameters) { [weak self] response, error in
            guard let self = self else { return }
            self.btnNext.stopAnimation()
            self.view.isUserInteractionEnabled = true
            
            if error == nil {
                let university = Education.nilProperties
                university.instituteName = self.institute.name
                let controller = AddNameController(university: university)
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            
        }
        
    }
}
