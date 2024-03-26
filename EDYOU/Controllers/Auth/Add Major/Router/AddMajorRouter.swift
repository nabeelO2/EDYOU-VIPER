//
//  MajorRouter.swift
//  EDYOU
//
//  Created by imac3 on 22/03/2024.
//

import Foundation
import UIKit


protocol MajorRouterProtocol {
    func navigateToHome()
    func navigateToSignup()
}

class AddMajorRouter : MajorRouterProtocol {
    
    func navigateToSignup() {
        print("navigate to home")
    }
    
    
    func navigateToHome() {
        print("navigate to home")
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> AddMajorViewController {
        
        let view = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
        let interactor = MajorInteractor()
        let router = AddMajorRouter(navigationController: navigationController)
        let presenter = MajorPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = "Add Major"
        
        return view
    }
    
}
