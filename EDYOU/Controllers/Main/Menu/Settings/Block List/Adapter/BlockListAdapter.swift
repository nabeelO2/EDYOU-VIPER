//
//  BlockListAdapter.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit
//import EmptyDataSet_Swift

class BlockListAdapter: NSObject {
    
    weak var tableView: UITableView!
    weak var textField : UITextField!

    var parent: BlockListController? {
        return tableView.viewContainingController() as? BlockListController
    }
    var isLoading = false
    var searchedUsers = [User]()
    var users = [User]()
    
    init(tableView: UITableView,textField: UITextField) {
        super.init()
        
        self.tableView = tableView
        self.textField = textField
        configure()
        self.textField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)

    }
    
    @objc func searchTextFieldDidChange(textField: UITextField) {
        if textField.text != "" {
            parent?.btnClear.isHidden = false
        } else {
            parent?.btnClear.isHidden = true
        }
        self.search(textField.text ?? "")
        }
    
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    
    }
    
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = users.filter { $0.name?.completeName.lowercased().contains(t) == true }
            self.searchedUsers = f
        } else {
            self.searchedUsers = users
        }
        tableView.reloadData()
        
    }
}

extension BlockListAdapter: UITableViewDataSource, UITableViewDelegate, UserCellActionsDelegate {
    func sendMessageToUser(user: User) {
    }
    
    func callToUser(user: User) {
    }
    
    func unblockUser(user: User) {
        unBlockUser(user: user)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        if searchedUsers.count == 0 {
            tableView.addEmptyView("No User(s)", "You have no user in list", EmptyCellConfirguration.friends.image)
        }
        tableView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 :searchedUsers.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        if isLoading {
            cell.btnConfirm.isHidden = true
            cell.viewCross.isHidden = true
            cell.viewCall.isHidden = true
            cell.viewCheckMark.isHidden = true
            cell.viewMessage.isHidden = true
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(self.searchedUsers[indexPath.row])
            cell.btnConfirm.isHidden = false
            cell.viewCross.isHidden = true
            cell.viewCall.isHidden = true
            cell.viewCheckMark.isHidden = true
            cell.viewMessage.isHidden = true
            cell.stkButtons.spacing = 14
            cell.btnConfirm.backgroundColor = .black
            cell.btnConfirm.borderColor = R.color.border()
            cell.btnConfirm.borderWidth = 0.5
            cell.btnConfirm.setTitleColor(.white, for: .normal)
            cell.btnConfirm.setTitle("Unblock", for: .normal)
            cell.delegate = self
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = searchedUsers.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
            
        }
    }
    
}

//
extension BlockListAdapter {
    func unBlockUser(user: User) {
        self.parent?.startLoading(title: "")
        APIManager.social.removeBlockUser(userid: user.userID!) { error in
            self.parent?.stopLoading()
            if error == nil {
                self.parent?.getBlockerUsers()
            } else {
                self.parent?.showErrorWith(message: error!.message)
            }
        }
    }
}
