//
//  VerifyCodeInteractor.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//
import Foundation

protocol VerifyCodeInteractorProtocol: AnyObject {
    func VerifyCode(with pin: String)
    func resendCode(with email: String)
}

protocol VerifyCodeInteractorOutput: AnyObject {
    func errorMessage(error message : String)
    func successResponse()
    func successMessage(successMessage message : String)
   
}

//Handle Api integration
class VerifyCodeInteractor {
    weak var output: VerifyCodeInteractorOutput?
}

extension VerifyCodeInteractor : VerifyCodeInteractorProtocol{
    func VerifyCode(with pin: String) {
        APIManager.auth.forgotPasswordVerify(code: pin) { [weak self] (error) in
           
            if error == nil {
                self?.output?.successResponse()
            } else {
                self?.output?.errorMessage(error: error!.message)
            }
            
        }
    
    }
    
    func resendCode(with email: String) {
        
        APIManager.auth.forgotPassword(email: email) { [weak self] (token, error) in
            
            if error == nil {
                self?.output?.successMessage(successMessage: "4 digit code sent to your email")
                
            } else {
                self?.output?.errorMessage(error: error!.message)
                
            }
            
        }
    }
    
}




