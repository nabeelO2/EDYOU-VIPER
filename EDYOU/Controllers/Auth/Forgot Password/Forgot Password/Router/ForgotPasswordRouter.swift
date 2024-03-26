//
//  ForgotPasswordRouter.swift
//  EDYOU
//
//  Created by imac3 on 25/03/2024.
//

import Foundation
import UIKit


protocol ForgotPasswordRouterProtocol {
    func navigateVerifyCodeController(_ email : String)
}

class ForgotPasswordRouter : ForgotPasswordRouterProtocol {
    
    
    func navigateVerifyCodeController(_ email : String) {
        let controller = VerifyCodeRouter.createModule(email: email, navigationController: navigationController ?? UINavigationController())
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> ForgotPasswordController {
        
        let view = ForgotPasswordController(nibName: "ForgotPasswordController", bundle: nil)
        let interactor = ForgotPasswordInteractor()
        let router = ForgotPasswordRouter(navigationController: navigationController)
        let presenter = ForgotPasswordPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = "Forgot Password11"
        
        return view
    }
    
}
