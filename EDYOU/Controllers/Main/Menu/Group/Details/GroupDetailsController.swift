//
//  GroupDetailsController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit

class GroupDetailsController: BaseController {

    @IBOutlet weak var groupCoverPhoto: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var adapter: GroupDetailsAdapter!
    var group: Group
    var loading = false
    var loadAPIsInGroups = false
    var shouldCallInvite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = GroupDetailsAdapter(tableView: tableView, group: group)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDetails()
    }
    
    init(group: Group) {
        self.group = group
        super.init(nibName: GroupDetailsController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.group = Group()
        super.init(coder: coder)
    }
    
    func loadDataOnScrollEnd() {
        if loading == false {
            print("LoadDataOnScrollEnd")
            getPosts(limit: 10, reload: false)
        }
    }
}


extension GroupDetailsController {
    func didTapBackButton() {
        if loadAPIsInGroups {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadApiAfterGroupJoin"), object: nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapMoreButton(){
        let isAdmin = group.groupAdmins?.contains(where: { $0.userID == Cache.shared.user?.userID }) ?? false
        let isMember = group.groupMembers?.contains(where: { $0.userID == Cache.shared.user?.userID }) ?? false
        let adminOptions = ["Edit", "Manage"]
        let adminOptionsImages = ["edit-group", "icon-settings"]
        
        let memberOptions = ["Leave group", "Add to Favorite"]
        let memberOptionsImages = ["icon-leave", "save"]
        
        let nonmemberOptions = ["Reject Invite"]
        let nonmemberOptionsImages = ["icon-leave"]
        
        if isAdmin {
            let controller = GroupManageOptionsController(options: adminOptions, optionImages: adminOptionsImages, screenName: "", completion: { selected in
                if (selected == "Edit") {
                    self.adapter.didTapEditButton()
                } else {
                    let navC = self.navigationController
                    let controller = ManageGroupController(group: self.group)
                    navC?.pushViewController(controller, animated: true)
                }
            })
            
            self.presentPanModal(controller)
        } else if isMember {
            let controller = GroupManageOptionsController(options: memberOptions, optionImages: memberOptionsImages, screenName: "", completion: { selected in
                if (selected == "Leave group") {
                    self.adapter.leaveGroup()
                } else {
                    self.adapter.manageGroupFavorites()
                }
            })
            
            self.presentPanModal(controller)
        }
        else{
            let controller = GroupManageOptionsController(options: nonmemberOptions, optionImages: nonmemberOptionsImages, screenName: "", completion: { selected in
                if (selected == "Reject Invite") {
                    self.adapter.rejectInvite()
                }
            })
            
            self.presentPanModal(controller)

        }
    }
}


// MARK: - Web APIs
extension GroupDetailsController {
    //f0bee5cf81154acbb3d85362f39afabf
    func getDetails() {
        guard  let id = group.groupID else { return }
        APIManager.social.getGroupDetails(groupId: id) { group, error in
            self.parent?.stopLoading()
            if let error = error {
                self.showErrorWith(message: error.message)
                self.adapter.isLoading = false
                return
            }
            guard let group = group else {
                return
            }
            self.group = group
            self.adapter.group = group
            self.loadPostsIfJoined()
            self.tableView.reloadData()
        }
    }
    
    func loadPostsIfJoined() {
        if group.allowedToDisplayPosts() {
            self.getPosts()
        } else {
            self.adapter.isLoading = false
        }
    }
    
    func favorite(groupId: String) {
        APIManager.social.addToFavorite(type: .groups, id: groupId) { [weak self] error in
            if error == nil {
                self?.group.isFavorite = true
            } else {
                self?.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(groupId: String) {
        APIManager.social.removeFromFavorite(type: .groups, id: groupId) { [weak self] error in
            if error == nil {
                self?.group.isFavorite = false
            } else {
                self?.showErrorWith(message: error!.message)
            }
        }
    }
    
    func getPosts(limit: Int = 10, reload: Bool = true) {
        loading = true
        APIManager.social.getHomePosts(groupId: group.groupID ?? "", postType: .groups, skip: reload ? 0 : adapter.postCount, limit: limit) { [weak self] posts, error in
            guard let self = self else { return }
            self.adapter.isLoading = false
            self.loading = false
            if error == nil {
                if reload {
                    self.adapter.reloadData(posts: posts?.posts ?? [], total: posts?.total ?? 0, isUpdate: false)
                } else {
                    self.adapter.reloadData(posts: posts?.posts ?? [], total: posts?.total ?? 0, isUpdate: true)
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
}

