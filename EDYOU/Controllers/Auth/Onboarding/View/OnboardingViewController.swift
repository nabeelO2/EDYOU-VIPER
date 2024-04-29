//
//  OnboardingViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit

class OnboardingViewController: BaseController {
    @IBOutlet weak var signupButton: UIButton!
    
    var presenter : OnboardingPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTouched(_ sender: Any) {
        presenter.navigateToSignIn(self.navigationController!)
    }
    @IBAction func signupButtonTouched(_ sender: Any) {
        presenter.navigateToSignup(self.navigationController!)
        
    }
    @IBAction func privacyPolicyButtonTouched(_ sender: Any) {
        presenter.navigateToPrivacy(self.navigationController!)
    }
    
    

}

extension OnboardingViewController : OnboardingViewProtocol{
    func prepareUI() {
        signupButton.layer.borderColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1).cgColor
        signupButton.layer.borderWidth = 1
    }
    
}

