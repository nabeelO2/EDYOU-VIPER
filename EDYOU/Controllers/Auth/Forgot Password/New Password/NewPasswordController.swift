//
//  NewPasswordController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class NewPasswordController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtPassword: BorderedTextField!
    @IBOutlet weak var txtConfirmPassword: BorderedTextField!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnShowConfirmPassword: UIButton!
    @IBOutlet weak var btnSave: TransitionButton!
    
    var pin = ""
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    init(pin: String) {
        super.init(nibName: NewPasswordController.name, bundle: nil)
        self.pin = pin
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


// MARK: - Actions
extension NewPasswordController {
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
    @IBAction func didTapSaveButton(_ sender: Any) {
        view.endEditing(true)
        let validated  = validate()
        if validated {
            
            btnSave.startAnimation()
            view.isUserInteractionEnabled = false
            APIManager.auth.forgotPasswordChange(code: pin, newPassword: txtPassword.text ?? "") { [weak self] (error) in
                guard let self = self else { return }
                self.view.isUserInteractionEnabled = true
                self.btnSave.stopAnimation()
                
                if error == nil {
                    self.showSuccessMessage(message: "Password updated successfully")
                    for controller in (self.navigationController?.viewControllers ?? []) {
                        if controller is LoginController {
                            self.navigationController?.popToViewController(controller, animated: true)
                            return
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                } else {
                    self.showErrorWith(message: error!.message)
                }
                
            }
            
        } else {
            btnSave.shake()
        }
    }
}

// MARK: - Utility Methods
extension NewPasswordController {
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
            txtConfirmPassword.setError("Password and Confirm Password does not match")
        }
        return passwordValidated && confirmPasswordValidated && txtPassword.text == txtConfirmPassword.text
    }
}


// MARK: - TextField Delegate
extension NewPasswordController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPassword.textField {
            let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
            btnShowPassword.isHidden = expectedText.count == 0
        } else if textField == txtConfirmPassword.textField {
            let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
            btnShowConfirmPassword.isHidden = expectedText.count == 0
        }
        
        return true
    }
}
