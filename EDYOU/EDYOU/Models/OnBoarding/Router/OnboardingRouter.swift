//
//  onBoardingRouter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation
import UIKit

protocol OnboardingRouterProtocol{
    func navigateToSignIn()
    func navigateToSignUp()
    func navigateToPrivacy()
}

class OnboardingRouter : OnboardingRouterProtocol{
    
    var navigationController1: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController1 = navigationController
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    static func createModule(_ navigationController: UINavigationController) -> OnboardingViewController {
        
        let view = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
        let interactor = onBoardingInteractor()
        let router = OnboardingRouter(navigationController: navigationController)
        let presenter = onBoardingPresenter.init(view: view,router: router, interactor: interactor)
//        interactor.output = presenter
        view.presenter = presenter
        
        view.title = "OnBoarding"
        
        return view
    }
    
    func navigateToSignIn() {
        let login = LoginRouter.createModule(navigationController: self.navigationController1 ?? UINavigationController())
        self.navigationController1?.pushViewController(login, animated: true)
//        self.pushViewController(login, animated: true)
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


