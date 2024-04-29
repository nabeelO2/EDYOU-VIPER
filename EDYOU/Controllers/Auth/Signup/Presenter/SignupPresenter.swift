//
//  SignupPresenter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation
//import PanModal

protocol SignupPresenterProtocol: AnyObject {//input
    func viewDidLoad()
    func navigateToPrivacy()
    func navigateToSignIn()
    func register()
    func selectGender()
    func selectUniviersity()
    func selectState()
    func changePasswordVisibility(_ isSecuredSelected : Bool)
}

class SignupPresenter {
    weak var view: SignupViewProtocol?
    private let interactor: SignupInteractorProtocol
    private let router: SignupRouter
//    private(set) var SignupResult: [SignupResultData] = []
    private var selectedGender = ""
    private var selectedState = ""
    private var selectedSchool : School?
    var schools: [DataPickerItem<School>] = []
    var states: [DataPickerItem<String>] = []
    var isPolicySelected : Bool = false
    init(view: SignupViewProtocol, router: SignupRouter, interactor : SignupInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func validate() -> Bool {
        
        let emailValidated = view?.emailValidated() ?? false
        let genderValidated = view?.genderValidated() ?? false
        let nameValidated = view?.nameValidated() ?? false
        let lastNameValidated = view?.lastNameValidated() ?? false
        let universityValidated = view?.universityValidated() ?? false
        let statesValidated = view?.statesValidated() ?? false
    
        let password = view?.getPassword() ?? ""
        if emailValidated && validateEmail() && genderValidated && nameValidated && lastNameValidated && universityValidated
        {
            let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
            let isMatched = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: password)
            if(isMatched  == true) {
               
                if isPolicySelected == false
                {
                    view?.showErrorMessage("Please accept our Terms and Condition and Privacy Policy")
                    
                    return false
                }
               else
                {
                   return true
                }
             
            }  else {
                view?.showErrorMessage("Your password must be at least 8 characters long, a special character, contain at least one number and have a mixture of uppercase and lowercase letters.")
                return false
            }
            
        }
        else
        {
            if nameValidated == false
            {
                 view?.setErrorToFname("Please enter valid first name")
            }
            else  if lastNameValidated == false
            {
                view?.setErrorToLname("Please enter valid last name")
                
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
       
        let emailValidated = view?.emailValidated() ?? false
        guard let emailSuffix = selectedSchool?.emailSuffix else {
            view?.setErrorToEmail("School not selected")
            return false
        }
        let suffix = view?.getEmail().components(separatedBy: "@").last ?? ""
        if suffix.contains("yopmail.com") {
            view?.setErrorToEmail("Invalid institute email")
            return false
        }
//        aamu.edu
        if (emailValidated && !suffix.contains(emailSuffix)) {
            view?.setErrorToEmail("Invalid institute email")
            return false
        }

        return emailValidated
    }
    
    func validateCompleteName() -> Bool {
        let completeName = view?.getFName() ?? ""
        let trimmedCompleteName = completeName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedCompleteName.containsWhitespace {
            return true
        }
        
        return false
    }

}


extension SignupPresenter : SignupPresenterProtocol {
    
    func changePasswordVisibility(_ isSecuredSelected: Bool) {
        view?.passwordBtnVisibility(!isSecuredSelected)
        view?.changeShowPasswordBtnImage(with: !isSecuredSelected ?  "showPasswordOff" : "showPasswordOff")
    }
    
    
    func navigateToSignIn() {
        router.navigateToSignIn()
    }
    
    func navigateToPrivacy() {
        
        let controller = PrivacyPolicyController(completion: {isAccept in
            self.isPolicySelected = isAccept
            self.view?.changePrivacyButtonImage(with: self.isPolicySelected ?  "selectedCheck" :  "unselectedCheck")
        })
        controller.modalPresentationStyle = .fullScreen
        view?.presentScreen(controller, true)
    }
    
    
    func register() {
        if validate()
        {
//            interactor
            signUp()
        }
        else
        {
            view?.shakeSignupButton()
        }
    }
    
    func viewDidLoad() {
        getStates()
        view?.prepareUI()
    }
    func getStates(){
        let states = Cache.shared.states.stringToDatePickerItem()
        if states.count == 0 {
            view?.startStatesLoading()
            view?.setStatesUserInteraction(false)
        }
        interactor.getStatesList()
    }
    func selectGender() {
        let genderPicker = ReusbaleOptionSelectionController(options:  ["Male", "Female", "Another gender identity", "Prefer not to say"], previouslySelectedOption: self.selectedGender, screenName: "Select Gender", completion: { selected in
            
            self.selectedGender = selected
            self.view?.setGender(selected)
            
        })
        
        self.view?.presentPicker(genderPicker)
    }
    
    func selectUniviersity() {
        if self.selectedState.isEmpty {
            view?.showErrorMessage("Please select state first")
            return
        }
        if self.schools.count == 0 {
            return
        }
        
        let controller = DataPickerController(title: "Schools in \(self.selectedState)", data: schools, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.selectedSchool = selectedItem.data
            self.view?.setUniversity(selectedItem.title)
            UserDefaults.standard.set(selectedItem.title, forKey: "SelectedUni")
            UserDefaults.standard.synchronize()
            self.view?.emailVisibility(false)
            
        }
        controller.showFullScreen = true
        view?.presentScreen(controller, true)
        
    }
    func selectState() {
        
        let controller = DataPickerController(title: "Choose States", data: states, singleSelection: true) { [weak self] selectedItems in
            guard let selectedItem = selectedItems.first, let self = self else { return }
            self.selectedState = selectedItem.title
            self.view?.setState(selectedItem.title)
            self.selectedSchool = nil
            self.view?.setUniversity("")
            self.getSchools()
        }
        controller.showFullScreen = true
        view?.presentScreen(controller, true)
        
    }
    
    func getSchools() {
        view?.startUniversityLoading()
        view?.setUniveristyInteraction(false)
//        universityTextfield.isUserInteractionEnabled = false
        interactor.getSchoolList(of: selectedState)
        
    }
    func getGender() -> String
    {
        guard let gender = view?.getGenderText() else { return "male" }
        if gender == "Another gender identity"
        {
            return "another_gender_identity"
        }
        else if gender == "Prefer not to say"
        {
            return "prefer_not_to_say"
        }
        else
        {
            return gender.lowercased()
        }
    }
    
    func signUp()
    {
        view?.startAnimating()
        
        var params : [String : Any] = [:]
        params = [
            "email": String(format:"%@",view!.getEmail()),
           "password": String(format:"%@",view!.getPassword()),
           "first_name": String(format:"%@",view!.getFName()),
           "last_name": String(format:"%@",view!.getEmail()),
           "gender": String(format:"%@",getGender()),
           "is_dev" : true
       ]
        
        if let code = getInviteCode(){
            params["invite_code"] = code
           
        }
        interactor.register(params)
    }
    func getInviteCode()->String?{
        if let code = UserDefaults.standard.string(forKey: "invitationCode"), code.count > 6{
            return code
        }
        return nil
    }
}

extension SignupPresenter : SignupInteractorOutput{
    
    func schoolList(schools list: [School]) {
        view?.stopUniversityLoading()
        view?.setUniveristyInteraction(false)
        self.schools = list.dataPickerItems()
    }
    func statesList(states list: [String]) {
        let states = list.stringToDatePickerItem()
        self.states = states
        view?.stopStatesLoading()
        view?.setStatesUserInteraction(true)
    }
    func error(error message: String) {
        view?.stopAnimating()
        view?.shakeSignupButton()
        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
        //navigate to verify email
        view?.stopAnimating()
        router.navigateToVerifyEmail(view?.getEmail())
        
    }
    func userInformation(response user: User) {
        view?.stopAnimating()
        
        if let id = user.userID, let pass  = Keychain.shared.accessToken {
            XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io" , pass: pass)
        }
        if user.major_start_year?.isEmpty == true || user.major_end_year?.isEmpty == true{
            UserDefaults.standard.setValue(false, forKey: "isUserAddedMajor")
            UserDefaults.standard.synchronize()
            //move to add major Screen
            router.navigateToAddMajor()
//            let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
//            self.navigationController?.pushViewController(controller, animated: true)
//            return
        }
        
        let university = user.education.first ?? Education.nilProperties
        if user.name?.firstName?.isEmpty == false || user.name?.lastName?.isEmpty == false {
//            Application.shared.switchToHome()
//            move to home Screen
        } else {
//            move to name controller
            
//            let controller = AddNameController(university: university)
//            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
}
    


protocol SignupViewProtocol: AnyObject {//output
    func prepareUI()
    func shakeSignupButton()
    func passwordBtnVisibility(_ isSecured : Bool)
    func showErrorMessage(_ message : String)
    func startAnimating()
    func stopAnimating()
    func startStatesLoading()
    func stopStatesLoading()
    func setStatesUserInteraction(_ result : Bool)
    func setState(_ state : String)
    func setGender(_ gender : String)
    func presentPicker(_ option : ReusbaleOptionSelectionController)
    func setUniversity(_ university : String)
    func emailVisibility(_ isHidden : Bool)
    func startUniversityLoading()
    func stopUniversityLoading()
    func setUniveristyInteraction(_ result : Bool)
    func presentScreen(_ controller : Any, _ withAnimation: Bool)
    func emailValidated()->Bool
    func genderValidated()->Bool
    func nameValidated()->Bool
    func lastNameValidated()->Bool
    func universityValidated()->Bool
    func statesValidated()->Bool
    func setErrorToEmail(_ error : String)
    func getPassword()->String
    func setErrorToFname(_ error : String)
    func setErrorToLname(_ error : String)
    func getEmail()->String
    func getFName()->String
    func getGenderText()->String
    func changePrivacyButtonImage(with name : String)
    func changeShowPasswordBtnImage(with name : String)
}
