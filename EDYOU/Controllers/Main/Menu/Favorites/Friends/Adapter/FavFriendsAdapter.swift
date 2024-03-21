//
//  
//  FavFriendsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//
//

import UIKit
import EmptyDataSet_Swift
import Martin

class FavFriendsAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: FavFriendsController? {
        return tableView.viewContainingController() as? FavFriendsController
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

extension FavFriendsAdapter {
    @objc func didTapMessageButton(_ sender: UIButton) {
        guard let user = searchedFriends.object(at: sender.tag) else { return }
        let userJID = BareJID("\(user.userID ?? "")@ejabberd.edyou.io")
        if let clint = XmppService.instance.connectedClients.first {
            let res =  DBChatStore.instance.createChat(for: clint.context, with: userJID , name: user.name?.completeName ?? "")
            switch res {
                case .created(_),.found(_):
                    print("created")
                    DBChatStore.instance.refreshConversationsList()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        if let conversation = DBChatStore.instance.conversation(for: clint.userBareJid, with: userJID) {
                            let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                            controller.conversation = conversation
                            self.parent?.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                case .none:
                    self.parent?.showErrorWith(message: "Error while fetching Chat User")
                    return
            }
        } else {
            self.parent?.showErrorWith(message: "Unable to connect to server")
        }
    }
    
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let userId = searchedFriends.object(at: sender.tag)?.userID else { return }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Remove from Favourite", style: .default, handler: { (_) in
            self.unfavorite(userId: userId)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.parent?.present(actionSheet, animated: true, completion: nil)
    }
}

extension FavFriendsAdapter: UITableViewDataSource, UITableViewDelegate {
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
        cell.viewMore.isHidden = true
        cell.btnMore.isHidden = true
        
        
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(searchedFriends[indexPath.row])
            cell.stkButtons.spacing = 14
            cell.viewMessage.isHidden = false
            cell.viewMore.isHidden = false
            cell.btnMore.isHidden = false
            
        }
        cell.btnMessage.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        
        cell.btnMessage.addTarget(self, action: #selector(didTapMessageButton(_:)), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        
        
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

extension FavFriendsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Friend(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? { 
        return NSAttributedString(string: "You have no favourite friend", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
    }
}

extension FavFriendsAdapter {
    func unfavorite(userId: String) {
        tableView.isUserInteractionEnabled = false
        APIManager.social.removeFromFavorite(type: .friends, id: userId) { [weak self] error in
            self?.tableView.isUserInteractionEnabled = true
            if error == nil {
                let searchedIndex = self?.searchedFriends.firstIndex(where: { $0.userID == userId })
                if let i = searchedIndex {
                    self?.searchedFriends.remove(at: i)
                    let indexPath = IndexPath(row: i, section: 0)
                    self?.tableView.beginUpdates()
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.tableView.endUpdates()
                }
                let index = self?.friends.firstIndex(where: { $0.userID == userId })
                if let i = index {
                    self?.friends.remove(at: i)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.tableView.reloadData()
                }
                
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
}
