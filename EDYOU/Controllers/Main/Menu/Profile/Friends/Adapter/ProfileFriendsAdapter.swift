//
//  ProfileFriendsAdapter.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 04/01/2022.
//

import Foundation
import EmptyDataSet_Swift

class ProfileFriendsAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: ProfileFriendsController? {
        return tableView.viewContainingController() as? ProfileFriendsController
    }
    var isLoading = true
    var searchedFriends = [User]()
    var friends = [User]()
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
        
    }
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = friends.filter { $0.name?.completeName.lowercased().contains(t) == true }
            self.searchedFriends = f
        } else {
            self.searchedFriends = friends
        }
        tableView.reloadData()
        
    }
}

extension ProfileFriendsAdapter {
    @objc func didTapConfirmButton(_ sender: UIButton) {
        guard let user = searchedFriends.object(at: sender.tag) else { return }
        sender.alpha = 0.5
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let requestStatus: FriendRequestStatus = sender.title(for: .normal) == "Cancel" ? .cancel : .approved
        
        updateRequestStatus(user: user, status: requestStatus) { status in
            sender.alpha = 1
            
            if status == true {
                self.searchedFriends.remove(at: sender.tag)
                
                if requestStatus == .approved {
                    self.parent?.friends.append(user)
                    self.parent?.friends = self.parent?.friends.sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") }) ?? []
                }
                
                self.tableView.reloadData()
                
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
    }
    @objc func didTapRemoveButton(_ sender: UIButton) {
        guard let user = searchedFriends.object(at: sender.tag) else { return }
        sender.alpha = 0.5
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        updateRequestStatus(user: user, status: .rejected) { status in
            sender.alpha = 1
            
            if status == true {
                self.searchedFriends.remove(at: sender.tag)
                
                self.tableView.reloadData()
                
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    @objc func didTapCallButton(_ sender: UIButton) {
        
    }
    @objc func didTapMessageButton(_ sender: UIButton) {
        
    }
}

extension ProfileFriendsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : searchedFriends.count
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
        
        
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(searchedFriends[indexPath.row])
            
//            let t = parent?.selectedTab
//
//
//            cell.stkButtons.spacing = 14
//            cell.viewCall.isHidden = false
//            cell.viewMessage.isHidden = false
            
//            if t == .received {
//                cell.stkButtons.spacing = 6
//                cell.btnConfirm.isHidden = false
//                cell.viewCross.isHidden = false
//            } else if t == .friends {
//                cell.stkButtons.spacing = 14
//                cell.viewCall.isHidden = false
//                cell.viewMessage.isHidden = false
//            } else if t == .sent {
//                cell.btnConfirm.isHidden = false
//                cell.btnConfirm.backgroundColor = R.color.sub_title()
//                cell.btnConfirm.setTitle("Cancel", for: .normal)
//            }
            
        }
        
        
        cell.btnConfirm.tag = indexPath.row
        cell.btnCross.tag = indexPath.row
        cell.btnMessage.tag = indexPath.row
        cell.btnCall.tag = indexPath.row
        
        cell.btnConfirm.addTarget(self, action: #selector(didTapConfirmButton(_:)), for: .touchUpInside)
        cell.btnCross.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
        cell.btnMessage.addTarget(self, action: #selector(didTapMessageButton(_:)), for: .touchUpInside)
        cell.btnCall.addTarget(self, action: #selector(didTapCallButton(_:)), for: .touchUpInside)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = searchedFriends.object(at: indexPath.row) {
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
            
        }
    }
    
}

extension ProfileFriendsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Result(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let message = "No friend in list"
        return NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
    }
}

extension ProfileFriendsAdapter {
    
    func updateRequestStatus(user: User, status: FriendRequestStatus, completion: @escaping (_ status: Bool) -> Void) {
        
        
        APIManager.social.updateFriendRequestStatus(user: user, status: status) { error in

            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                completion(false)
            } else {
                completion(true)
            }
            
            
        }
    }
    
}
