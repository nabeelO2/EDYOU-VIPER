//
//  GroupMemberRequestsController.swift
//  EDYOU
//
//  Created by  Mac on 29/09/2021.
//

import UIKit

class GroupMemberRequestsController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerCollectionView: UICollectionView!
    var adapter: GroupMemberRequestsAdapter!
    var group: GroupAdminData
    var selectedTab = GroupMembersHeaderType.received
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = GroupMemberRequestsAdapter(tableView: tableView, group: group,collectionView: headerCollectionView)
        getData()
    }
    
    init(group: GroupAdminData) {
        self.group = group
        super.init(nibName: GroupMemberRequestsController.name, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        self.group = GroupAdminData()
        super.init(coder: coder)
    }
    
}

// MARK: Actions
extension GroupMemberRequestsController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Web APIs
extension GroupMemberRequestsController {
    func getData() {
        guard  let id = group.groupID else { return }
        APIManager.social.getAdminData(groupId: id) { [weak self] data, error in
            guard let self = self else { return }
            
            if error == nil, let d = data {
                if d.received?.count ?? 0 > 0 {
                    let pendingMemberRequests = d.received!.filter { user in
                        if let groupMemberStatus = user.groupMemberStatus {
                            let memberStatus = GroupMemberStatus(rawValue: groupMemberStatus ) ?? .waiting_for_admin_approval
                            switch memberStatus {
                            case .waiting_for_admin_approval, .waiting_for_my_approval:
                                return true
                            case .joined_via_invite, .joined_by_me, .rejected_by_admin, .defaultState:
                                return false
                            }
                        }
                        return false
                    }
                    d.pending = pendingMemberRequests
                }
                self.group = d
                self.adapter.group = d
                self.tableView.reloadData()
            } else {
                self.showErrorWith(message: error?.message ?? "Something went wrong")
            }
        }
    }
}
