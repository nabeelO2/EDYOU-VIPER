//
//  onBoardingPresenter.swift
//  EDYOU
//
//  Created by imac3 on 13/03/2024.
//

import Foundation

protocol onBoardingPresenterProtocol: AnyObject {
    func viewDidLoad()
    func navigateToSignIn()
    func navigateToSignup()
    func navigateToPrivacy()
}

class onBoardingPresenter {
    weak var view: OnBoardingViewProtocol?
    private let interactor: onBoardingInteractorProtocol
    private let router: OnboardingRouterProtocol
//    private(set) var loginResult: [LoginResultData] = []
    
    init(view: OnBoardingViewProtocol, router: OnboardingRouterProtocol, interactor : onBoardingInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension onBoardingPresenter: onBoardingPresenterProtocol {
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

