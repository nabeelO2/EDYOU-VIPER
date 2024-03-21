//
//  FriendsController.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

class FriendsController: BaseController {
    
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var cstTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedTabTitleLbl: UILabel!
    @IBOutlet weak var selectedTabHeader: UIView!
    @IBOutlet weak var sortBtn: UIButton!
    
    @IBOutlet var tabLabels: [UILabel]!
    var selectedTab = Tab.requests
    var filters = [FilterOptions]()
    var friendsCount = Int()
    
    enum Tab: Int {
        case requests, friends, suggestions
    }
    
    var adapter: FriendsAdapter!
    var tabsAdapter: FriendsTabAdapter!
    var sortFiltersAdapter : ReusableFiltersViewModel!
    
    var received = [User]()
    var friends = [User]()
    var sent = [User]()
    var suggestedPeople = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = FriendsAdapter(tableView: tableView,textField: txtSearch)
        tabsAdapter = FriendsTabAdapter(collectionView: collectionView)
        selectTab(index: 0, animated: false)
        getFriends()
        getSuggestedPeople()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
//        if frame.height > 0 {
//            cstTableViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
//        } else {
//            cstTableViewBottom.constant = 0
//        }
        view.layoutIfNeeded(true)
    }

}


// MARK: Actions
extension FriendsController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        viewSearch.showView()
    }
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        txtSearch.text = ""
        txtSearch.resignFirstResponder()
        btnClear.isHidden = true
        viewSearch.hideView()
        adapter.search("")
    }
    @IBAction func didTapInviteButton(_ sender: UIButton) {
        let controller = InviteFriendsController()
        controller.isLoggedIn = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        self.btnClear.isHidden = true
        adapter.search("")
    }
    @IBAction func didTapTabButton(_ sender: UIButton) {
        //selectTab(index: sender.tag, animated: true)
    }
    @IBAction func didTapSortBtn(_ sender: UIButton) {
        
        sortFiltersAdapter = ReusableFiltersViewModel()
        var requiredFilters = [FilterOptions]()
        var layout = SearchType.friendRequests
        switch selectedTab {
        case .requests:
            layout = .friendRequests
            requiredFilters = sortFiltersAdapter.getResultedOptions(layout: .friendRequests)
        case .friends:
            layout = .friendsSort
            requiredFilters = sortFiltersAdapter.getResultedOptions(layout: .friendsSort)
        case .suggestions:
            break
        }
        if !filters.isEmpty {
            requiredFilters = filters
        }
        let filters = ReusableOptionsFilterViewController(resultedOptions: requiredFilters, layout: layout, screenName: "") { selected in
            print(selected)
            self.filters = selected
            if self.selectedTab == .requests {
                self.adapter.sortRequests(filters: self.filters)
            }
        }
        self.presentPanModal(filters)
    }
    
}

// MARK: Utility Methods
extension FriendsController {
    func selectTab(index: Int, animated: Bool) {
        self.filters.removeAll()
        view.endEditing(true)
        selectedTab = Tab(rawValue: index) ?? .requests

        switch selectedTab {
        case .requests:
            self.selectedTabHeader.isHidden = false
            self.selectedTabTitleLbl.text = "Friend Requests"
            adapter.friends = received + sent
            adapter.searchedFriends = adapter.friends
            getFriends()
            break
        case .friends:
            self.selectedTabHeader.isHidden = false
            self.selectedTabTitleLbl.text = "\(self.friendsCount) Friends"
            adapter.friends = friends
            adapter.searchedFriends = adapter.friends
            getFriends()
            break
        case .suggestions:
            self.selectedTabHeader.isHidden = true
            adapter.friends = suggestedPeople
            adapter.searchedFriends = adapter.friends
            getSuggestedPeople()
            break
        }
        txtSearch.text = ""
        tableView.reloadData()
      
    }
}


//// MARK: TextField Delegate
//extension FriendsController: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
//        btnClear.isHidden = expectedText.count == 0
//        adapter.search(expectedText)
//        return true
//
//    }
//}

// MARK: Web APIs
extension FriendsController {
    func getFriends() {
        APIManager.social.getFriends { [weak self] friends, error in
            guard let self = self else { return }
            
            if error == nil {
                self.txtSearch.text = ""
                
                
                let r = (friends?.pendingFriends ?? []).filter { $0.requestOrigin == "received" }
                let s = (friends?.pendingFriends ?? []).filter { $0.requestOrigin == "sent" }
                
                var receiverUser = Set<String>()
                let receiverUsers = r.filter {
                    receiverUser.insert($0.userID ?? "").inserted
                }
                receiverUser.removeAll()
                let sentUsers = s.filter {
                    receiverUser.insert($0.userID ?? "").inserted
                }
                
                self.received = receiverUsers.sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") })
                self.sent = sentUsers.sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") })
                self.friends = (friends?.friends ?? []).sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") })
                self.friendsCount = self.friends.count
                
                if self.selectedTab == .friends {
                    self.adapter.friends = self.friends
                } else if self.selectedTab == .requests {
                    self.adapter.friends = self.received + self.sent
                } else {
                    self.adapter.friends = self.sent
                }
                self.adapter.searchedFriends = self.adapter.friends
                Cache.shared.frinedDict = (self.friends + self.received + self.sent).reduce(into: Cache.shared.frinedDict) { result, user in
                    result["\(user.userID ?? "")@ejabberd.edyou.io"] = [user.name?.completeName ?? user.formattedUserName,user.profileImage ?? ""]
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoading = false
            self.tableView.reloadData()
            
        }
        
    }
    func getSuggestedPeople() {
        APIManager.social.suggestion(type: .peoples) { (results, error) in
            if (error == nil) {
                self.suggestedPeople = results?.people ?? []
                self.adapter.requestSents.removeAll()
                self.adapter.searchedFriends = self.suggestedPeople
                Cache.shared.frinedDict = (results?.people ?? []).reduce(into: Cache.shared.frinedDict) { result, user in
                    result["\(user.userID ?? "")@ejabberd.edyou.io"] = [user.name?.completeName ?? user.formattedUserName,user.profileImage ?? ""]
                }
                self.adapter.tableView.reloadData()
                //self.setDataForEmptyText()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}
