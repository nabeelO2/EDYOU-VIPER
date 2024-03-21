//
//  EventUsersController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit

class EventUsersController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var adapter: UsersListAdapter!
    var users = [User]()
    var type = Type.organisers
    
    enum `Type` {
        case organisers, participants, invited, going, interested, notGoing
        
        var name: String {
            switch self {
            case .organisers:   return "Organisers"
            case .participants:   return "Participants"
            case .invited:   return "Invited"
            case .going:   return "Going"
            case .interested:   return "Interested"
            case .notGoing:   return "Not Going"
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = type.name
        adapter = UsersListAdapter(tableView: tableView)
        adapter.users = users
    }
    
    init(type: Type, users: [User]) {
        super.init(nibName: EventUsersController.name, bundle: nil)
        
        self.type = type
        self.users = users
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
