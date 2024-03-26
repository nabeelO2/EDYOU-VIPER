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
    func navigateToSignup()
    func navigateToAddMajor()
    func navigateToForgotPassword()
}

class LoginRouter : LoginRouterProtocol {
    
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
    
    static func createModule(navigationController: UINavigationController) -> LoginController {
        
        let view = LoginController(nibName: "LoginController", bundle: nil)
        let interactor = LoginInteractor()
        let router = LoginRouter(navigationController: navigationController)
        let presenter = LoginPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}


