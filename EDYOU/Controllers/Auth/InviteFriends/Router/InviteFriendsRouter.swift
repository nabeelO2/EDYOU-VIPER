//
//  InviteFriendsRouter.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//


import Foundation
import UIKit


protocol InviteFriendsRouterProtocol {
    func navigateToAddPhotoVC()
}

class InviteFriendsRouter : InviteFriendsRouterProtocol {
    
    func navigateToAddPhotoVC() {
        let photo = SelectPhotoRouter.createModule(navigationController: navigationController ?? UINavigationController())
        navigationController?.pushViewController(photo, animated: true)
    }
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
        
    }
    
    static func createModule(navigationController: UINavigationController) -> InviteFriendViewController {
        
        let view = InviteFriendViewController(nibName: InviteFriendViewController.name, bundle: nil)
        let interactor = InviteFriendsInteractor()
        let router = InviteFriendsRouter(navigationController: navigationController)
        let presenter = InviteFriendsPresenter.init(view: view,router: router,interactor : interactor)
        interactor.output = presenter
        view.presenter = presenter
        
        view.title = ""
        
        return view
    }
    
}

