//
//  onBoardingPresenter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation

protocol onBoardingPresenterInterface: AnyObject {
    func viewDidLoad()
    func navigateToSignIn()
    func navigateToSignup()
    func navigateToPrivacy()
}

class onBoardingPresenter {
    weak var view: OnBoardingViewInterface?
//    private let interactor: LoginInteractorInterface
    private let router: OnboardingRouter
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: OnBoardingViewInterface, router: OnboardingRouter) {
        self.view = view
//        self.interactor = interactor
        self.router = router
    }
    
}


extension onBoardingPresenter: onBoardingPresenterInterface {
    func navigateToSignIn() {
        self.router.navigateToSignIn()
    }
    
    func navigateToSignup() {
        
    }
    
    func navigateToPrivacy() {
        
    }
    
    func navigateToHome() {
//        self.router.navigateToHome()
    }
    
    
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    
}

