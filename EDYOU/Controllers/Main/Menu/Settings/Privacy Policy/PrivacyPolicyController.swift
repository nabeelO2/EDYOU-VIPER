//
//  PrivacyPolicyController.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class PrivacyPolicyController: UIViewController {

    var completion: ((_ isAccept: Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    init(completion: @escaping (_ isAccept: Bool) -> Void) {
        super.init(nibName: PrivacyPolicyController.name, bundle: nil)
        
        self.completion = completion
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        goBack()
    }
    
    @IBAction func didTapAcceptButton(_ sender: UIButton) {
        completion?(true)
        goBack()
    }
    @IBAction func didTapRejectButton(_ sender: UIButton) {
        completion?(false)
        goBack()
    }
}
