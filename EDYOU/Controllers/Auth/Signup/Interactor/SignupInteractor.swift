//
//  SignupInteractor.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//


import Foundation

protocol SignupInteractorProtocol: AnyObject {
    func getStatesList()
    func getSchoolList(of state : String)
    func register(_ params : [String: Any])
}

protocol SignupInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func userInformation(response user : User)
    func statesList( states list : [String])
    func schoolList(schools list : [School])
}

//Handle Api integration
class SignupInteractor {
    weak var output: SignupInteractorOutput?
}

extension SignupInteractor : SignupInteractorProtocol{
    
    func register(_ params : [String: Any]) {
        
        APIManager.auth.signup(parameters: params) { [weak self] oneTimeToken, error in
            if error != nil{
                self?.output?.error(error: error!.message)
            }else{
                self?.output?.successResponse()
            }
            
        }

    }
    func getStatesList(){
        
        APIManager.auth.getStates { [weak self] stateList , error in
            if error == nil{
                self?.output?.statesList(states: stateList ?? [])
            }
            
        }
    }
    func getSchoolList(of state : String){
        
        APIManager.auth.getSchools(state: state) { schools, error in
            if error == nil{
                self.output?.schoolList(schools: (schools ?? []))
            }
            else{
                self.output?.error(error: error!.message)
            }
        }
    }
}


