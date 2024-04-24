//
//  SignupViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 15/10/2022.
//

import UIKit
import TransitionButton

class SignupViewController: BaseController, UITextFieldDelegate {

    //MARK: -  Textfields Outlets
    
    @IBOutlet weak var firstNameTextfield: BorderedTextField!
       
    @IBOutlet weak var lastNameTextfield: BorderedTextField!
    @IBOutlet weak var universityTextfield: BorderedTextField!
    @IBOutlet weak var statesTextField: BorderedTextField!
    @IBOutlet weak var emailTextfield: BorderedTextField!
    @IBOutlet weak var passwordTextfield: BorderedTextField!
    @IBOutlet weak var genderTextfield: BorderedTextField!
       
    
    
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var signupButton: TransitionButton!
    @IBOutlet weak var policyButton: UIButton!
    @IBOutlet var passwordStrengthViews: [UIView]!
   
    
    
    var presenter: SignupPresenterProtocol!
    var adapter: PickerViewAdapter!
    var universities: [DataPickerItem<Institute>] = []
    var states: [DataPickerItem<String>] = []
    var schools: [DataPickerItem<School>] = []
    var selectedSchool : School?
    var selectedState : String = ""
    var selectedGender : String = ""
    var isPolicySelected : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
//        setupUI()
////        getInstitutes()
//        getStates()
     
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: -  SetupUI
    
    func setupUI()
    {
        emailTextfield.isHidden = true
        genderTextfield.leftSeparatorView.isHidden = true
        genderTextfield.placeHolderLeadingConstraint.constant = 0
        passwordTextfield.leftSeparatorView.isHidden = true
        passwordTextfield.leftIconLeftPadding = 12
        passwordTextfield.placeHolderLeadingConstraint.constant = 0
        passwordTextfield.textField.isSecureTextEntry = true
        emailTextfield.leftSeparatorView.isHidden = true
        emailTextfield.placeHolderLeadingConstraint.constant = 0
        emailTextfield.textField.keyboardType = .emailAddress
        statesTextField.leftSeparatorView.isHidden = true
        statesTextField.placeHolderLeadingConstraint.constant = 0
        universityTextfield.leftSeparatorView.isHidden = true
        universityTextfield.placeHolderLeadingConstraint.constant = 0
        firstNameTextfield.leftSeparatorView.isHidden = true
        firstNameTextfield.placeHolderLeadingConstraint.constant = 0
        lastNameTextfield.leftSeparatorView.isHidden = true
        lastNameTextfield.placeHolderLeadingConstraint.constant = 0
        firstNameTextfield.validations = [.required]
        lastNameTextfield.validations = [.required]
        universityTextfield.validations = [.required]
        statesTextField.validations = [.required]
        emailTextfield.validations = [.required, .email]
        passwordTextfield.validations = [.required]
        genderTextfield.validations = [.required]
        passwordTextfield.validations = [.required]
        passwordTextfield.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        firstNameTextfield.textField.delegate = self
        lastNameTextfield.textField.delegate = self

        passwordTextfield.textField.delegate = self
        emailTextfield.textField.delegate = self
      
        for view in passwordStrengthViews
        {
            view.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        }
       
        
    }
    
    func updatePasswordStrengthViews(strength: Int)
    {
        for view in passwordStrengthViews
        {
            view.backgroundColor = UIColor(red: 0.946, green: 0.946, blue: 0.946, alpha: 1)
        }
        
        if strength > -1
        {
            for number in 0...strength
            {
                passwordStrengthViews[number].backgroundColor = R.color.edYouGreen()
            }
        }
       
    }

    
    // MARK: -  Others
    func getGender() -> String
    {
        if genderTextfield.text == "Another gender identity"
        {
            return "another_gender_identity"
        }
        else
        if genderTextfield.text == "Prefer not to say"
        {
            return "prefer_not_to_say"
        }
        else
        {
            return genderTextfield.text?.lowercased() ?? "male"
        }
    }
    func validate() -> Bool {
        
        let emailValidated = emailTextfield.validate()
        let genderValidated = genderTextfield.validate()
        let nameValidated = firstNameTextfield.validate()
        let lastNameValidated = lastNameTextfield.validate()
        let universityValidated = universityTextfield.validate()
        let statesValidated = statesTextField.validate()
    
        
        if emailValidated && validateEmail() && genderValidated && nameValidated && lastNameValidated && universityValidated
        {
            let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
            let isMatched = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: passwordTextfield.text)
            if(isMatched  == true) {
               
                if isPolicySelected == false
                {
                    showErrorWith(message: "Please accept our Terms and Condition and Privacy Policy")
                    return false
                }
               else
                {
                   return true
                }
             
            }  else {
                showErrorWith(message: "Your password must be at least 8 characters long, a special character, contain at least one number and have a mixture of uppercase and lowercase letters.")
                return false
            }
            
        }
        else
        {
            if nameValidated == false
            {
                firstNameTextfield.setError("Please enter valid first name")

            }
            else  if lastNameValidated == false
            {
                lastNameTextfield.setError("Please enter valid last name")

            }
            else
            if universityValidated == false
            {
                //showErrorWith(message: "Please select your university")
            }
            else
            if emailValidated == false
            {
               // showErrorWith(message: "Please enter a valid Email Address")
            }
            else
            if validateEmail()  == false
            {
                
            }
            else
            if genderValidated == false
            {
               // showErrorWith(message: "Please select your gender")
            }
            else
            if statesValidated == false
            {
               // showErrorWith(message: "Please select your gender")
            }
          
            return false
        }
       
    }
    
   
    func validateEmail() -> Bool {
        let emailValidated = emailTextfield.validate()
        guard let emailSuffix = selectedSchool?.emailSuffix else {
            emailTextfield.setError("School not selected")
            return false
        }
        let suffix = emailTextfield.text?.components(separatedBy: "@").last ?? ""
        if suffix.contains("yopmail.com") {
            emailTextfield.setError("Invalid institute email")
            return false
        }
//        aamu.edu
        if (emailValidated && !suffix.contains(emailSuffix)) {
            emailTextfield.setError("Invalid institute email")
            return false
        }
        
        return emailValidated
    }
    
    func validateCompleteName() -> Bool {
         let completeName = firstNameTextfield.text ?? ""
        let trimmedCompleteName = completeName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedCompleteName.containsWhitespace {
            return true
        }
        
        return false
    }
    
    //MARK: -  Selector Methods

    @IBAction func selectStates(_ sender: UIButton) {
        let controller = DataPickerController(title: "Choose States", data: states, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.selectedState = selectedItem.title
            self.statesTextField.text = selectedItem.title
            self.selectedSchool = nil
            self.universityTextfield.text = ""
            self.getSchools()
        }
        controller.showFullScreen = true
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectUniversityButtonTouched(_ sender: Any) {
        if self.selectedState.isEmpty {
            self.showErrorWith(message: "Please select state first")
            return
        }
        if self.schools.count == 0 {
            return
        }
        
        let controller = DataPickerController(title: "Schools in \(self.selectedState)", data: schools, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.selectedSchool = selectedItem.data
            self.universityTextfield.text = selectedItem.title
            UserDefaults.standard.set(self.universityTextfield.text, forKey: "SelectedUni")
            UserDefaults.standard.synchronize()
            self.emailTextfield.isHidden = false
            self.emailTextfield.textField.becomeFirstResponder()
        }
        controller.showFullScreen = true
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectGenderButtonTouched(_ sender: Any)
    {
        let genderPicker = ReusbaleOptionSelectionController(options:  ["Male", "Female", "Another gender identity", "Prefer not to say"], previouslySelectedOption: self.selectedGender, screenName: "Select Gender", completion: { selected in
            
            self.selectedGender = selected
            self.genderTextfield.text = selected
            
        })
        
        self.presentPanModal(genderPicker)
    }
    @IBAction func signInButtonTouched(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPasswordButtonTouched(_ sender: Any)
    {
        passwordTextfield.textField.isSecureTextEntry = !passwordTextfield.textField.isSecureTextEntry
        
        showPasswordButton.setImage(passwordTextfield.textField.isSecureTextEntry ? UIImage(named: "showPasswordOff") : UIImage(named: "showPasswordOff"), for: .normal)
      
    }
    @IBAction func signupButtonTouched(_ sender: Any)
    {
        
        if validate()
        {
            signUp()
        }
        else
        {
            signupButton.shake()
        }
    }
    
    @IBAction func policyCheckButtonTouched(_ sender: Any) {
     
        let controller = PrivacyPolicyController(completion: {isAccept in
            self.isPolicySelected = isAccept
            self.policyButton.setImage(self.isPolicySelected ? UIImage(named: "selectedCheck") : UIImage(named: "unselectedCheck"), for: .normal)
        })
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    
    }
    
    
    @IBAction func privacyPolicyButtonTouched(_ sender: Any) {
        
        let controller = PrivacyPolicyController(completion: {isAccept in
            self.isPolicySelected = isAccept
            self.policyButton.setImage(self.isPolicySelected ? UIImage(named: "selectedCheck") : UIImage(named: "unselectedCheck"), for: .normal)
        })
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func termsAndConditionsButtonTouched(_ sender: Any) {
        let controller = PrivacyPolicyController(completion: {isAccept in
            self.isPolicySelected = isAccept
            self.policyButton.setImage(self.isPolicySelected ? UIImage(named: "selectedCheck") : UIImage(named: "unselectedCheck"), for: .normal)
        })
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func getInviteCode()->String?{
        if let code = UserDefaults.standard.string(forKey: "invitationCode"), code.count > 6{
            return code
        }
        return nil
    }
}


//MARK: - API Methods

extension SignupViewController {
    func signUp()
    {
        signupButton.startAnimation()
        
        var params : [String : Any] = [:]
        
        if let code = getInviteCode(){
            params = [
               "email": String(format:"%@",emailTextfield.text!),
               "password": String(format:"%@",passwordTextfield.text!),
               "first_name": String(format:"%@",firstNameTextfield.text!),
               "last_name": String(format:"%@",lastNameTextfield.text!),
               "gender": String(format:"%@",getGender()),
               "is_dev" : true,
               "invite_code" : code
   //            "school_id": String(format:"%@",selectedUniversityID),
   //            "state": String(format:"%@",selectedState)
           ] as [String : Any]
        }
        else{
            params = [
               "email": String(format:"%@",emailTextfield.text!),
               "password": String(format:"%@",passwordTextfield.text!),
               "first_name": String(format:"%@",firstNameTextfield.text!),
               "last_name": String(format:"%@",lastNameTextfield.text!),
               "gender": String(format:"%@",getGender()),
               "is_dev" : true
   //            "school_id": String(format:"%@",selectedUniversityID),
   //            "state": String(format:"%@",selectedState)
           ]
        }
        
         
        APIManager.auth.signup(parameters: params) { [weak self] oneTimeToken, error in
            guard let self = self else { return }
            self.signupButton.stopAnimation()
            
            if error == nil {
                let controller = VerifyEmailController(email: self.emailTextfield.text ?? "")
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error?.message ?? "Invalid response")
            }
            
        }
    }
    
    func getSchools() {
        universityTextfield.startLoading()
        universityTextfield.isUserInteractionEnabled = false
        APIManager.auth.getSchools(state: self.selectedState) { schools, error in
            self.universityTextfield.stopLoading()
            self.universityTextfield.isUserInteractionEnabled = false
            if let e = error {
                self.showErrorWith(message: e.message)
            } else {
                self.schools = (schools ?? []).dataPickerItems()
            }
        }
    }
    
    func getStates() {
        
    }
}

//MARK: -  Textfield Delegates
extension SignupViewController
{
    
    func validatePasswordStrength(password: String) -> Int
    {
        var currentStrength = -1
      
        // Check of aleast 8 Characters
        if password.count > 7
        {
            currentStrength = currentStrength + 1
            
        }
        
        // Check for Captial and small Letters
        let capitalSmallLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalSmallLetterRegEx)
        if texttest.evaluate(with: password)
        {
            let texttestSmallLetter = NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*" )
            if texttestSmallLetter.evaluate(with: password)
            {
                currentStrength = currentStrength + 1
            }
          
        }
          
        // Check for Digit
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        if texttest1.evaluate(with: password)
        {
            currentStrength = currentStrength + 1
        }
        
        // Check for Special Character
        let specialCharacterRegEx  = ".*[!&^%$#@()/_*+-]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        if texttest2.evaluate(with: password)
        {
            currentStrength = currentStrength + 1
        }

       return currentStrength
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        updatePasswordStrengthViews(strength: validatePasswordStrength(password: passwordTextfield.textField.text ?? ""))
    }
}

extension SignupViewController : SignupViewProtocol{
    func setStates(_ statesList: [DataPickerItem<String>]) {
//        self.se
    }
    func setStatesUserInteraction(_ result: Bool) {
        statesTextField.isUserInteractionEnabled = result
    }
    func stopStatesLoading() {
        statesTextField.stopLoading()
    }
    func startStatesLoading() {
        statesTextField.startLoading()
    }
    func shakeSignupButton() {
        
    }
    
    func showErrorMessage(_ message: String) {
        
    }
    
    func startAnimating() {
        
    }
    
    func stopAnimating() {
        
    }
    
    func prepareUI() {
        setupUI()
    }
    
    func shakeLoginButton() {
        
    }
    
    func showHidePassword() {
        
    }
    
    func passwordBtnVisibility(_ isHidden: Bool) {
        
    }
    
    
}
