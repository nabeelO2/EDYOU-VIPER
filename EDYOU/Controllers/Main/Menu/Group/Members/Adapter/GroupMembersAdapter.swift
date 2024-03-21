//
//  
//  GroupMembersAdapter.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//
//

import UIKit

class GroupMembersAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var parent: GroupMembersController? {
        return tableView.viewContainingController() as? GroupMembersController
    }
    var users = [User]()
    var admins = [User]()
    var group: Group
    var isAdminMe: Bool {
        
        
        let isOwner = Cache.shared.user?.userID == group.groupOwner?.userID
        let isAdmin = group.groupAdmins?.contains(where: { $0.userID == Cache.shared.user?.userID })
        
        return isOwner == true || isAdmin == true
    }
    
    // MARK: - Initializers
    init(tableView: UITableView, group: Group) {
        self.group = group
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
extension GroupMembersAdapter {
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let member = group.groupMembers?.object(at: sender.tag) else { return }
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? UserCell
        let isMemberAdmin = group.groupAdmins?.contains(where: { $0.userID == member.userID })
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Block", style: .default, handler: { _ in
            self.update(user: member, action: .blockMember, cell: cell) { status in
                if status {
                    self.group.groupMembers?.remove(at: sender.tag)
                }
                self.tableView.reloadData()
            }
        }))
        
        if isMemberAdmin == true {
            actionSheet.addAction(UIAlertAction(title: "Remove Admin", style: .default, handler: { _ in
                self.update(user: member, action: .removeGroupAdmin, cell: cell) { status in
                    
                    if status == true {
                        let index = self.group.groupAdmins?.firstIndex(where: { $0.userID == member.userID })
                        if let i = index, i >= 0, i < (self.group.groupAdmins?.count ?? 0) {
                            self.group.groupAdmins?.remove(at: i)
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Make Admin", style: .default, handler: { _ in
                self.update(user: member, action: .addGroupAdmin, cell: cell) { status in
                    if status == true {
                        self.group.groupAdmins?.append(member)
                    }
                    self.tableView.reloadData()
                }
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Remove from Group", style: .default, handler: { _ in
            self.update(user: member, action: .removeGroupMember, cell: cell) { status in
                if status {
                    self.group.groupMembers?.remove(at: sender.tag)
                }
                self.tableView.reloadData()
            }
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.parent?.present(actionSheet, animated: true, completion: nil)
        
    }
}


// MARK: - TableView DataSource and Delegates
extension GroupMembersAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.groupMembers?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        
        
        cell.imgCall.image = UIImage(systemName: "ellipsis")
        cell.imgCall.tintColor = R.color.sub_title()
        cell.btnConfirm.isHidden = true
        cell.viewCross.isHidden = true
        cell.viewCall.isHidden = isAdminMe == false
        cell.viewCheckMark.isHidden = true
        cell.viewMessage.isHidden = true
        
        cell.btnCall.tag = indexPath.row
        cell.btnCall.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        
        
        
        if let member = group.groupMembers?.object(at: indexPath.row) {
            
            cell.setData(member)
            
            let isOwner = member.userID == group.groupOwner?.userID
            let isAdmin = group.groupAdmins?.contains(where: { $0.userID == member.userID })
            
            if isOwner {
                cell.lblInfo.isHidden = false
                cell.lblInfo.text = "~Owner"
                cell.viewCall.isHidden = true
            } else if isAdmin == true {
                cell.lblInfo.isHidden = false
                cell.lblInfo.text = "~Admin"
                cell.viewCall.isHidden = member.userID == Cache.shared.user?.userID

            } else {
                cell.lblInfo.isHidden = true
            }
            
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = group.groupMembers?.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
            
        }
    }
}


extension GroupMembersAdapter {
    func update(user: User, action: GroupAdminAction, cell: UserCell?, completion: @escaping (_ status: Bool) -> Void) {
        guard let gId = group.groupID else { return }
        
        cell?.startLoading()
        APIManager.social.groupAdminAction(groupId: gId, userId: user.userID!, action: action) { error in
            cell?.stopLoading()
            if error == nil {
                completion(true)
            } else {
                self.parent?.showErrorWith(message: error!.message)
                completion(false)
            }
            
        }
    }
}


