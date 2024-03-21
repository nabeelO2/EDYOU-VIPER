//
//  PendingPostsController.swift
//  EDYOU
//
//  Created by  Mac on 17/10/2021.
//

import UIKit

class PendingPostsController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    
    var adapter:PendingPostsdapter!
    var group: GroupAdminData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = PendingPostsdapter(tableView: tableView, group: group)
        
    }
    init(group: GroupAdminData) {
        self.group = group
        super.init(nibName: PendingPostsController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        self.group = GroupAdminData()
        super.init(coder: coder)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adapter.isLoading = false
        self.adapter.tableView.reloadData()
    }
    
}


// MARK: - Web APIs
extension PendingPostsController {
    func getData() {
        guard  let id = group.groupID else { return }
        APIManager.social.getAdminData(groupId: id) { [weak self] data, error in
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            if error == nil, let d = data {
                self.group = d
                self.adapter.group = d
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
        }
    }
}

