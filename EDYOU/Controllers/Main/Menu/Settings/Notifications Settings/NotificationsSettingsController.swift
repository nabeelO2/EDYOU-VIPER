//
//  NotificationsSettingsController.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class NotificationsSettingsController: BaseController  {

    @IBOutlet weak var tableView: UITableView!
    
    var adapter: NotificationsSettingsAdapter!
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        adapter = NotificationsSettingsAdapter(tableView: tableView)
//        getNotificationSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter = NotificationsSettingsAdapter(tableView: tableView)
        getNotificationSettings()
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API
    func getNotificationSettings()
    {
        //self.startLoading(title: "")
        APIManager.social.getNotificationSettings { [weak self] settings, error in
            guard let self = self else { return }
          //  self.stopLoading()
            if error == nil {

                self.adapter.notificationSetting = settings
                self.adapter.tableView.reloadData()
                
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}
