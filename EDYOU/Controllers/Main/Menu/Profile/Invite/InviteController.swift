//
//  InviteController.swift
//  EDYOU
//
//  Created by imac3 on 18/04/2023.
//

import UIKit
import Contacts
import MessageUI


class InviteController: BaseController {
    
    @IBOutlet weak var inviteStatusLbl : UILabel!
    @IBOutlet weak var sendEmailBtn : UIButton!
    @IBOutlet weak var emailBGV : UIView!
    @IBOutlet weak var contactTblV : UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var searchStackViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var txtEmail: BorderedTextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contactTableViewBottom: NSLayoutConstraint!
//    @IBOutlet weak var emailTblV : UITableView!
//    @IBOutlet weak var emailTblVHeightConstraint: NSLayoutConstraint!
    
    var contacts : [CNContact] = []
    var adapter : ContactsAdapter!
    var emailAdapter : EmailAdapter!
    
    var currentRefferalCode : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupView()
    }
    
    func setupView(){
        adapter = ContactsAdapter(tableView: contactTblV)
//        emailAdapter = EmailAdapter(tableView: emailTblV)
//        txtEmail.textField.le
        txtEmail.textField.keyboardType = .emailAddress
        txtEmail.textField.autocorrectionType = .no
        txtEmail.validations = [.required, .email]
        txtEmail.borderWidth = 1.0
        txtEmail.borderColor = UIColor(hexString: "#F3F5F8")
        txtEmail.layoutSubviews()
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            contactTableViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            contactTableViewBottom.constant = 0
        }
    }
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        contactTblV.isHidden = sender.selectedSegmentIndex == 1
        emailBGV.isHidden = !contactTblV.isHidden
        
    }
    @IBAction func sendInviteByEmail(_ sender : UIButton){
        if txtEmail.validate() {
            view.endEditing(true)
            //sendEmail
            invitedByEmail(txtEmail.text!)
            
        } else {
            sendEmailBtn.shake()
        }
    }
}


extension InviteController {
    
    @IBAction func didTapClearButton(_ sender: Any) {
        view.endEditing(true)
        txtSearch.text = ""
        btnClear.isHidden = true
        searchStackViewTrailing.constant = 16
        view.layoutIfNeeded(true)
        search("")
    }
    @IBAction func searchIconTouched(_ sender: Any) {
        txtSearch.becomeFirstResponder()
    }
}
// MARK: - Utility Methods
extension InviteController {
    func search(_ text: String) {
        let t = text.lowercased().trimmed
        
        if t.count > 0 {
            let filtered = contacts.filter {
                $0.givenName.lowercased().contains(t) == true
            }
            adapter.contacts = filtered
            if segmentedControl.selectedSegmentIndex == 1 {
                segmentedControl.selectedSegmentIndex = 0
                onSegmentChange(segmentedControl)
            }
        } else {
            adapter.contacts = adapter.AllContacts
        }
        contactTblV.reloadData()
        
    }
}


// MARK: - TextField Delegate
extension InviteController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        btnClear.isHidden = false
        searchStackViewTrailing.constant = 0
        view.layoutIfNeeded(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.trimmed ?? "") == "" {
            textField.text = ""
            btnClear.isHidden = true
            searchStackViewTrailing.constant = 16
            view.layoutIfNeeded(true)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        search(expectedText)
        
        return true
        
    }
}


//MARK: - send invite by Email
extension InviteController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func sendEmail(_ email : String) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody(getMessage(), isHTML: true)

            present(mail, animated: true)
        } else {
            
            if let url = URL(string: "mailto:\(email)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            else{
                showErrorWith(message: "No email account set up on the device")
            }        }
    }
    
    func invitedByEmail(_ email : String){
        
        let parameters : [String: Any]  = [
          "invite_source_type": "email",
          "invite_address": "\(email)"
        ]
    
        APIManager.social.inviteUser(parameters) { invitedUser,error  in
            if error != nil {
                self.showErrorWith(message: error!.message)
            } else {
                self.currentRefferalCode = invitedUser?.referralCode ?? ""
                print("invited user referal code: \(invitedUser?.referralCode)")
                self.sendEmail(email)
                self.refreshInvitedUserList()
            }
        }
    }
    private func refreshInvitedUserList(){
        self.adapter?.getInvitedUser()
        self.emailAdapter?.getInvitedUser()
        
    }
    
}


//MARK: - send invite by SMS
extension InviteController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .sent{
            //message sent successfully change status from pending to sent
            let parameters : [String: String]  = [
              "invite_status": "sent",
              "referral_code": currentRefferalCode
            ]
            APIManager.social.updateInviteStatus(parameters, completion: { error in
                self.refreshInvitedUserList()
            })
        }
        else{
            //message not sent
        }
        controller.dismiss(animated: true)
    }
    
    
    func sendSMS(_ phone : String,_ name : String = "") {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = getMessage(name)
            controller.recipients = [phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
        else {
            // show failure alert
            showErrorWith(message: "No SMS account set up on the device")
        }
    }
    private func getMessage(_ name : String = "")->String{
        if name.isEmpty{
            return "Hey Exciting news! I'm on edyou, the ultimate platform for college influencers.\nJoin me and let's become America's top college influencer together! Download the app now and let the journey begin\n\n \nhttps://edyouapp.com"
        }
        return "Hey \(name)! Exciting news! I'm on edyou, the ultimate platform for college influencers.\nJoin me and let's become America's top college influencer together! Download the app now and let the journey begin\n\n \nhttps://edyouapp.com"
    }
    
    
    
    
    func invitedBySMS(_ number : String, _ name  : String = ""){
        
        let parameters : [String: Any]  = [
          "invite_source_type": "sms",
          "invite_address": "\(number)"
        ]
    
        APIManager.social.inviteUser(parameters) { invitedUser,error in
            if error != nil {
                self.showErrorWith(message: error!.message)
            } else {
//                print("invited user referal code: \(invitedUser?.referralCode)")
                self.currentRefferalCode = invitedUser?.referralCode ?? ""
                self.refreshInvitedUserList()
                self.sendSMS(number,name)

            }
        }
    }
}

