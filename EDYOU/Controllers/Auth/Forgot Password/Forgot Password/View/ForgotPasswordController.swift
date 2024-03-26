//
//  ForgotPasswordController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class ForgotPasswordController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtEmail:  BorderedTextField!
    @IBOutlet weak var btnResetPassword: TransitionButton!
    
    var presenter : ForgotPasswordPresenterProtocol!
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

}


// MARK: - Actions
extension ForgotPasswordController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        presenter.forgotPassword(with: txtEmail.text ?? "", validation: txtEmail.validate())
       
       
    }
}

// MARK: - Utility Methods
extension ForgotPasswordController {
    func setupUI() {
        txtEmail.leftSeparatorView.isHidden = true
        txtEmail.placeHolderLeadingConstraint.constant = 0
        txtEmail.textField.keyboardType = .emailAddress
        txtEmail.textField.autocorrectionType = .no
        txtEmail.validations = [.required, .email]
    }
    
}

extension ForgotPasswordController : ForgotPasswordViewProtocol{
    func prepareUI() {
        setupUI()
    }
    func showErrorMessage(_ message: String) {
        self.showErrorWith(message: message)
    }
    func startAnimating() {
        btnResetPassword.startAnimation()
    }
    func stopAnimating() {
        
        btnResetPassword.stopAnimation(animationStyle: .normal, revertAfterDelay: 1.0) {
            
        }
    }
    func shakeBtn() {
        btnResetPassword.shake()
    }
    func getEmail() -> String {
       return txtEmail.text ?? ""
    }
    func userInteraction(_ isTrue: Bool) {
        view.isUserInteractionEnabled = isTrue
    }
    func endEditing() {
        view.endEditing(true)
    }
    
}
