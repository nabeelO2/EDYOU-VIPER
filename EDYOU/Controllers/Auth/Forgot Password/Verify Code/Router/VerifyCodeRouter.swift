//
//  VerifyCodePresenter.swift
//  EDYOU
//
//  Created by imac3 on 26/03/2024.
//

import Foundation
import UIKit


protocol VerifyCodeRouterProtocol {
    func navigatetoNewPasswordController(_ pin : String)
}

class VerifyCodeRouter : VerifyCodeRouterProtocol {
    
    
    func navigatetoNewPasswordController(_ pin : String) {
        let new = NewPasswordRouter.createModule(pinCode: pin, navigationController: self.navigationController ?? UINavigationController())
        self.navigationController?.pushViewController(new, animated: true)
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(email: String,navigationController: UINavigationController) -> VerifyCodeController {
        
        let view = VerifyCodeController(email: email)
        let interactor = VerifyCodeInteractor()
        let router = VerifyCodeRouter(navigationController: navigationController)
        let presenter = VerifyCodePresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = "Forgot Password"
        
        return view
    }
    
}
