//
//  ManageGroupController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit

class ManageGroupController: BaseController {
    @IBOutlet weak var lblPendingPosts: UILabel!
    @IBOutlet weak var lblMemberRequests: UILabel!
    
    var group: Group
    var groupData: GroupAdminData?
    var isAllInviteFriendRequestSucceded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDetails()
        getAdminData()
    }
    
    init(group: Group) {
        self.group = group
        super.init(nibName: ManageGroupController.name, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        self.group = Group()
        super.init(coder: coder)
    }
}

// MARK: - Actions
extension ManageGroupController {
    
    @IBAction func didTapBackButton(_ sender: Any) {
        goBack()
    }
   
    @IBAction func didTapPendingPostsButton(_ sender: UIButton) {
        guard let data = groupData else { return }
        let controller = PendingPostsController(group: data)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapMemberRequestsButton(_ sender: UIButton) {
        guard let data = groupData else { return }
        let controller = GroupMemberRequestsController(group: data)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapInviteButton(_ sender: UIButton) {
        guard let id = group.groupID else { return }
        let controller = SelectFriendsController(groupId: id, type: .notJoined) { [weak self] users in
            guard let self = self else { return }

            self.inviteFriends(friends: users) {
            }
        }
        
        controller.modalPresentationStyle = .fullScreen
        self.parent?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Group", message: "Are you sure you want to delete the Group?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deleteGroup()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: - Utility Methods
extension ManageGroupController {
    func setData() {
        guard let data = groupData else { return }
        
        lblPendingPosts.text = "\(data.pendingPosts?.count ?? 0)"
        if data.received?.count ?? 0 > 0 {
            let pendingMemberRequests = data.received!.filter { user in
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
            data.pending = pendingMemberRequests
            lblMemberRequests.text = "\(data.pending?.count ?? 0)"
        } else {
            lblMemberRequests.text = "0"
        }
    }
}

// MARK: - Web APIs
extension ManageGroupController {
    func getDetails() {
        guard  let id = group.groupID else { return }
        APIManager.social.getGroupDetails(groupId: id) { [weak self] group, error in
            guard let self = self else { return }
            
            if error == nil, let g = group {
                self.group = g
                self.setData()
            }
        }
    }
    
    func getAdminData() {
        guard  let id = group.groupID else { return }
        APIManager.social.getAdminData(groupId: id) { [weak self] data, error in
            guard let self = self else { return }
            
            if error == nil {
                self.groupData = data
                self.setData()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func deleteGroup() {
        guard  let id = group.groupID else { return }
        self.startLoading(title: "Deleting Group...")
        APIManager.social.deleteGroup(groupId: id) { error in
            self.stopLoading()
            let showMyGroups:[String: Bool] = ["shouldShowMyGroups": true]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadApiAfterGroupCreation"), object: nil, userInfo: showMyGroups)
            self.popBack(3)
        }
    }
    
    func inviteFriends(friends: [User], completion: @escaping () -> Void) {
        isAllInviteFriendRequestSucceded = true
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        
        let group = DispatchGroup()
        for f in friends {
            group.enter()
            operationQueue.addOperation {
                self.inviteFriend(friend: f) {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if self.isAllInviteFriendRequestSucceded {
                self.showSuccessMessage(message: "Successfully invited")
            }
            completion()
        }
    }
    
    func inviteFriend(friend: User, completion: @escaping () -> Void) {
        print("Called for user Id: \(String(describing: friend.userID))")
        
        guard let groupId = group.groupID else { return }
        APIManager.social.inviteFriend(groupId: groupId, userId: friend.userID!) { error in
            if error != nil {
                self.isAllInviteFriendRequestSucceded = false
                self.showErrorWith(message: error!.message)
            }
            completion()
        }
    }
}
