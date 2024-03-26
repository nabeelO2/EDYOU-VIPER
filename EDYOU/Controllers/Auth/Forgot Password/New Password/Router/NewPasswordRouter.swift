//
//  NewPasswordRouter.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//

import Foundation
import UIKit


protocol NewPasswordRouterProtocol {
    func navigatetoLogin()
}

class NewPasswordRouter : NewPasswordRouterProtocol {
    
    func navigatetoLogin() {
        let controllers = self.navigationController?.viewControllers ?? []
        if let loginController = controllers.first(where: { vc in
            vc is LoginController
        }){
            self.navigationController?.popToViewController(loginController, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(pinCode: String,navigationController: UINavigationController) -> NewPasswordController {
        
        let view = NewPasswordController(pin: pinCode)
        let interactor = NewPasswordInteractor()
        let router = NewPasswordRouter(navigationController: navigationController)
        let presenter = NewPasswordPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = "Forgot Password"
        
        return view
    }
    
}

