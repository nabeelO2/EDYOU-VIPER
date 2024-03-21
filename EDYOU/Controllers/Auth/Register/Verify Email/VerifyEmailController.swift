//
//  VerifyEmailController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class VerifyEmailController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtPinCode: PinCodeTextField!
    @IBOutlet weak var btnConfirm: TransitionButton!
    @IBOutlet weak var lblTimer: UILabel!
    
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailLabel: UILabel!
    private var timer: Timer?
    private var time = 60
    
    var email: String = ""
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: VerifyEmailController.name, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.email = ""
        super.init(coder: coder)
    }
    init(code: [String]) {
        
        super.init(nibName: VerifyEmailController.name, bundle: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            self.VerifyOTP(code)
        }
    }
    

    func VerifyOTP(_ otp : [String]){
        txtPinCode.txtPin1.text = otp[0]
        txtPinCode.txtPin2.text = otp[1]
        txtPinCode.txtPin3.text = otp[2]
        txtPinCode.txtPin4.text = otp[3]
        
        didTapConfirmButton(btnConfirm)
    }
}



// MARK: - Actions
extension VerifyEmailController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapConfirmButton(_ sender: Any) {
        
        
        let validated  = validate()
        if validated {
            
            view.endEditing(true)
            btnConfirm.startAnimation()
            APIManager.auth.verify(code: txtPinCode.text) { [weak self] response, error in
                guard let self = self else { return }
                self.btnConfirm.stopAnimation()
                if error == nil {
                    
                    //change status for inviteCode
//                    if let id = response?.dictionary["id"] as? String, (id == "1" || id == "2" || id == "3"){
//                        UserDefaults.standard.set(true, forKey: "isEmailVerified")
//                        UserDefaults.standard.set(nil, forKey: "invitationCode")
//                        self.changeInvitationStatus()
//                    }
//                    else{
                        
                        UserDefaults.standard.set(nil, forKey: "invitationCode")
                        UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
                        UserDefaults.standard.synchronize()
                    
                    if let id = Cache.shared.user?.userID, let pass  = Keychain.shared.accessToken {
                        XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io" , pass: pass)
                    }
                        Application.shared.switchToHome()
                        
//                    }
                    

                } else {
                    self.showErrorWith(message: error!.message)
                }
            }
            
        } else {
            btnConfirm.shake()
        }
    }
    
    func changeInvitationStatus(){
        if let code = UserDefaults.standard.string(forKey: "invitationCode"){
//            let parameters : [String: Any]  = [
//              "invite_status": "completed",
//              "referral_code": "\(code)",
//              "is_invited_user" : true
//            ]
//            APIManager.social.updateInviteStatus(parameters, completion: { error in
//                //self.getInvitedUser()
//                UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
//                UserDefaults.standard.synchronize()
//                let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
//                self.navigationController?.pushViewController(controller, animated: true)
//
//            })
        }
        else{
            
//            print("invitation code not found")
            inviteCodeScreen()
        }
        
    }
    
    func inviteCodeScreen(){
        let vc = InviteCodeController()
        present(vc, presentationStyle: .fullScreen)
    }
}

// MARK: - Utility Methods
extension VerifyEmailController {
    func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.emailLabel.text = email
    }
    
    

    
    
    func validate() -> Bool {
        let pincodeValidated = txtPinCode.text.count == 4
        return pincodeValidated
    }
    
    func startTimer() {
        time = 300
        self.lblTimer.text = "0:\(self.time)"
//        self.btnResendCode.isEnabled = false
//        self.btnResendCode.alpha = 0.7
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.time -= 1
            self.lblTimer.text = "0:\(self.time)"
            
            if self.time <= 0 {
                self.lblTimer.text = "0:0"
                timer.invalidate()
//                self.btnResendCode.isEnabled = true
//                self.btnResendCode.alpha = 1
            }
            
        })
    }
}

extension VerifyEmailController
{
    @objc func keyboardWillShow(notification: NSNotification) {
       
        continueButtonBottomConstraint.constant = 310
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
       
        continueButtonBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
