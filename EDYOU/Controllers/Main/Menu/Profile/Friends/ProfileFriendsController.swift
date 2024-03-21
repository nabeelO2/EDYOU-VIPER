//
//  ProfileFriendsController.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 04/01/2022.
//

import UIKit

class ProfileFriendsController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    var adapter: ProfileFriendsAdapter!
    
    var friends = [User]()
    var user: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = ProfileFriendsAdapter(tableView: tableView)
        adapter.friends = friends
        adapter.searchedFriends = friends
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriends()
    }
    
    init(friends: [User], user: User) {
        self.user = user
        super.init(nibName: ProfileFriendsController.name, bundle: nil)
        
        self.friends = friends
    }
    required init?(coder: NSCoder) {
        self.user = User.nilUser
        super.init(coder: coder)
    }


}


// MARK: Web APIs
extension ProfileFriendsController {
    func getFriends() {
        APIManager.social.getFriends(userId: user.userID) { [weak self] friends, error in
            guard let self = self else { return }
            
            if error == nil {
                self.friends = (friends?.friends ?? []).sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") })
                
                self.adapter.friends = self.friends
                self.adapter.searchedFriends = self.adapter.friends
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoading = false
            self.tableView.reloadData()
            
        }
        
    }
}
