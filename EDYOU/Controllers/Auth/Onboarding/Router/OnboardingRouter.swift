//
//  OnboardingRouter.swift
//  EDYOU
//
//  Created by imac3 on 24/04/2024.
//

import Foundation
import UIKit


protocol OnboardingRouterProtocol {
    func navigateToLogin()
    func navigateToSignup()
}

class OnboardingRouter : OnboardingRouterProtocol {
    
    func navigateToSignup() {
        print("navigate to signup")
    }
    
    
    func navigateToLogin() {
        print("navigate to home")
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> OnboardingViewController {
        
        let view = OnboardingViewController(nibName: OnboardingViewController.name, bundle: nil)
        let interactor = OnboardingInteractor()
        let router = OnboardingRouter(navigationController: navigationController)
        let presenter = OnboardingPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}
