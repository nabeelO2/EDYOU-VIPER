//
//  
//  InviteFriendsToEventAdapter.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//
//

import UIKit
import EmptyDataSet_Swift


class InviteFriendsToEventAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var parent: SelectFriendsController? {
        return tableView.viewContainingController() as? SelectFriendsController
    }
    var didChangeSelection: (() -> Void)?
    var isLoading = true
    var friends = [User]()
    var searchedFriends = [User]()
    
    // MARK: - Initializers
    init(tableView: UITableView, didChangeSelection: @escaping () -> Void) {
        super.init()
        
        self.didChangeSelection = didChangeSelection
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    func deselectUser(_ user: User) {
        if let index = friends.firstIndex(where: { $0.userID == user.userID }), index >= 0 {
            friends[index].isSelected = false
        }
        if let index = searchedFriends.firstIndex(where: { $0.userID == user.userID }), index >= 0 {
            searchedFriends[index].isSelected = false
        }
        tableView.reloadData()
    }
    func search(text: String) {
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


// MARK: - Utility Methods
extension InviteFriendsToEventAdapter {
}


// MARK: - TableView DataSource and Delegates
extension InviteFriendsToEventAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isUserInteractionEnabled = !isLoading
        return isLoading ? 10 : searchedFriends.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.btnConfirm.isHidden = true
        cell.viewCross.isHidden = true
        cell.viewCall.isHidden = true
        cell.viewMessage.isHidden = true
        
        if isLoading {
            cell.viewCheckMark.isHidden = true
            cell.beginSkeltonAnimation()
        } else {
            cell.viewCheckMark.isHidden = false
            cell.setData(searchedFriends[indexPath.row])
            cell.imgCheckMark.image = UIImage(systemName: searchedFriends[indexPath.row].isSelected ? "checkmark.circle.fill" : "circle")
            cell.imgCheckMark.tintColor = searchedFriends[indexPath.row].isSelected ? R.color.buttons_green() : R.color.sub_title()?.withAlphaComponent(0.5)
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < searchedFriends.count {
            searchedFriends[indexPath.row].isSelected = !searchedFriends[indexPath.row].isSelected
            if let index = friends.firstIndex(where: { $0.userID == searchedFriends[indexPath.row].userID }), index >= 0 {
                friends[index].isSelected = searchedFriends[indexPath.row].isSelected
            }
            didChangeSelection?()
            tableView.reloadData()
        }
        
    }
}

extension InviteFriendsToEventAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No User(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let message = "No user liked this post"
        
        return NSAttributedString(string: message, attributes: [NSAttributedString.Key.font :  UIFont.systemFont(ofSize: 16)])
    }
}
