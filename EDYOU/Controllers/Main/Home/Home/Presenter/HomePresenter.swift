//
//  HomePresenter.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2024.
//
import Foundation

protocol HomePresenterProtocol: AnyObject {//Input
    func viewDidLoad()
    func viewWillAppear()
    
}

class HomePresenter {
    weak var view: HomeViewProtocol?
    private let interactor: HomeInteractorProtocol
    private let router: HomeRouter

    
    init(view: HomeViewProtocol, router: HomeRouter, interactor : HomeInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension HomePresenter: HomePresenterProtocol {
    
    
    func viewDidLoad() {
        XMPPAppDelegateManager.shared.registerForPushNotifications()
        view?.prepareUI()
    }
    func viewWillAppear() {
       
        view?.setProfileImage()
        interactor.getNotifications()
        interactor.getEvents()
    }
    
}

extension HomePresenter : HomeInteractorOutput{
    func error(error message: String) {
//        view?.stopAnimating()
//        view?.shakeLoginButton()
//        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
//        UserDefaults.standard.set(true, forKey: "loggedIn")
        //get user detail
    }

    func eventsIAmInvited(_ events: [Event]?) {
        
        if let events = events, events.count > 0 {
            router.presentEventInviteVC(events)
        }
    }
    
    func unReadNotifications(_ notifications: Int) {
        if notifications > 99 {
            view?.updateNotificationBadge("99+")
           
        } else {
            view?.updateNotificationBadge("\(notifications)")
            
        }
        view?.hideNotificationBadge(notifications == 0)
    }
    func publicEvents(_ events: [Event]) {
//        view?.adapter.events = events
    }
}


protocol HomeViewProtocol: AnyObject {//Output
    func prepareUI()
    func setProfileImage()
    func updateNotificationBadge(_ text : String)
    func hideNotificationBadge(_ isHidden : Bool)
}




