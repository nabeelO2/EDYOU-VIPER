//
//  NewPasswordPresenter.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//

import Foundation

protocol NewPasswordPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapShowPasswordButton()
    func didTapShowConfirmPasswordButton()
    func didTapSavePasswordButton()
}

class NewPasswordPresenter {
    weak var view: NewPasswordViewProtocol?
    private let interactor: NewPasswordInteractorProtocol
    private let router: NewPasswordRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: NewPasswordViewProtocol, router: NewPasswordRouter, interactor : NewPasswordInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func validate() -> Bool {
        let passwordValidated = view?.getPasswordValidation() ?? false
        let confirmPasswordValidated = view?.getConfirmPasswordValidation() ?? false
        let passwordText = view?.getPasswordText()
        let confirmedPasswordText = view?.getConfirmPasswordText()
        
        if passwordValidated && confirmPasswordValidated && passwordText != confirmedPasswordText {
            view?.showErrorMessage("Password and Confirm Password does not match")
        }
        return passwordValidated && confirmPasswordValidated && passwordText == confirmedPasswordText
    }
    
}


extension NewPasswordPresenter: NewPasswordPresenterProtocol {
    
    func didTapShowConfirmPasswordButton() {
        let secure = view?.getShowConfirmPasswordSecure()
        if secure ?? false{
            view?.showConfirmPasswordUnSecured()
            view?.updateTextConfirmPassword("Hide")
        }
        else{
            view?.showConfirmPasswordSecured()
            view?.updateTextConfirmPassword("Show")
        }
    }
    
    func didTapSavePasswordButton() {
        view?.endEditing()

        let validated  = validate()
        if validated {
//            
            view?.startAnimating()
            view?.userInteraction(false)
            interactor.changePassword(with: view?.getPin() ?? "", newPassword: view?.getPasswordText() ?? "")

        } else {
            view?.shakeBtn()
        }
    }
    
    func didTapShowPasswordButton() {
        let secure = view?.getShowPasswordSecure()
        if secure ?? false{
            view?.showPasswordUnSecured()
            view?.updateTextPassword("Hide")
        }
        else{
            view?.showPasswordSecured()
            view?.updateTextPassword("Show")
        }
        
    }
    
//    func verifyCode(with pinCode: String, validation: Bool) {
//        
//        
//        if validation{
//            view?.endEditing()
//            view?.startAnimating()
//            view?.userInteraction(false)
//            interactor.VerifyCode(with: pinCode)
//            
//        }
//        else{
//            view?.shakeBtn()
//        }
//    }
//    
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
//    func resendCode(with email: String) {
//        view?.endEditing()
//        view?.startLoading(with: "")
//        interactor.resendCode(with: email)
//        
//    }
    
}

extension NewPasswordPresenter : NewPasswordInteractorOutput{
    func errorMessage(error message: String) {
        view?.stopAnimating()
        view?.userInteraction(true)
        view?.showErrorMessage(message)
    }
    
    func successMessage(successMessage message: String) {
        view?.showSuccessMessageToUser(message)
        view?.endEditing()
        view?.stopAnimating()
        router.navigatetoLogin()
        

    }
    
}


protocol NewPasswordViewProtocol: AnyObject {
    func prepareUI()
    func showErrorMessage(_ message : String)
    func showSuccessMessageToUser(_ message : String)
    func startAnimating()
    func stopAnimating()
    func shakeBtn()
    func userInteraction(_ isTrue : Bool)
    func endEditing()
    func getShowPasswordSecure()->Bool
    func getShowConfirmPasswordSecure()->Bool
    func showPasswordSecured()
    func showPasswordUnSecured()
    func showConfirmPasswordSecured()
    func showConfirmPasswordUnSecured()
    func updateTextPassword(_ text : String)
    func updateTextConfirmPassword(_ text : String)
    func getPasswordText()->String
    func getConfirmPasswordText()->String
    func getPasswordValidation()->Bool
    func getConfirmPasswordValidation()->Bool
    func getPin()->String
}




