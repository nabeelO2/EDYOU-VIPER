//
//  LoginPresenter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation

protocol LoginPresenterInterface: AnyObject {
    func viewDidLoad()
    func navigateToHome()
    func login(email : String, password : String)
}

class LoginPresenter {
    weak var view: LoginViewInterface?
//    private let interactor: LoginInteractorInterface
    private let router: LoginRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: LoginViewInterface, router: LoginRouter) {
        self.view = view
//        self.interactor = interactor
        self.router = router
    }
    
}


extension LoginPresenter: LoginPresenterInterface {
    func navigateToHome() {
//        self.router.navigateToHome()
    }
    
    
    
    func login(email: String, password: String) {
//        interactor.login(with: email, password: password)
    }
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    
}
