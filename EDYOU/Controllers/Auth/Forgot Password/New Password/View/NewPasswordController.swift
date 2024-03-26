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
    var presenter : NewPasswordPresenterProtocol!
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
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
        presenter.didTapShowPasswordButton()
        
        
    }
    @IBAction func didTapShowConfirmPasswordButton(_ sender: Any) {
        presenter.didTapShowConfirmPasswordButton()
//        txtConfirmPassword.textField.isSecureTextEntry = !txtConfirmPassword.textField.isSecureTextEntry
//        btnShowConfirmPassword.setTitle(txtConfirmPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapSaveButton(_ sender: Any) {
        presenter.didTapSavePasswordButton()
        
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

extension NewPasswordController : NewPasswordViewProtocol{
    
    func getPin() -> String {
        return pin
    }
    func getPasswordText() -> String {
        return txtPassword.text ?? ""
    }
    
    func getConfirmPasswordText() -> String {
        return txtConfirmPassword.text ?? ""
    }
    
    func getPasswordValidation() -> Bool {
        return txtPassword.validate()
    }
    
    func getConfirmPasswordValidation() -> Bool {
        return txtConfirmPassword.validate()
    }
    
    
    func updateTextPassword(_ text: String) {
        btnShowPassword.setTitle(text, for: .normal)
    }
    
    func updateTextConfirmPassword(_ text: String) {
        btnShowConfirmPassword.setTitle(text, for: .normal)
    }
    
    func showPasswordSecured() {
        txtPassword.textField.isSecureTextEntry = true
    }
    
    func showPasswordUnSecured() {
        txtPassword.textField.isSecureTextEntry = false
    }
    
    func showConfirmPasswordSecured() {
        txtConfirmPassword.textField.isSecureTextEntry = true
    }
    
    func showConfirmPasswordUnSecured() {
        txtConfirmPassword.textField.isSecureTextEntry = false
    }
    
    func getShowPasswordSecure() -> Bool {
        return txtPassword.textField.isSecureTextEntry
    }
    
    func getShowConfirmPasswordSecure() -> Bool {
        return txtConfirmPassword.textField.isSecureTextEntry
    }
    
    func prepareUI() {
        setupUI()
    }
    func endEditing() {
        view.endEditing(true)
    }
    func userInteraction(_ isTrue: Bool) {
        view.isUserInteractionEnabled = isTrue
    }
    func showErrorMessage(_ message: String) {
        self.showErrorWith(message: message)
    }
    func startAnimating() {
        btnSave.startAnimation()
    }
    func stopAnimating() {
        btnSave.stopAnimation()
    }
    
    func shakeBtn() {
        btnSave.shake()
    }
    func showSuccessMessageToUser(_ message: String) {
        showSuccessMessage(message: message)
    }
    func startLoading(with text: String) {
        self.startLoading(title: text)
    }
    func stopLoadingTxt() {
        self.stopLoading()
    }
}
