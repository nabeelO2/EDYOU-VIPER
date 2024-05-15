//
//  HomeRouter.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2024.
//

import Foundation
import UIKit
import PanModal


protocol HomeRouterProtocol {
    func navigateToVC()
    func presentEventInviteVC(_ events : [Event])
}

class HomeRouter : HomeRouterProtocol {
    
    func navigateToVC() {
        print("navigate to next screen")
    }
    
    func presentEventInviteVC(_ events: [Event]) {
        let controller = EventInviteController()
        controller.allInvitedEvents = events
        self.navigationController?.presentPanModal(controller)
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> HomeController {
        
        let view = HomeController(nibName: HomeController.name, bundle: nil)
        let interactor = HomeInteractor()
        let router = HomeRouter(navigationController: navigationController)
        let presenter = HomePresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}


