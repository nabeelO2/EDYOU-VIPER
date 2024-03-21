//
//  
//  UsersListAdapter.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//
//

import UIKit

class UsersListAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var parent: UIViewController? {
        return tableView.viewContainingController()
    }
    var users = [User]()
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
}


// MARK: - Utility Methods
extension UsersListAdapter {
}


// MARK: - TableView DataSource and Delegates
extension UsersListAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        if users.count == 0 {
            tableView.addEmptyView("No User(s)", "No user liked this post", EmptyCellConfirguration.friends.image)
        }
        return users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.setData(users[indexPath.row])
        cell.btnConfirm.isHidden = true
        cell.viewCross.isHidden = true
        cell.viewMessage.isHidden = true
        cell.viewCall.isHidden = true
        cell.viewCheckMark.isHidden = true
        cell.lblInfo.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = users.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.popToRootViewController(animated: false)
            navC?.pushViewController(controller, animated: true)
            
        }
    }
}



