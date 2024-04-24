//
//  SignupRouter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation
import UIKit


protocol SignupRouterProtocol {
    func navigateToHome()
    func navigateToSignup()
    func navigateToAddMajor()
    func navigateToForgotPassword()
}

class SignupRouter : SignupRouterProtocol {
    
    func navigateToForgotPassword() {
        let forgot = ForgotPasswordRouter.createModule(navigationController: navigationController ?? UINavigationController())
        self.navigationController?.pushViewController(forgot, animated: true)
    }
    func navigateToAddMajor() {
        let major = AddMajorRouter.createModule(navigationController: self.navigationController ?? UINavigationController())
        self.navigationController?.pushViewController(major, animated: true)
    }
    func navigateToSignup() {
        let signup = SignupRouter.createModule(navigationController: self.navigationController ?? UINavigationController())
        
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    
    func navigateToHome() {
        
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController) -> SignupViewController {
        
        let view = SignupViewController(nibName: "SignupController", bundle: nil)
        let interactor = SignupInteractor()
        let router = SignupRouter(navigationController: navigationController)
        let presenter = SignupPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        view.title = ""
        return view
    }
    
}




