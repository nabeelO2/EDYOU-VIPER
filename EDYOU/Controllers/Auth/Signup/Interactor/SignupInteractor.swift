//
//  SignupInteractor.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//


import Foundation

protocol SignupInteractorProtocol: AnyObject {
    func register(with email: String, password : String)
    func getStatesList()->[String]?
}

protocol SignupInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func userInformation(response user : User)
    func statesList( states list : [String])
}

//Handle Api integration
class SignupInteractor {
    weak var output: SignupInteractorOutput?
}

extension SignupInteractor : SignupInteractorProtocol{
    func register(with email: String, password: String) {
        
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
    func getStatesList()->[String]?{
        return nil
//        APIManager.auth.getStates { [weak self] stateList , error in
//            self?.output?.statesList(states: stateList)
//
//        }
    }
}


