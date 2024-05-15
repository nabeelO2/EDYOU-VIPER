//
//  SelectPhotoRouter.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//


import Foundation
import UIKit


protocol SelectPhotoRouterProtocol {
    func navigateToHomeVC()
    func back()
}

class SelectPhotoRouter : SelectPhotoRouterProtocol {
    
    
    
    func navigateToHomeVC() {
        print("navigate to home screen")
        Application.shared.switchToHome()
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> SelectPhotoController {
        
        let view = SelectPhotoController(nibName: SelectPhotoController.name, bundle: nil)
        let interactor = SelectPhotoInteractor()
        let router = SelectPhotoRouter(navigationController: navigationController)
        let presenter = SelectPhotoPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}


