//
//  NewPasswordController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class ChangePasswordController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtOldPassword: BorderedTextField!
    @IBOutlet weak var txtNewPassword: BorderedTextField!
    @IBOutlet weak var txtConfirmPassword: BorderedTextField!
    @IBOutlet weak var btnShowOldPassword: UIButton!
    @IBOutlet weak var btnShowNewPassword: UIButton!
    @IBOutlet weak var btnShowConfirmPassword: UIButton!
    @IBOutlet weak var btnSave: TransitionButton!
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}


// MARK: - Actions
extension ChangePasswordController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapShowOldPasswordButton(_ sender: Any) {
        txtOldPassword.textField.isSecureTextEntry = !txtOldPassword.textField.isSecureTextEntry
        btnShowOldPassword.setTitle(txtOldPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapShowNewPasswordButton(_ sender: Any) {
        txtNewPassword.textField.isSecureTextEntry = !txtNewPassword.textField.isSecureTextEntry
        btnShowNewPassword.setTitle(txtNewPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapShowConfirmPasswordButton(_ sender: Any) {
        txtConfirmPassword.textField.isSecureTextEntry = !txtConfirmPassword.textField.isSecureTextEntry
        btnShowConfirmPassword.setTitle(txtConfirmPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapSaveButton(_ sender: Any) {
        let validated  = validate()
        if validated {
            changePassword()
        } else {
            btnSave.shake()
        }
    }
}

// MARK: - Utility Methods
extension ChangePasswordController {
    func setupUI() {
        txtOldPassword.textField.isSecureTextEntry = true
        txtOldPassword.validations = [.required, .min(length: 8)]
        txtOldPassword.textField.delegate = self
        
        txtNewPassword.textField.isSecureTextEntry = true
        txtNewPassword.validations = [.required, .min(length: 8)]
        txtNewPassword.textField.delegate = self
        
        txtConfirmPassword.textField.isSecureTextEntry = true
        txtConfirmPassword.validations = [.required, .min(length: 8)]
        txtConfirmPassword.textField.delegate = self
    }
    func validate() -> Bool {
        let oldPasswordValidated = txtOldPassword.validate()
        let passwordValidated = txtNewPassword.validate()
        let confirmPasswordValidated = txtConfirmPassword.validate()
        return oldPasswordValidated && passwordValidated && confirmPasswordValidated && txtNewPassword.text == txtConfirmPassword.text
    }
}


// MARK: - TextField Delegate
extension ChangePasswordController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        if textField == txtOldPassword.textField {
            btnShowOldPassword.isHidden = expectedText.count == 0
        } else if textField == txtNewPassword.textField {
            btnShowNewPassword.isHidden = expectedText.count == 0
        } else if textField == txtConfirmPassword.textField {
            btnShowConfirmPassword.isHidden = expectedText.count == 0
        }
        
        return true
    }
}


// MARK: - Web APIs
extension ChangePasswordController {
    func changePassword() {
        
        view.isUserInteractionEnabled = false
        btnSave.startAnimation()
        APIManager.auth.changePassword(oldPassword: txtOldPassword.text ?? "", newPassword: txtNewPassword.text ?? "") { [weak self] error in
            guard let self = self else { return }
            
            self.view.isUserInteractionEnabled = true
            self.btnSave.stopAnimation()
            if error == nil {
                self.showSuccessMessage(message: "Password updated successfully")
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
        
    }
}
