//
//  OnboardingPresenter.swift
//  EDYOU
//
//  Created by imac3 on 24/04/2024.
//
import Foundation

protocol OnboardingPresenterProtocol: AnyObject {//Input
    func viewDidLoad()
    func setupUI()
    func navigateToSignIn()
    func navigateToSignup()
    func navigateToPrivacy()
}

class OnboardingPresenter {
    weak var view: OnboardingViewProtocol?
    private let interactor: OnboardingInteractorProtocol
    private let router: OnboardingRouter

    
    init(view: OnboardingViewProtocol, router: OnboardingRouter, interactor : OnboardingInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension OnboardingPresenter: OnboardingPresenterProtocol {
        
    func setupUI() {
        
    }
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    func navigateToSignIn() {
        router.navigateToLogin()
    }
    func navigateToSignup() {
        router.navigateToSignup()
    }
    func navigateToPrivacy() {
        router.navigateToLogin()
    }
    
}

extension OnboardingPresenter : OnboardingInteractorOutput{
    func error(error message: String) {
//        view?.stopAnimating()
//        view?.shakeLoginButton()
//        view?.showErrorMessage(message)
        
    }
    
    func successResponse() {
//        UserDefaults.standard.set(true, forKey: "loggedIn")
        //get user detail
    }

}


protocol OnboardingViewProtocol: AnyObject {//Output
    func prepareUI()
}


