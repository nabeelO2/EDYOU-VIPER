//
//  HomeRouter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//
import Foundation
import UIKit


protocol LoginRouterProtocol {
    func navigateToHome()
}

class LoginRouter : LoginRouterProtocol {
    
    func navigateToHome() {
        
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController) -> LoginController {
        
        let view = LoginController(nibName: "LoginController", bundle: nil)
        let interactor = LoginInteractor()
        let router = LoginRouter(navigationController: navigationController)
        let presenter = LoginPresenter.init(view: view,router: router)
//        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}


