//
//  MajorInteractor.swift
//  EDYOU
//
//  Created by imac3 on 22/03/2024.
//

import Foundation

protocol MajorInteractorProtocol: AnyObject {
    func login(with email: String, password : String)
    func getUserDetail()
}

protocol MajorInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func userInformation(response user : User)
}

//Handle Api integration
class MajorInteractor {
    weak var output: MajorInteractorOutput?
}

extension MajorInteractor : MajorInteractorProtocol{
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
//            if error == nil {
//                self.output?.error(error: error!.message)
//            }
//            else{
//                self.output?.userInformation(user!)
//            }
        }
    }
}



