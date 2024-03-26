//
//  NewPasswordInteractor.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//
import Foundation

protocol NewPasswordInteractorProtocol: AnyObject {
    
    func changePassword(with pin: String, newPassword : String)
}

protocol NewPasswordInteractorOutput: AnyObject {
    func errorMessage(error message : String)
    func successMessage(successMessage message : String)
   
}

//Handle Api integration
class NewPasswordInteractor {
    weak var output: NewPasswordInteractorOutput?
}

extension NewPasswordInteractor : NewPasswordInteractorProtocol{
    func changePassword(with pin: String, newPassword: String) {
        
        APIManager.auth.forgotPasswordChange(code: pin, newPassword: newPassword) { [weak self] (error) in
            
            if error == nil {
                self?.output?.successMessage(successMessage: "Password updated successfully")
    
            } else {
                self?.output?.errorMessage(error: error!.message)
            }
            
        }
    }
    
    
    
    
}




