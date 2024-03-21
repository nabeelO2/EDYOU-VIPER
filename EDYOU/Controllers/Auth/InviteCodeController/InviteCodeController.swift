//
//  InviteController.swift
//  EDYOU
//
//  Created by imac3 on 15/05/2023.
//

import UIKit
import PanModal
import TransitionButton

class InviteCodeController: BaseController {

    @IBOutlet weak var inviteCodeTxtF: BorderedTextField!{
        didSet
        {
            inviteCodeTxtF.leftSeparatorView.isHidden = true
            inviteCodeTxtF.placeHolderLeadingConstraint.constant = 16
            
        }
    }
    @IBOutlet weak var btnSubmit : TransitionButton!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var ImgVBack : UIImageView!
    
    var hideBackButton = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        inviteCodeTxtF.validations = [.required]
        inviteCodeTxtF.textField.delegate = self
        btnBack.isHidden = hideBackButton
        ImgVBack.isHidden = hideBackButton
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if let copiedSomething = UIPasteboard.general.string{
                self.processInviteLink(copiedSomething)
            }
        }
    }
    
    private func processInviteLink(_ urlStr : String){
        let invitationCodeArr = urlStr.components(separatedBy: "invitationcode=")
        if invitationCodeArr.count > 1 {
            let invitationCode = invitationCodeArr[invitationCodeArr.count-1]
          //  UserDefaults.standard.set(invitationCode, forKey: "invitationCode")
            print("move to signup with invitation Code \(invitationCode)")
            self.inviteCodeTxtF.text = invitationCode
        }
        else{
            self.showErrorWith(message: "We're sorry, but the invitation code you entered is not valid. Please ensure that you have copied the code accurately from the sms/email you received.")
        }
    }

    
    func validate() -> Bool {
        
        return inviteCodeTxtF.validate()
       
    }
    
    
    @IBAction func submitAction(_ sender : UIButton){
        if validate(){
            //change status of invite code
            let validated  = validate()
            if validated {
                
                view.endEditing(true)
                btnSubmit.startAnimation()
                self.changeInvitationStatus()
                
            } else {
                btnSubmit.shake()
            }
        }
    }
    @IBAction func logoutAction(_ sender : UIButton){
        UserDefaults.standard.set(nil, forKey: "isEmailVerified")
//        UserDefaults.standard.set(nil, forKey: "isEmailVerified")
//        Application.shared.switchToLogin()
        APIManager.auth.logout { response, error in
            XMPPAppDelegateManager.shared.logoutFromXMPP()
            Keychain.shared.clear()
            RealmContextManager.shared.clearRealmDB()
            Cache.shared.clear()
            UIApplication.shared.unregisterForRemoteNotifications()
            Application.shared.switchToLogin()
        }
    }
    
        
       
    func changeInvitationStatus(){
//            if let code = UserDefaults.standard.string(forKey: "invitationCode"){
                let parameters : [String: Any]  = [
                  "invite_status": "completed",
                  "referral_code": "\(inviteCodeTxtF.text!)",
                  "is_invited_user" : true
                ]
            
                APIManager.social.updateInviteStatus(parameters, completion: { error in
                    //self.getInvitedUser()
                    self.btnSubmit.stopAnimation()
                    if error != nil {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            self.btnSubmit.shake()
                            self.showErrorWith(message: error!.message)
                        }
                        
                    }
                    else{
                        UserDefaults.standard.set(self.inviteCodeTxtF.text!, forKey: "invitationCode")
                        
                        UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
                        UserDefaults.standard.synchronize()
                        Application.shared.switchToHome()
                        
//                        let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
//                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    
                })
//            }
//            else{
//                print("invitation code not found")
//            }
            
        }

}

//extension InviteCodeController : PanModalPresentable {
//    
//    var panScrollable: UIScrollView? {
//        return nil
//    }
//    
//    var showDragIndicator: Bool {
//        return false
//    }
//    
//    var shouldRoundTopCorners: Bool {
//        return false
//    }
//    
//    var shortFormHeight: PanModalHeight {
//        return .contentHeight(300)
//    }
//    
//    var longFormHeight: PanModalHeight {
//        return .contentHeight(300)
//    }
//}


extension InviteCodeController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
            
            let updatedText = (text as NSString).replacingCharacters(in: range, with: string).uppercased()
            textField.text = updatedText
            
            return false
    }
}

