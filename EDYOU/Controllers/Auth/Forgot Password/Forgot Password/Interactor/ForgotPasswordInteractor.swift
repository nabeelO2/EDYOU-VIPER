//
//  ForgotPasswordInteractor.swift
//  EDYOU
//
//  Created by imac3 on 25/03/2024.
//
import Foundation

protocol ForgotPasswordInteractorProtocol: AnyObject {
    func forgotPassword(with email: String)
    
}

protocol ForgotPasswordInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
   
}

//Handle Api integration
class ForgotPasswordInteractor {
    weak var output: ForgotPasswordInteractorOutput?
}

extension ForgotPasswordInteractor : ForgotPasswordInteractorProtocol{
    func forgotPassword(with email: String) {
        APIManager.auth.forgotPassword(email: email) { token, response in
            if response != nil{
                self.output?.successResponse()
            }
            else{
                //                self.output?.error(error: errr!.message)
            }
            
        }

    }
    
    
}




