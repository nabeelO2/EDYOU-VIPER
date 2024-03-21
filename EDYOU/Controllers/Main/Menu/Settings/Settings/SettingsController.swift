//
//  SettingsController.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//

import UIKit
import DPTagTextView

class SettingsController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    
    var adapter: SettingsAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = SettingsAdapter(tableView: tableView)
    }
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
