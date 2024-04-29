//
//  OnboardingRouter.swift
//  EDYOU
//
//  Created by imac3 on 24/04/2024.
//

import Foundation
import UIKit


protocol OnboardingRouterProtocol {
    func navigateToLogin(_ navigationConroller:UINavigationController)
    func navigateToSignup(_ navigationConroller:UINavigationController)
    func navigateToPrivacy(_ navigationConroller:UINavigationController)
}

class OnboardingRouter : OnboardingRouterProtocol {
    
    func navigateToSignup(_ navigationController: UINavigationController) {
        print("navigate to signup")
        let controller = SignupRouter.createModule(navigationController: navigationController)
        navigationController.pushViewController(controller, animated: true)
    }
    
    
    func navigateToLogin(_ navigationController: UINavigationController) {
        print("navigate to login")
        let controller = LoginRouter.createModule(navigationController: navigationController)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToPrivacy(_ navigationController: UINavigationController){
//        let controller = PrivacyPolicyController(nibName: PrivacyPolicyController.name, bundle: nil)
//        controller.modalPresentationStyle = .fullScreen
//        navigationController?.present(controller, animated: true, completion: nil)
        
    }
    
//    var navigationController: UINavigationController?
    
    init() {
//        self.navigationController = navigationController
        
    }
    
    static func createModule() -> OnboardingViewController {
        
        let view = OnboardingViewController(nibName: OnboardingViewController.name, bundle: nil)
        let interactor = OnboardingInteractor()
        let router = OnboardingRouter()
        let presenter = OnboardingPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}
