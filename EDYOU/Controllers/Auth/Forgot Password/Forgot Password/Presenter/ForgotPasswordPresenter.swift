//
//  ForgotPasswordPresenter.swift
//  EDYOU
//
//  Created by imac3 on 25/03/2024.
//

import Foundation

protocol ForgotPasswordPresenterProtocol: AnyObject {
    func viewDidLoad()
    func forgotPassword(with email: String, validation : Bool)
}

class ForgotPasswordPresenter {
    weak var view: ForgotPasswordViewProtocol?
    private let interactor: ForgotPasswordInteractorProtocol
    private let router: ForgotPasswordRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: ForgotPasswordViewProtocol, router: ForgotPasswordRouter, interactor : ForgotPasswordInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension ForgotPasswordPresenter: ForgotPasswordPresenterProtocol {
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    func forgotPassword(with email: String, validation : Bool) {
        view?.endEditing()
        view?.startAnimating()
        if validation{
            view?.startAnimating()
            interactor.forgotPassword(with: email)
            view?.userInteraction(false)
        }
        else{
            view?.shakeBtn()
        }
        
    }
    
}

extension ForgotPasswordPresenter : ForgotPasswordInteractorOutput{
    func error(error message: String) {
        view?.stopAnimating()
        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
        view?.stopAnimating()
        view?.userInteraction(true)
        router.navigateVerifyCodeController(view?.getEmail() ?? "")
//        UserDefaults.standard.set(true, forKey: "loggedIn")
        //get user detail
    }
    
}


protocol ForgotPasswordViewProtocol: AnyObject {
    func prepareUI()
    func showErrorMessage(_ message : String)
    func startAnimating()
    func stopAnimating()
    func shakeBtn()
    func getEmail()->String
    func userInteraction(_ isTrue : Bool) 
    func endEditing()
}


