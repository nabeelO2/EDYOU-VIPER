//
//  LoginController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class LoginController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtEmail: BorderedTextField!
    
    @IBOutlet weak var txtPassword: BorderedTextField!
    
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnShow: UIButton!
    
    var presenter: LoginPresenterProtocol!
   
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

}


// MARK: - Actions
extension LoginController {
    @IBAction func didTapLoginButton(_ sender: Any) {
        let emailValidated = txtEmail.validate()
        let passwordValidated = txtPassword.validate()
        let res = emailValidated && passwordValidated
        
        presenter.login(email: txtEmail.text, password: txtPassword.text, isValidation: res)
        
    }
    @IBAction func didTapShowButton(_ sender: Any) {
        presenter.showHidePassword()
    }
    @IBAction func didTapForgotPasswordButton(_ sender: Any) {
        presenter.navigateToForgetPassword()
    }
    @IBAction func didTapCreateAccountButton(_ sender: Any) {
        presenter.navigateToSignup()
    }
}

// MARK: - Utility Methods
extension LoginController {
    func setupUI() {
        txtEmail.textField.keyboardType = .emailAddress
        txtEmail.textField.autocorrectionType = .no
        txtEmail.validations = [.required, .email]
        txtPassword.textField.isSecureTextEntry = true
        txtPassword.validations = [.required, .min(length: 8)]
        txtPassword.textField.delegate = self
        txtPassword.textField.keyboardType = .default
    }
    func validate() -> Bool {
        let emailValidated = txtEmail.validate()
        let passwordValidated = txtPassword.validate()
        return emailValidated && passwordValidated
    }
}


// MARK: - TextField Delegate
extension LoginController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPassword.textField {
            let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
            presenter.textFieldDidChange(text: expectedText)
        }
        
        return true
    }
}



extension LoginController : LoginViewProtocol{
    func startAnimating() {
        btnLogin.startAnimation()
    }
    
    func stopAnimating() {
        btnLogin.stopAnimation()
    }
    
    func showHidePassword() {
        txtPassword.textField.isSecureTextEntry = !txtPassword.textField.isSecureTextEntry
        btnShow.setTitle(txtPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    
    func shakeLoginButton() {
        btnLogin.shake()
    }
    
    func prepareUI() {
        txtEmail.leftSeparatorView.isHidden = true
        txtEmail.placeHolderLeadingConstraint.constant = 0
        
        txtPassword.leftSeparatorView.isHidden = true
        txtPassword.placeHolderLeadingConstraint.constant = 0
        
        setupUI()
    }
    func passwordBtnVisibility(_ isHidden : Bool){
        btnShow.isHidden = isHidden
    }
    func showErrorMessage(_ message: String) {
        self.showErrorWith(message: message)
    }
}
