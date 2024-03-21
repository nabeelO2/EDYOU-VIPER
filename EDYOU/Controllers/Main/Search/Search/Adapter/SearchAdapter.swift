//
//  SearchAdapter.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

class SearchAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: SearchController? {
        return tableView.viewContainingController() as? SearchController
    }
    var users = [User]()
    
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

extension SearchAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.btnConfirm.isHidden = true
        cell.viewCross.isHidden = true
        cell.viewCall.isHidden = true
        cell.viewCheckMark.isHidden = true
        cell.viewMessage.isHidden = true
        cell.setData(users[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let user = users.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            parent?.tabBarController?.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
}
