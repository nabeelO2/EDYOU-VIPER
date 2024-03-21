//
//  WelcomeController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

class WelcomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Actions
extension WelcomeController {
    @IBAction func didTapContinueWithEmailButton(_ sender: UIButton) {
        let controller = LoginController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapCreateAccountButton(_ sender: UIButton) {
        let controller = SelectUniversityController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
