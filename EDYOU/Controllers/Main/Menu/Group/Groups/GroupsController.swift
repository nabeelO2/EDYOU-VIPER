//
//  GroupsController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit

class GroupsController: BaseController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var groupFeedHeaderView: UIView!
    @IBOutlet weak var myGroupsHeaderView: UIView!
    @IBOutlet weak var lblSelectedGroupType: UILabel!
    @IBOutlet weak var groupsTableView: UITableView!
    
    var adapter: GroupsAdapter!
    
    enum GroupType: Int {
        case my, joined, invited, pending, `public`, newsFeed
        
        var noResultsTitle: String {
            switch self {
            case .my:       return "No Groups"
            case .joined:   return "No Groups"
            case .invited:  return "No Invite(s)"
            case .pending:  return "No Groups"
            case .public:   return "No Group feed"
            case .newsFeed: return "No Group newsfeed"
            }
        }
        
        var noResultsDescription: String {
            switch self {
            case .my:       return "You have no Group in list"
            case .joined:   return "You have no Group in list"
            case .invited:  return "You have no Group invites for now"
            case .pending:  return "You have no Group in list"
            case .public:   return "You have no Group feed in list"
            case .newsFeed:   return "You have no Group newsfeed in list"
            }
        }
    }
    
    var selectedFilter: Filter = .my
    var options = ["My Groups", "My joined Groups", "My Groups invitations", "My pending Groups"]
    
    enum Filter: String {
        case my, joined, invitations, pending
        
        var name : String {
            switch self {
            case .my: return "Groups"
            case .joined: return "Joined Groups"
            case .invitations: return "Groups invitations"
            case .pending: return "Pending Groups"
            }
        }
        
        var selectedOption : String {
            switch self {
            case .my: return "My Groups"
            case .joined: return "My joined Groups"
            case .invitations: return "My Groups invitations"
            case .pending: return "My pending Groups"
            }
        }
    }
    
    var myGroups = [Group]()
    var jointedGroups = [Group]()
    var invitedGroups = [Group]()
    var pendingGroups = [Group]()
    var suggestedPublicGroups = [Group]()
    var selectedTab = GroupType.newsFeed
    var loadApis = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
        AppDefaults.shared.groupFilterOption = ""
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ReloadApiAfterGroupCreation"), object: nil, queue: nil) { notification in
            if let dict = notification.userInfo as NSDictionary? {
                       if let shouldShowMyGroups = dict["shouldShowMyGroups"] as? Bool{
                           self.getGroups(shouldShowMyGroup: shouldShowMyGroups)
                           self.getSuggestedGroups()
                       }
            }
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ReloadApiAfterGroupJoin"), object: nil, queue: nil) { notification in
            self.loadApis = true            
        }
        
        
        adapter = GroupsAdapter(collectionView: collectionView, tableView: groupsTableView, didRemove: { [weak self] group, action in
            guard let self = self else { return }
            
            if self.selectedTab == .my {
                if let index = self.pendingGroups.firstIndex(where: { $0.groupID == group.groupID }), index >= 0 {
                    self.pendingGroups.remove(at: index)
                }
                
                if action == .accepted {
                    let isContain = self.jointedGroups.contains { $0.groupID == group.groupID }
                    if isContain == false {
                        if group.privacy == "private"{
                            self.pendingGroups.insert(group, at: 0)
                        } else {
                        self.jointedGroups.insert(group, at: 0)
                        }
                    }
                }
            }
            self.getSuggestedGroups()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (loadApis) {
            loadApis = false
            getPosts(limit: 10, reload: true)
            getGroups()
            getSuggestedGroups()
        } else if self.selectedTab == .newsFeed {
            getPosts(limit: 10, reload: true)
        }
    }
}


extension GroupsController {
    func loadDataOnScrollEnd() {
        if adapter.isLoading == false {
            print("LoadDataOnScrollEnd")
            getPosts()
        }
    }
    
    func changeTableDesign(selectedTab: GroupType) {
        if (selectedTab == .newsFeed) {
            self.groupFeedHeaderView.isHidden = false
            self.myGroupsHeaderView.isHidden = true
            getPosts(limit: 10, reload: true)
            adapter.groups = myGroups
        } else if selectedTab == .public {
            self.groupFeedHeaderView.isHidden = true
            self.myGroupsHeaderView.isHidden = true
            self.getSuggestedGroups(refreshTable: true)
            adapter.groups = suggestedPublicGroups
            
        }else {
            self.groupFeedHeaderView.isHidden = true
            self.myGroupsHeaderView.isHidden = false
            self.getGroups(shouldShowMyGroup:true)
            adapter.groups = myGroups
            //adapter.groups = myGroups + jointedGroups
        }
        
        self.selectedTab = selectedTab
        adapter.groupType = selectedTab
        adapter.search(txtSearch.text ?? "")
        self.groupsTableView.reloadData()
        self.collectionView.reloadData()
    }
    
    func selectTab(index: Int) {
        selectedTab = GroupType(rawValue: index) ?? .my
        
        switch selectedTab {
        case .my:
            adapter.groups = myGroups
        case .joined:
            adapter.groups = jointedGroups
        case .invited:
            adapter.groups = invitedGroups
        case .pending:
            adapter.groups = pendingGroups
        case .public:
            adapter.groups = suggestedPublicGroups
        case .newsFeed:
            break
        }
        adapter.groupType = selectedTab
        adapter.search(txtSearch.text ?? "")
        self.groupsTableView.reloadData()
    }

    @IBAction func didTapEventsChoiceButton(_ sender: UIButton) {
        // show user choice filters
        let previousSelectedOption = self.selectedFilter.selectedOption
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "My Groups", completion: { selected in
            if (selected == "My Groups") {
                self.selectedFilter = .my
                self.lblSelectedGroupType.text = self.selectedFilter.name
                self.adapter.groups = self.myGroups
                self.adapter.searchedGroups = self.myGroups
            } else if (selected == "My joined Groups") {
                self.selectedFilter = .joined
                self.lblSelectedGroupType.text = self.selectedFilter.name
                self.adapter.groups = self.jointedGroups
            } else if (selected == "My Groups invitations") {
                self.selectedFilter = .invitations
                self.lblSelectedGroupType.text = self.selectedFilter.name
                self.adapter.groups = self.invitedGroups
            } else if (selected == "My pending Groups") {
                self.selectedFilter = .pending
                self.lblSelectedGroupType.text = self.selectedFilter.name
                self.adapter.groups = self.pendingGroups
            }
            
            self.adapter.search(self.txtSearch.text ?? "")
            self.adapter.tableView.reloadData()
        })
        
        self.presentPanModal(userEventFilter)
    }
    
    @IBAction func didTapFeedHeaderFilterButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapMyGroupHeaderFilterButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapCreateButton(_ sender: UIButton) {
        let controller = CreateGroupController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        txtSearch.becomeFirstResponder()
        viewSearch.showView()
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        view.endEditing(true)
        viewSearch.hideView()
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")

    }
    
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")
    }
}

// MARK: TextField Delegate
extension GroupsController: UITextFieldDelegate {
    @objc func searchTextFieldDidChange(textField: UITextField) {
        self.adapter.search(textField.text ?? "")
    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
//        btnClear.isHidden = expectedText.count == 0
//        adapter.search(expectedText)
//        return true
//
//    }
}


extension GroupsController {
    func getGroups(shouldShowMyGroup: Bool = false) {
        APIManager.social.getGroups { [weak self] my, joined, invited, pending, error in
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            if error == nil {
                self.myGroups = my
                self.jointedGroups = joined
                self.invitedGroups = invited
                self.pendingGroups = pending
                self.selectTab(index: self.selectedTab.rawValue)
                self.adapter.groups = my
               // self.adapter.groups = my + joined
                self.adapter.search(self.txtSearch.text ?? "")
                if shouldShowMyGroup{
                    if self.selectedTab != .my {
                    self.changeTableDesign(selectedTab: .my)
                    }
                } else {
                self.changeTableDesign(selectedTab: .newsFeed)
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            self.groupsTableView.reloadData()
        }
    }
    func getSuggestedGroups(refreshTable: Bool = false) {
        APIManager.social.suggestion(type: .groups) { (results, error) in
            if (error == nil) {
                self.suggestedPublicGroups = results?.groups?.groups ?? []
                //self.adapter.groups = self.suggestedPublicGroups
                if refreshTable{
                    self.adapter.groups = self.suggestedPublicGroups
                    self.adapter.searchedGroups = self.adapter.groups
                    self.groupsTableView.reloadData()
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
    }
    func getPosts(limit: Int = 10, reload: Bool = false) {
        self.adapter.isLoading = true
        
        APIManager.social.getHomePosts(postType: .groups, skip: reload ? 0 : adapter.posts.count, limit: limit) { [weak self] posts, error in
            guard let self = self else { return }
            self.adapter.isLoading = false
            if error == nil {
                if reload {
                    self.adapter.posts = posts?.posts ?? []
                    self.adapter.filteredPosts = self.adapter.posts
                } else {
                    self.adapter.posts.updateRecord(with: posts?.posts ?? [])
                    self.adapter.filteredPosts = self.adapter.posts
                }
                self.adapter.totalRecord = posts?.total ?? 0
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.groupsTableView.reloadData()
        }
    }
}
