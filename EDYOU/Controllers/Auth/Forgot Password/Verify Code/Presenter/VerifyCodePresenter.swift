//
//  VerifyCodePresenter.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//

import Foundation

protocol VerifyCodePresenterProtocol: AnyObject {
    func viewDidLoad()
    func verifyCode(with pinCode: String, validation : Bool)
    func resendCode(with email: String)
}

class VerifyCodePresenter {
    weak var view: VerifyCodeViewProtocol?
    private let interactor: VerifyCodeInteractorProtocol
    private let router: VerifyCodeRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: VerifyCodeViewProtocol, router: VerifyCodeRouter, interactor : VerifyCodeInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension VerifyCodePresenter: VerifyCodePresenterProtocol {
    func verifyCode(with pinCode: String, validation: Bool) {
        
        
        if validation{
            view?.endEditing()
            view?.startAnimating()
            view?.userInteraction(false)
            interactor.VerifyCode(with: pinCode)
            
        }
        else{
            view?.shakeBtn()
        }
    }
    
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    func resendCode(with email: String) {
        view?.endEditing()
        view?.startLoading(with: "")
        interactor.resendCode(with: email)
        
    }
    
}

extension VerifyCodePresenter : VerifyCodeInteractorOutput{
    func errorMessage(error message: String) {
        view?.stopLoadingTxt()
        view?.stopAnimating()
        view?.userInteraction(true)
        view?.showErrorMessage(message)
    }
    
    
    
    func successResponse() {
        view?.stopAnimating()
        view?.userInteraction(true)
        router.navigatetoNewPasswordController(view?.getPinCode() ?? "")
    }
    func successMessage(successMessage message: String) {
        view?.endEditing()
        view?.stopLoadingTxt()
        view?.showSuccessMessageToUser(message)
    }
    
}


protocol VerifyCodeViewProtocol: AnyObject {
    func prepareUI()
    func showErrorMessage(_ message : String)
    func showSuccessMessageToUser(_ message : String)
    func startAnimating()
    func stopAnimating()
    func shakeBtn()
    func userInteraction(_ isTrue : Bool)
    func endEditing()
    func startLoading(with text :String)
    func stopLoadingTxt()
    func getPinCode()->String
    
}



