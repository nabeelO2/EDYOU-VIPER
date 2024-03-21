//
//  GroupMembersController.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//

import UIKit

class GroupMembersController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var adapter: GroupMembersAdapter!
    var group: Group
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = GroupMembersAdapter(tableView: tableView, group: group)
    }
    init(group: Group) {
        self.group = group
        super.init(nibName: GroupMembersController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        self.group = Group()
        super.init(coder: coder)
    }
}

// MARK: Actions
extension GroupMembersController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
