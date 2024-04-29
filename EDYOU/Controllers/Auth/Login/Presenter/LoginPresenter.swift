//
//  LoginPresenter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation

protocol LoginPresenterProtocol: AnyObject {
    func viewDidLoad()
    func navigateToHome()
    func navigateToSignup()
    func navigateToForgetPassword()
    func showHidePassword()
    func login(email : String?, password : String?,isValidation : Bool)
    func textFieldDidChange(text: String)
}

class LoginPresenter {
    weak var view: LoginViewProtocol?
    private let interactor: LoginInteractorProtocol
    private let router: LoginRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: LoginViewProtocol, router: LoginRouter, interactor : LoginInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension LoginPresenter: LoginPresenterProtocol {
    
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
    
    
    
    func login(email: String?, password: String?, isValidation: Bool) {
        if isValidation{
            //hit api
            view?.startAnimating()
            interactor.login(with: email!, password: password!)
        }else{
            view?.stopAnimating()
            view?.shakeLoginButton()
        }
    }
    
    
    func navigateToHome() {
    }
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    
}

extension LoginPresenter : LoginInteractorOutput{
    func error(error message: String) {
        view?.stopAnimating()
        view?.shakeLoginButton()
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
            Application.shared.switchToHome()
//            move to home Screen
        } else {
//            move to name controller
            
//            let controller = AddNameController(university: university)
//            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}
    


protocol LoginViewProtocol: AnyObject {
    func prepareUI()
    func shakeLoginButton()
    func showHidePassword()
    func passwordBtnVisibility(_ isHidden : Bool)
    func showErrorMessage(_ message : String)
    func startAnimating()
    func stopAnimating()
}
