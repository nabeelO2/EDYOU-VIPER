//
//  LoginInteractor.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation

protocol LoginInteractorProtocol: AnyObject {
    func login(with email: String, password : String)
    func getUserDetail()
}

protocol LoginInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func userInformation(response user : User)
}

//Handle Api integration
class LoginInteractor {
    weak var output: LoginInteractorOutput?
}

extension LoginInteractor : LoginInteractorProtocol{
    func login(with email: String, password: String) {
        APIManager.auth.login(email: email, password: password) { response, error in
            if response != nil{
                self.output?.successResponse()
               
            }
            else{
                self.output?.error(error: error!.message)
            }
            
        }
    }
    
    func getUserDetail() {
        
        APIManager.social.getUserInfo { [weak self] user, error in
            if error != nil {
                self?.output?.error(error: error!.message)
            }
            else{
                self?.output?.userInformation(response: user!)
            }
        }
    }
}


