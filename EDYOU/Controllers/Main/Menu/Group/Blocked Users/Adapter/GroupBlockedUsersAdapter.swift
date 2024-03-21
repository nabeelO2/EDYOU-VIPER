//
//  
//  GroupBlockedUsersAdapter.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//
//

import UIKit
import TransitionButton

class GroupBlockedUsersAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var parent: GroupBlockedUsersController? {
        return tableView.viewContainingController() as? GroupBlockedUsersController
    }
    var users = [User]()
    var group: GroupAdminData
    
    // MARK: - Initializers
    init(tableView: UITableView, group: GroupAdminData) {
        self.group = group
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(MemberRequestCell.nib, forCellReuseIdentifier: MemberRequestCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension GroupBlockedUsersAdapter {
    
    @objc func didTapUnblockButton(_ sender: TransitionButton) {
        
        guard let u = group.blocked?.object(at: sender.tag) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0))
        
        sender.startAnimation()
        cell?.isUserInteractionEnabled = false
        update(user: u, action: .unblockMember) { [weak self] status in
            cell?.isUserInteractionEnabled = true
            sender.stopAnimation()
            
            if status == true {
                self?.group.blocked?.remove(at: sender.tag)
                self?.tableView.reloadData()
            }
            
        }
    }
}


// MARK: - TableView DataSource and Delegates
extension GroupBlockedUsersAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.blocked?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberRequestCell.identifier, for: indexPath) as! MemberRequestCell
        
        
        if let member = group.blocked?.object(at: indexPath.row) {
            
            cell.setData(member)
            
            
        }
        
        cell.btnDecline.backgroundColor = .clear
        cell.btnDecline.borderColor = R.color.border()
        cell.btnDecline.borderWidth = 0.5
        cell.btnDecline.setTitleColor(.black, for: .normal)
        cell.btnDecline.setTitle("Unblock", for: .normal)
        
        cell.btnApprove.isHidden = true
        cell.btnDecline.tag = indexPath.row
        cell.btnDecline.addTarget(self, action: #selector(didTapUnblockButton(_:)), for: .touchUpInside)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = group.blocked?.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
            
        }
    }
}


extension GroupBlockedUsersAdapter {
    func update(user: User, action: GroupAdminAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let gId = group.groupID else { return }
        
        APIManager.social.groupAdminAction(groupId: gId, userId: user.userID!, action: action) { error in
            if error == nil {
                completion(true)
            } else {
                self.parent?.showErrorWith(message: error!.message)
                completion(false)
            }
            
        }
    }
}
