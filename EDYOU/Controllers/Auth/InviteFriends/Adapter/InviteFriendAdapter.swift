//
//  InviteFriendsAdapter.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

//import Foundation
//import UIKit
//
//class InviteFriendAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
//    
//    // MARK: - Properties
//    weak var tableView: UITableView!
//    
//    var parent: InviteFriendViewController? {
//        return tableView.viewContainingController() as? InviteFriendViewController
//    }
//    var navigationController: UINavigationController? {
//        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
//        return navC
//    }
//    
//    var people: [User] = []
//   
//    
//    // MARK: - Initializers
//    init(tableView: UITableView) {
//        super.init()
//        
//        self.tableView = tableView
//        configure()
//    }
//    
//    
//  
//}
//
//
//extension InviteFriendAdapter : AddFriendCellDelegate
//{
//    func addFriend(user: User, _ onSuccess: @escaping (Any) -> Void) {
//    
//        self.addFriendAPI(user: user) { success in
//            onSuccess(success)
//        }
//    }
//    
//  
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return people.count
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//         return 65
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendTableViewCell.identifier, for: indexPath) as! AddFriendTableViewCell
//        cell.setData(people[indexPath.row])
//        cell.delegate = self
//        return cell
//           
//    }
//}
