//
//  
//  NewChatAdapter.swift
//  EDYOU
//
//  Created by  Mac on 05/12/2021.
//
//

import UIKit

class NewChatAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var didSelectUser: ((_ user: User) -> Void)?
    var parent: UIViewController? {
        return tableView.viewContainingController() as? UIViewController
    }
    
    var users = [User]()
    var isLoading = true
    
    // MARK: - Initializers
    init(tableView: UITableView, didSelectUser: @escaping (_ user: User) -> Void) {
        super.init()
        
        self.didSelectUser = didSelectUser
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
extension NewChatAdapter {
}


// MARK: - TableView DataSource and Delegates
extension NewChatAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 20: users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(users[indexPath.row])
        }
        cell.hideSktButtonsSubViews()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = users.object(at: indexPath.row) {
            didSelectUser?(user)
          
          //  let navC = self?.tabBarController?.navigationController ?? self?.navigationController
//            let controller = ChatRoomController()
//            controller.user = user
//            parent?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
