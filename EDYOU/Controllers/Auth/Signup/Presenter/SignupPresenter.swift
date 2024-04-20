//
//  SignupPresenter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation

protocol SignupPresenterProtocol: AnyObject {
    func viewDidLoad()
    func navigateToHome()
    func navigateToSignup()
    func navigateToForgetPassword()
    func showHidePassword()
    func register(email : String?, password : String?,isValidation : Bool)
    func textFieldDidChange(text: String)
}

class SignupPresenter {
    weak var view: SignupViewProtocol?
    private let interactor: SignupInteractorProtocol
    private let router: SignupRouter
//    private(set) var SignupResult: [SignupResultData] = []
    
    init(view: SignupViewProtocol, router: SignupRouter, interactor : SignupInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension SignupPresenter: SignupPresenterProtocol {
    
    func navigateToSignup() {
        router.navigateToSignup()
    }
    
    func textFieldDidChange(text: String) {
        let isHidden = text.count == 0
        view?.passwordBtnVisibility(isHidden)
    }
    
    func navigateToForgetPassword() {
        router.navigateToForgotPassword()
    }
    
    func showHidePassword() {
        view?.showHidePassword()
    }
    
    
    
    func register(email: String?, password: String?, isValidation: Bool) {
        if isValidation{
            //hit api
            view?.startAnimating()
            interactor.register(with: email!, password: password!)
        }else{
            view?.stopAnimating()
            view?.shakeSignupButton()
        }
    }
    
    
    func navigateToHome() {
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
    
}

extension SignupPresenter : SignupInteractorOutput{
    
    func statesList(states list: [String]) {
        let states = list.stringToDatePickerItem()
        view?.setStates(states)
    }
    func error(error message: String) {
        view?.stopAnimating()
        view?.shakeSignupButton()
        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
        UserDefaults.standard.set(true, forKey: "loggedIn")
        //get user detail
        interactor.getUserDetail()
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
    


protocol SignupViewProtocol: AnyObject {
    func prepareUI()
    func shakeSignupButton()
    func showHidePassword()
    func passwordBtnVisibility(_ isHidden : Bool)
    func showErrorMessage(_ message : String)
    func startAnimating()
    func stopAnimating()
    func startStatesLoading()
    func stopStatesLoading()
    func setStatesUserInteraction(_ result : Bool)
    func setStates(_ statesList : [DataPickerItem<String>])
}
