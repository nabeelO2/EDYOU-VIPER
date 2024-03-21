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
    {
        didSet{
            txtEmail.leftSeparatorView.isHidden = true
            txtEmail.placeHolderLeadingConstraint.constant = 0
        }
    }
    @IBOutlet weak var btnResetPassword: TransitionButton!
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}


// MARK: - Actions
extension ForgotPasswordController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapResetPasswordButton(_ sender: Any) {
        view.endEditing(true)
        let validated  = validate()
        if validated {
            btnResetPassword.startAnimation()
            view.isUserInteractionEnabled = false
            APIManager.auth.forgotPassword(email: txtEmail.text ?? "") { [weak self] (token, error) in
                guard let self = self else { return }
                self.view.isUserInteractionEnabled = true
                self.btnResetPassword.stopAnimation()
                
                if error == nil {
                    let controller = VerifyCodeController(email: self.txtEmail.text ?? "")
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.showErrorWith(message: error!.message)
                }
                
            }
            
        } else {
            btnResetPassword.shake()
        }
    }
}

// MARK: - Utility Methods
extension ForgotPasswordController {
    func setupUI() {
        txtEmail.textField.keyboardType = .emailAddress
        txtEmail.textField.autocorrectionType = .no
        txtEmail.validations = [.required, .email]
    }
    func validate() -> Bool {
        let emailValidated = txtEmail.validate()
        return emailValidated
    }
}
