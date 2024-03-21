//
//  NewPostAdapter.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit

class NewPostTagUsersAdapter: NSObject {

    
    weak var tableView: UITableView!
    
    
    var users : [User] = []
    var filteredUsers : [User] = []
    var didSelectUser: ((_ user: User) -> Void)?
    var textColor: UIColor = .black {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView, didSelectUser: @escaping (_ user: User) -> Void) {
        super.init()
        
        self.tableView = tableView
        self.didSelectUser = didSelectUser
        configure()
    }
    
    func configure() {
        tableView.register(TagUserCell.nib, forCellReuseIdentifier: TagUserCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func search(text: String) {
        let t = text.lowercased()
        filteredUsers = users.filter {
            $0.name?.completeName.lowercased().contains(t) == true
        }
        tableView.reloadData()
    }
    
    func showAll() {
        filteredUsers = users
        tableView.reloadData()
    }
}

extension NewPostTagUsersAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagUserCell.identifier, for: indexPath) as! TagUserCell
        cell.lblName.text = filteredUsers[indexPath.row].name?.completeName
        cell.lblName.textColor =  textColor
        cell.imgProfile.setImage(url: filteredUsers[indexPath.row].profileImage, placeholder: R.image.profile_image_dummy())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectUser?(filteredUsers[indexPath.row])
    }
}
