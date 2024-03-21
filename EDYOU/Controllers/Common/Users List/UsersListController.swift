//
//  UsersListController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit

class UsersListController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var adapter: UsersListAdapter!
    var users = [User]()
    var strTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = strTitle
        adapter = UsersListAdapter(tableView: tableView)
        adapter.users = users
    }
    
    init(title: String, users: [User]) {
        super.init(nibName: UsersListController.name, bundle: nil)
        
        self.strTitle = title
        self.users = users
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        goBack()
    }
    
}
