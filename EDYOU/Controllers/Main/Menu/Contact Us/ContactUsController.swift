//
//  ContactUsController.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//

import UIKit
import TransitionButton

class ContactUsController: BaseController, UITextFieldDelegate {
    
    @IBOutlet weak var submitButton: TransitionButton!
    @IBOutlet weak var detailMessage: UITextView!

    @IBOutlet weak var subjectTextfield: BorderedTextField!{
        didSet
        {
            nameTextfield.leftSeparatorView.isHidden = true
            nameTextfield.placeHolderLeadingConstraint.constant = 0
            
        }
    }
    @IBOutlet weak var nameTextfield:  BorderedTextField!{
        didSet
        {
            nameTextfield.leftSeparatorView.isHidden = true
            nameTextfield.placeHolderLeadingConstraint.constant = 0
            
        }
    }
    
    @IBOutlet weak var emailTextfield: BorderedTextField!{
        didSet
        {
            emailTextfield.leftSeparatorView.isHidden = true
            emailTextfield.placeHolderLeadingConstraint.constant = 0
            emailTextfield.textField.keyboardType = .emailAddress
        }
    }
    
    @IBOutlet weak var phoneTextfield: BorderedTextField!{
        didSet
        {
            nameTextfield.leftSeparatorView.isHidden = true
            nameTextfield.leftSeparatorView.backgroundColor = .white
            nameTextfield.placeHolderLeadingConstraint.constant = 0
            
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedSubject : String = ""

    var adapter: ContactUsAdapter!
    public var validations = [Validation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = ContactUsAdapter(collectionView: collectionView)
        setupUI()
    }
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonTouched(_ sender: Any)
    {
        if validate()
        {
            submitContactUs()
        }
        else
        {
            submitButton.shake()
        }
    }
    
    func validate() -> Bool {
        let nameValidated = nameTextfield.validate()
        let emailValidated = emailTextfield.validate()
        let phoneValidated = phoneTextfield.validate()
        let subjectValidated = subjectTextfield.validate()
        let suffix = emailTextfield.text?.components(separatedBy: "@").last ?? ""
        
        if emailValidated && validateEmail() && phoneValidated && subjectValidated && nameValidated && validateMessage()
        {
            return true
        } else
        {
            if nameValidated == false
            {
                showErrorWith(message: "Please enter your full name")
            }
            else
            if emailValidated == false
            {
                showErrorWith(message: "Please enter a valid Email Address")
            }
            else
            if phoneValidated == false
            {
                showErrorWith(message: "Please enter your phone number")
            }
            else
            if subjectValidated == false
            {
                showErrorWith(message: "Please select subject")
            }
            
            else
            if validateMessage() == false
            {
                showErrorWith(message: "Please enter detail message")
            }
           
            return false
        }
        
        
    }
    
    func validateEmail() -> Bool {
        let emailValidated = emailTextfield.validate()
        let suffix = emailTextfield.text?.components(separatedBy: "@").last ?? ""
        if suffix.contains("yopmail.com") {
            emailTextfield.setError("Invalid institute email")
            return false
        }
        return emailValidated
    }
    
    func validateMessage() -> Bool {
        
        if detailMessage.text.isStringEmpty() {
            return false
        }
        return true
    }
  
    
    
   @IBAction func showSubjectSheet() {
        let genderPicker = ReusbaleOptionSelectionController(options:  ["Suspended Account", "Account Access Issue", "Account Privacy Issue", "Copyright Content", "Other Support"], previouslySelectedOption: self.selectedSubject, screenName: "Select Subject", completion: { selected in
            self.selectedSubject = selected
            self.subjectTextfield.text = selected
        })
        
        self.presentPanModal(genderPicker)
    }
    
    //MARK: -  SetupUI
    func setupUI()
    {
        nameTextfield.validations = [.required]
        phoneTextfield.validations = [.required, .phone]
        emailTextfield.validations = [.required, .email]
        subjectTextfield.validations = [.required ]

        nameTextfield.textField.delegate = self
        emailTextfield.textField.delegate = self
        phoneTextfield.textField.delegate = self
        subjectTextfield.textField.delegate = self

        
    }
    
    // MARK: -  Others
    func getSubject() -> String
    {
        switch subjectTextfield.text {
        case "Suspended Account":
            return "suspended_account"
        case "Account Access Issue":
            return "account_access_issue"
        case "Account Privacy Issue":
            return "account_privacy_issue"
        case "Copyright Content":
            return "copyright_content"
        case "Other Support":
            return "other_support"
        default:
            return "suspended_account"

        }
        
    }
    
}

extension ContactUsController {
    func submitContactUs()
    {
        submitButton.startAnimation()
        guard let  userId = Cache.shared.user?.userID else {
            return
        }
        let params = [
            "email": String(format:"%@",emailTextfield.text!),
            "phone": String(format:"%@",phoneTextfield.text!),
            "name": String(format:"%@",nameTextfield.text!),
            "subject": String(format:"%@",getSubject()),
            "detail" : String(format:"%@",detailMessage.text!),
            "user_id" : userId
//            "school_id": String(format:"%@",selectedUniversityID),
//            "state": String(format:"%@",selectedState)
        ] as [String : Any]
        APIManager.auth.contactUS(parameters: params) { error in
            self.submitButton.stopAnimation()
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showErrorWith(message: error?.message ?? "Invalid response")
            }
        }

    }
}
