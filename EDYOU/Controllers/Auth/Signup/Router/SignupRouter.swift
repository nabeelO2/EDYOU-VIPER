//
//  SignupRouter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation
import UIKit


protocol SignupRouterProtocol {
//    func navigateToHome()
}

class SignupRouter : SignupRouterProtocol {
    
//    func navigateToHome() {
//        
//    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController) -> SignupViewController {
        
        let view = SignupViewController(nibName: "SignupController", bundle: nil)
        let interactor = SignupInteractor()
        let router = SignupRouter(navigationController: navigationController)
        let presenter = SignupPresenter.init(view: view,router: router)
//        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}



