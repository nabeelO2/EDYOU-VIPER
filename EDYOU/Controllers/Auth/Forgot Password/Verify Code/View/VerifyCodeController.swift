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
    var presenter : VerifyCodePresenterProtocol!
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        //setupUI()
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
        let validated  = validate()
        presenter.verifyCode(with: txtPinCode.text, validation: validated)
    }
    @IBAction func didTapResendCodeButton(_ sender: Any) {
        presenter.resendCode(with: email)
        
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

extension VerifyCodeController : VerifyCodeViewProtocol{
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
        btnConfirm.startAnimation()
    }
    func stopAnimating() {
        btnConfirm.stopAnimation()
    }
    
    func shakeBtn() {
        btnConfirm.shake()
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
    
    func getPinCode() -> String {
        return self.txtPinCode.text
    }
}
