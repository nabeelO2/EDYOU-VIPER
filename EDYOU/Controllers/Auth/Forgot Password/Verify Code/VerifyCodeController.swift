//
//  VerifyCodeController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class VerifyCodeController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtPinCode: PinCodeTextField!
    @IBOutlet weak var btnConfirm: TransitionButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    var email = ""
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(email: String) {
        super.init(nibName: VerifyCodeController.name, bundle: nil)
        self.email = email
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}



// MARK: - Actions
extension VerifyCodeController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapConfirmButton(_ sender: Any) {
        view.endEditing(true)
        let validated  = validate()
        if validated {
            
            btnConfirm.startAnimation()
            view.isUserInteractionEnabled = false
            APIManager.auth.forgotPasswordVerify(code: txtPinCode.text) { [weak self] (error) in
                guard let self = self else { return }
                self.view.isUserInteractionEnabled = true
                self.btnConfirm.stopAnimation()
                
                if error == nil {
                    let controller = NewPasswordController(pin: self.txtPinCode.text)
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.showErrorWith(message: error!.message)
                }
                
            }
            
            
            
        } else {
            btnConfirm.shake()
        }
        
        
    }
    @IBAction func didTapResendCodeButton(_ sender: Any) {
        view.endEditing(true)
        self.startLoading(title: "")
        APIManager.auth.forgotPassword(email: email) { [weak self] (token, error) in
            guard let self = self else { return }
            self.stopLoading()
            
            if error == nil {
                self.showSuccessMessage(message: "4 digit code sent to your email")
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
    }
}

// MARK: - Utility Methods
extension VerifyCodeController {
    func setupUI() {
        self.emailLabel.text  = self.email
    }
    func validate() -> Bool {
        let pincodeValidated = txtPinCode.text.count == 4
        return pincodeValidated
    }
}
