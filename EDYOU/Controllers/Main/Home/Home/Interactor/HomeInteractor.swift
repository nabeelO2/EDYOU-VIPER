//
//  HomeInteractor.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2024.
//

import Foundation

protocol HomeInteractorProtocol: AnyObject {//Input
    func apiCall(with email: String, password : String)
    func getMyEvents()
    func getNotifications()
    func getEvents()
}

protocol HomeInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func eventsIAmInvited(_ events : [Event]?)
    func unReadNotifications(_ notifications : Int)
    func publicEvents(_ events : [Event])
}

//Handle Api integration
class HomeInteractor {
    weak var output: HomeInteractorOutput?
}

extension HomeInteractor : HomeInteractorProtocol{
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
    func getMyEvents() {
        APIManager.social.getMyEvents(query: .me) { [weak self] eventsIAmGoing, eventsICreated, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested, error  in
            guard let self = self else { return }
            
            if error == nil {
                self.output?.eventsIAmInvited(eventsIAmInvited ?? [])
//                self.eventsIAmInvited = eventsIAmInvited ?? []
              
            }
        }
    }
    
    func getNotifications(){
        APIManager.social.getNotifications { [weak self] notifications, error in
            guard let self = self else { return }
            if error == nil {
                let unreadCount = notifications.unreadCount()
                self.output?.unReadNotifications(unreadCount)
                
            } else {
                self.output?.error(error: error!.message)
            }
        }
    }
    
    func getEvents() {
        APIManager.social.getEvents(query: .public) { [weak self] events, error in
            guard let self = self else { return }
            
            if error == nil {
                self.output?.publicEvents(events ?? [])
            } else {
                self.output?.error(error: error!.message)
            }
        }
    }
}


