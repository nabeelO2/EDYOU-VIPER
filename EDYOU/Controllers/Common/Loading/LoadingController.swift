//
//  LoadingController.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//

import UIKit

class LoadingController: UIViewController {

    @IBOutlet weak var lblLoading: UILabel!
    
    private var strTitle = "Loading..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblLoading.text = strTitle
    }
    init(title: String) {
        super.init(nibName: LoadingController.name, bundle: nil)
        
        self.strTitle = title
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
