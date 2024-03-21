//
//  InviteFriendsController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

class InviteFriendsController: UIViewController {
    
    @IBOutlet weak var lblSkip: UILabel!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblSkip.isHidden = isLoggedIn
        btnSkip.isHidden = isLoggedIn
        btnNext.isHidden = isLoggedIn
        view.backgroundColor = isLoggedIn ? R.color.background_light() : R.color.background()
    }

}

// MARK: - Actions
extension InviteFriendsController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapSkipButton(_ sender: Any) {
        Application.shared.switchToHome()
    }
    @IBAction func didTapFacebookButton(_ sender: Any) {
    }
    @IBAction func didTapTwitterAppButton(_ sender: Any) {
    }
    @IBAction func didTapGmailButton(_ sender: Any) {
    }
    @IBAction func didTapWhatsAppButton(_ sender: Any) {
    }
    @IBAction func didTapSMSButton(_ sender: Any) {
    }
    @IBAction func didTapCopyButton(_ sender: Any) {
    }
    @IBAction func didTapQRCodeButton(_ sender: Any) {
    }
    @IBAction func didTapNextButton(_ sender: Any) {
        Application.shared.switchToHome()
    }
}
