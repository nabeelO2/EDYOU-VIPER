//
//  InviteFriendsInteractor.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//

import Foundation

protocol InviteFriendsInteractorProtocol: AnyObject {//Input
    func getSuggestedPeople(_ type: SuggestionType)
    func addFriend(_ user : User, _ onSuccess: @escaping (Any) -> Void)
}

protocol InviteFriendsInteractorOutput: AnyObject {
    func error(error message : String)
    func suggestedPeoples(_ users : [User]?)
    func updateNextButtonUI()
}

//Handle Api integration
class InviteFriendsInteractor {
    weak var output: InviteFriendsInteractorOutput?
}

extension InviteFriendsInteractor : InviteFriendsInteractorProtocol{
    
    
    func getSuggestedPeople(_ type: SuggestionType)
    {
        APIManager.social.suggestion(type: type) { (results, error) in
            
            if (error == nil) {
                let suggestedPeople = results?.people ?? []
                self.output?.suggestedPeoples(suggestedPeople)
                
            } else {
                self.output?.error(error: error!.message)
               
            }
        }
    }
    func addFriend(_ user: User, _ onSuccess: @escaping (Any) -> Void) {
        APIManager.social.sendFriendRequest(user: user, message: "Hi add me in your friends list.") { [weak self] error in

            guard let self = self else { return }
            
            if error == nil {
                self.output?.updateNextButtonUI()
               onSuccess(true)
            } else {

                if error!.message != "Record already exist"
                {
                    onSuccess(false)
                    self.output?.error(error: error!.message)
                }
                else
                {
                    self.output?.updateNextButtonUI()
                    onSuccess(true)
                }
            }
        }
        
    }
//    func addFriendAPI(user: User)
//    {
//        APIManager.social.sendFriendRequest(user: user, message: "Hi add me in your friends list.") { [weak self] error in
//
//            guard let self = self else { return }
////            if error == nil {
////                self.parent?.updateUI()
////               onSuccess(true)
////            } else {
////              
////                if error!.message != "Record already exist"
////                {
////                    onSuccess(false)
////                    self.parent?.showErrorWith(message: error!.message)
////                }
////                else
////                {
////                    self.parent?.updateUI()
////                    onSuccess(true)
////                }
////            }
//        }
//        
//    }
    
}


 


