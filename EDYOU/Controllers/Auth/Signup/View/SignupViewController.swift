//
//  SignupViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 15/10/2022.
//

import UIKit
import TransitionButton

class SignupViewController: BaseController, UITextFieldDelegate {

    //MARK: -  Outlets
    
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
//    var adapter: PickerViewAdapter!
    var universities: [DataPickerItem<Institute>] = []
    
    
//    var selectedSchool : School?
//    var selectedState : String = ""
//    var selectedGender : String = ""
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()

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
    
    //MARK: -  Selector Methods

    @IBAction func selectStates(_ sender: UIButton) {
        
        presenter.selectState()
    }
    
    @IBAction func selectUniversityButtonTouched(_ sender: Any) {
        presenter.selectUniviersity()
    }
    
    @IBAction func selectGenderButtonTouched(_ sender: Any)
    {
        presenter.selectGender()
    }
    @IBAction func signInButtonTouched(_ sender: Any)
    {
        presenter.navigateToSignIn()
    }
    
    @IBAction func showPasswordButtonTouched(_ sender: Any)
    {
        presenter.changePasswordVisibility(passwordTextfield.textField.isSecureTextEntry)
      
    }
    @IBAction func signupButtonTouched(_ sender: Any)
    {
        presenter.register()

    }
    
    @IBAction func policyCheckButtonTouched(_ sender: Any) {
        presenter.navigateToPrivacy()
    }
    
    
    @IBAction func privacyPolicyButtonTouched(_ sender: Any) {
        presenter.navigateToPrivacy()
        
    }
    
    @IBAction func termsAndConditionsButtonTouched(_ sender: Any) {
        presenter.navigateToPrivacy()
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
        signupButton.shake()
    }
    
    func showErrorMessage(_ message: String) {
        self.showErrorWith(message: message)
    }
    
    func startAnimating() {
        signupButton.startAnimation()
    }
    
    func stopAnimating() {
        signupButton.stopAnimation()
    }
    
    func prepareUI() {
        setupUI()
    }
    
    
    func passwordBtnVisibility(_ isSecured: Bool) {
        passwordTextfield.textField.isSecureTextEntry = isSecured
    }
    
    func setGender(_ gender: String) {
        self.genderTextfield.text = gender
    }
    func presentPicker(_ option: ReusbaleOptionSelectionController) {
        self.presentPanModal(option)
    }
    func setUniversity(_ university: String) {
        self.universityTextfield.text = university
    }
    func emailVisibility(_ isHidden: Bool) {
        self.emailTextfield.isHidden = isHidden
        if !isHidden{
            self.emailTextfield.textField.becomeFirstResponder()
        }
        
    }
    func setState(_ state: String) {
        self.statesTextField.text = state
    }
    func startUniversityLoading() {
        self.universityTextfield.startLoading()
    }
    func stopUniversityLoading() {
        self.universityTextfield.stopLoading()
    }
    func setUniveristyInteraction(_ result: Bool) {
        self.universityTextfield.isUserInteractionEnabled = result
    }
    func presentScreen(_ controller : Any, _ withAnimation: Bool) {
            
        self.present(controller as! UIViewController, presentationStyle: .overCurrentContext)
  
    }
    func emailValidated() -> Bool {
        return emailTextfield.validate()
    }
    func genderValidated()->Bool{
        return genderTextfield.validate()
    }
    func nameValidated()->Bool{
        return firstNameTextfield.validate()
    }
    func lastNameValidated()->Bool{
        return lastNameTextfield.validate()
    }
    func universityValidated()->Bool{
        return universityTextfield.validate()
    }
    func statesValidated()->Bool{
        return statesTextField.validate()
    }
    func getPassword() -> String {
        return passwordTextfield.text ?? ""
    }
    func getEmail() -> String {
        return emailTextfield.text ?? ""
    }
    func getFName() -> String {
        return firstNameTextfield.text ?? ""
    }
    
    func setErrorToLname(_ error: String) {
        lastNameTextfield.setError(error)
    }
    func setErrorToFname(_ error: String) {
        firstNameTextfield.setError(error)
    }
    func getGenderText() -> String {
        return genderTextfield.text ?? ""
    }
    func setErrorToEmail(_ error: String) {
        emailTextfield.setError(error)
    }
    func changePrivacyButtonImage(with name: String) {
        self.policyButton.setImage( UIImage(named: name) , for: .normal)
        
    }
    func changeShowPasswordBtnImage(with name: String) {
        showPasswordButton.setImage(UIImage(named: name), for: .normal)
    }
}


