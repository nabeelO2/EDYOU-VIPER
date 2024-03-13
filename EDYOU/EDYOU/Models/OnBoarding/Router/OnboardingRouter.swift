//
//  onBoardingRouter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation
import UIKit


class OnboardingRouter {
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    
    static func createModule(_ navigationController: UINavigationController) -> OnboardingViewController {
        
        let view = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
        let interactor = onBoardingInteractor()
        let router = OnboardingRouter(navigationController: nil)
        let presenter = onBoardingPresenter.init(view: view,router: router)
//        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
    func navigateToSignIn() {
        let login = LoginRouter.createModule()
        self.navigationController?.pushViewController(login, animated: true)
    }
    func navigateToSignUp() {
//        let repoDetailVC = HomeRouter.createModule()
//        self.navigationController?.pushViewController(repoDetailVC, animated: true)
    }
    func navigateToPrivacy() {
//        let repoDetailVC = HomeRouter.createModule()
//        self.navigationController?.pushViewController(repoDetailVC, animated: true)
    }
    
}


