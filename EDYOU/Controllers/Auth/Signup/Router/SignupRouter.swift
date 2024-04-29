//
//  SignupRouter.swift
//  EDYOU
//
//  Created by imac3 on 20/03/2024.
//

import Foundation
import UIKit


protocol SignupRouterProtocol {
    func navigateToVerifyEmail(_ email : String?)
    func navigateToSignIn()
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
    func navigateToSignIn() {
        let signup = LoginRouter.createModule(navigationController: self.navigationController ?? UINavigationController())
        
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    
    func navigateToVerifyEmail(_ email : String?) {
        let controller = VerifyEmailController(email: email ?? "")
        self.navigationController?.pushViewController(controller, animated: true)
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




