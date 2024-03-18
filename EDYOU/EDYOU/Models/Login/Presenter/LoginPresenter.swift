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
    func navigateToForgetPassword()
    func showHidePassword()
    func login(email : String?, password : String?,isValidation : Bool)
    func textFieldDidChange(text: String)
}

class LoginPresenter {
    weak var view: LoginViewProtocol?
//    private let interactor: LoginInteractorInterface
    private let router: LoginRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: LoginViewProtocol, router: LoginRouter) {
        self.view = view
//        self.interactor = interactor
        self.router = router
    }
    
}


extension LoginPresenter: LoginPresenterProtocol {
    func textFieldDidChange(text: String) {
        let isHidden = text.count == 0
        view?.passwordBtnVisibility(isHidden)
    }
    
    func navigateToForgetPassword() {
        
    }
    
    func showHidePassword() {
        view?.showHidePassword()
    }
    
    
    
    func login(email: String?, password: String?, isValidation: Bool) {
        if isValidation{
            //hit api
            
        }else{
            view?.shakeLoginButton()
        }
    }
    
    
    func navigateToHome() {
//        self.router.navigateToHome()
    }
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    
}
