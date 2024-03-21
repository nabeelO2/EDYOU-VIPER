//
//  GroupBlockedUsersController.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//

import UIKit

class GroupBlockedUsersController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var adapter: GroupBlockedUsersAdapter!
    var group: GroupAdminData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = GroupBlockedUsersAdapter(tableView: tableView, group: group)
        getData()
    }
    init(group: GroupAdminData) {
        self.group = group
        super.init(nibName: GroupBlockedUsersController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        self.group = GroupAdminData()
        super.init(coder: coder)
    }
}

// MARK: Actions
extension GroupBlockedUsersController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Web APIs
extension GroupBlockedUsersController {
    func getData() {
        guard  let id = group.groupID else { return }
        APIManager.social.getAdminData(groupId: id) { [weak self] data, error in
            guard let self = self else { return }
            
            if error == nil, let d = data {
                self.group = d
                self.adapter.group = d
                self.tableView.reloadData()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}
