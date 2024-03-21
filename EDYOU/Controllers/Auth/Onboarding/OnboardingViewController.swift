//
//  OnboardingViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit

class OnboardingViewController: BaseController {
    @IBOutlet weak var signupButton: UIButton!
    {
        didSet
        {
            //TODO: Add in Color Asset
            signupButton.layer.borderColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1).cgColor
            signupButton.layer.borderWidth = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTouched(_ sender: Any) {
        let controller = LoginController(nibName: "LoginController", bundle: nil)
  
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func signupButtonTouched(_ sender: Any) {
        let controller = SignupViewController(nibName: "SignupController", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    @IBAction func privacyPolicyButtonTouched(_ sender: Any) {
        let controller = PrivacyPolicyController(completion: {isAccept in
          
        })
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
