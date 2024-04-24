//
//  OnboardingInteractor.swift
//  EDYOU
//
//  Created by imac3 on 24/04/2024.
//


import Foundation

protocol OnboardingInteractorProtocol: AnyObject {//Input
    func apiCall(with email: String, password : String)
   
}

protocol OnboardingInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
}

//Handle Api integration
class OnboardingInteractor {
    weak var output: OnboardingInteractorOutput?
}

extension OnboardingInteractor : OnboardingInteractorProtocol{
    func apiCall(with email: String, password: String) {
        APIManager.auth.login(email: email, password: password) { response, error in
            if response != nil{
                self.output?.successResponse()
            }
            else{
                self.output?.error(error: error!.message)
            }
            
        }
    }
    
    
}



