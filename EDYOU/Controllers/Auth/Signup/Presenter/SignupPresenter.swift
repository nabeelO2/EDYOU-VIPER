//
//  SignupPresenter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation

protocol SignupPresenterProtocol: AnyObject {
    func viewDidLoad()
    
}

class SignupPresenter {
    weak var view: SignupViewProtocol?
//    private let interactor: LoginInteractorInterface
    private let router: SignupRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: SignupViewProtocol, router: SignupRouter) {
        self.view = view
//        self.interactor = interactor
        self.router = router
    }
    
}

extension SignupPresenter : SignupPresenterProtocol{
    func viewDidLoad() {
        
    }
    
    
}

protocol SignupViewProtocol: AnyObject {
    func prepareUI()
    func shakeLoginButton()
    func showHidePassword()
    func passwordBtnVisibility(_ isHidden : Bool)
}
