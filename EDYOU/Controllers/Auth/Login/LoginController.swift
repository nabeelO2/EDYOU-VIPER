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
    {
        didSet{
            txtEmail.leftSeparatorView.isHidden = true
            txtEmail.placeHolderLeadingConstraint.constant = 0
        }
    }
    @IBOutlet weak var txtPassword: BorderedTextField!
    {
        didSet{
            txtPassword.leftSeparatorView.isHidden = true
            txtPassword.placeHolderLeadingConstraint.constant = 0
        }
    }
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnShow: UIButton!
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
//        #if DEBUG
//        txtEmail.text = "jhangir@cornell.edu"
//        txtPassword.text = "@Service1"
//        #endif
    }

}


// MARK: - Actions
extension LoginController {
    @IBAction func didTapLoginButton(_ sender: Any) {
        let validated  = validate()
        if validated {
            
            view.endEditing(true)
            login()
            
        } else {
            btnLogin.shake()
        }
    }
    @IBAction func didTapShowButton(_ sender: Any) {
        txtPassword.textField.isSecureTextEntry = !txtPassword.textField.isSecureTextEntry
        btnShow.setTitle(txtPassword.textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }
    @IBAction func didTapForgotPasswordButton(_ sender: Any) {
        let controller = ForgotPasswordController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapCreateAccountButton(_ sender: Any) {
        
//        if AppDefaults.shared.termsAndConditionsAccepted {
//            let controller = SignupViewController(nibName: "SignupController", bundle: nil)
//            self.navigationController?.pushViewController(controller, animated: true)
//        } else {
//
//
//            let controller = PrivacyPolicyController { isAccepted in
//
//                if isAccepted {
//                   / AppDefaults.shared.termsAndConditionsAccepted = isAccepted
                    
                    let controller = SignupViewController(nibName: "SignupController", bundle: nil)
              
                    self.navigationController?.pushViewController(controller, animated: true)
//                }
//
//            }
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true, completion: nil)
    //    }
        
        
        
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
            btnShow.isHidden = expectedText.count == 0
        }
        
        return true
    }
}


// MARK: - Web APIs
extension LoginController {
    func login() {
        btnLogin.startAnimation()
        APIManager.auth.login(email: txtEmail.text!, password: txtPassword.text!) { [weak self] response, error in
            guard let self = self else { return }
            if error == nil {
//                if let id = response?.dictionary["id"] as? String, (id == "1" || id == "2" || id == "3"){
//                    UserDefaults.standard.set(true, forKey: "isEmailVerified")
//                    UserDefaults.standard.set(nil, forKey: "invitationCode")
//                    self.changeInvitationStatus()
//                }
//                else{
                    UserDefaults.standard.set(true, forKey: "loggedIn")
//                        UserDefaults.standard.set("", forKey: "invitationCode")
                    self.getUserDetails()
//                    UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
//                    UserDefaults.standard.synchronize()
//                    Application.shared.switchToHome()
//                }
//                self.getUserDetails()
                
            } else {
                self.btnLogin.stopAnimation()
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getUserDetails() {
        self.connectSocket()
//        Constants.baseURL = "https://sanitas.serveo.net"
        APIManager.social.getUserInfo { [weak self] user, error in
//            Constants.baseURL = "https://8172-182-180-126-38.ngrok-free.app"
            guard let self = self else { return }
            self.btnLogin.stopAnimation()
            if let user = user {
                if let id = user.userID, let pass  = Keychain.shared.accessToken {
                    XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io" , pass: pass)
                }
                if user.major_start_year?.isEmpty == true || user.major_end_year?.isEmpty == true{
                    UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
                    UserDefaults.standard.synchronize()
                    let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
                    self.navigationController?.pushViewController(controller, animated: true)
                    return
                }
                    
                let university = user.education.first ?? Education.nilProperties
                if user.name?.firstName?.isEmpty == false || user.name?.lastName?.isEmpty == false {
                    Application.shared.switchToHome()
                } else {
                    let controller = AddNameController(university: university)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                self.showErrorWith(message: error?.message ?? "Unexpected error")
            }
        }
    }
    
    func connectSocket() {
//        ChatManager.shared.connect()
    }
    func changeInvitationStatus(){
        if UserDefaults.standard.string(forKey: "invitationCode") != nil{
            
        }
        else{
            
            
            inviteCodeScreen()
        }
        
    }
    func inviteCodeScreen(){
        let vc = InviteCodeController()
        present(vc, presentationStyle: .fullScreen)
    }
}
