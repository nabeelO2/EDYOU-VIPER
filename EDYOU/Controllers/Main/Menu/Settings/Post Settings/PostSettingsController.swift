//
//  PostSettingsController.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class PostSettingsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var adapter: PostSettingsAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = PostSettingsAdapter(tableView: tableView)
        adapter.selectedSetting = AppDefaults.shared.postSettings
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        AppDefaults.shared.postSettings = adapter.selectedSetting
        navigationController?.popViewController(animated: true)
    }
}
