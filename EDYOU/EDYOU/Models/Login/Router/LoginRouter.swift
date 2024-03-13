//
//  HomeRouter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//
import Foundation
import UIKit


//protocol HomeRouterInterface: AnyObject {
//    func navigateToHome(to home: String)
//}

class LoginRouter {
    
    
//    var navigationController: UINavigationController?
    
    init() {
        
    }
    
    static func createModule() -> LoginController {
        
        let view = LoginController(nibName: "LoginController", bundle: nil)
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let presenter = LoginPresenter.init(view: view,router: router)
//        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}


