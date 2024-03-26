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
        presenter.forgotPassword(with: txtEmail.text ?? "", validation: validate())
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
        
    }
    func startAnimating() {
        
    }
    func stopAnimating() {
        
    }
}
