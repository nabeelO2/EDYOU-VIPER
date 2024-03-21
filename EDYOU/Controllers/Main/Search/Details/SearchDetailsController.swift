//
//  SearchDetailsController.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit

class SearchDetailsController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
  
//    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tabContentView: UIView!
    @IBOutlet weak var viewIndicator: UIView!
    
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var cstStackViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var cstTableViewBottom: NSLayoutConstraint!
    
    @IBOutlet var tabViews: [UIView]!
    @IBOutlet weak var filterImageView: UIImageView!
    
    @IBOutlet var tabLabels: [UILabel]!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var topTabSelectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    var selectedTab = SearchType.posts
    var filters = [FilterOptions]()
    var suggestedFriends = [User]()
    var suggestedPeople = [User]()
    var suggestedEvents = [Event]()
    var suggestedGroups = [Group]()
    var suggestedPosts = [Post]()
    var viewModel : ReusableFiltersViewModel!
  
  
    
    var adapter: SearchDetailsAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
        adapter = SearchDetailsAdapter(tableView: tableView)
        adapter.isLoading = true

        getSuggestedPosts()
        getSuggestedPeople()
        getSuggestedGroups()
        getSuggestedEvents()
        getSuggestedFriends()
        selectTab(index: 0, animated: true, endEditing: true)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
      
        
        adapter.stopPreviousPlayingCellWithVideo {
            super.viewWillDisappear(animated)
        }
    
    }
    
    @objc func searchTextFieldDidChange(textField: UITextField) {
       
        if textField.text?.count ?? 0 > 0
        {
//            self.collectionView.isHidden = true
            adapter.isSearching = true
            adapter.reloadData()
            self.topTabSelectionViewHeightConstraint.constant = 0
            self.tableViewTopConstraint.constant = 10
            view.layoutIfNeeded(true)
        }
        else
        {
             search(textField.text ?? "")
        }
      
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstTableViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstTableViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }
    
    @IBAction func searchIconTouched(_ sender: Any) {
        txtSearch.becomeFirstResponder()
    }
    

}

extension SearchDetailsController {
    @IBAction func didTapTabButton(_ sender: UIButton) {
        self.filters.removeAll()
        adapter.stopPreviousPlayingCellWithVideo {
            self.selectTab(index: sender.tag, animated: true, endEditing: true)
        }

        
    }
    @IBAction func didTapClearButton(_ sender: Any) {
        view.endEditing(true)
        txtSearch.text = ""
        btnClear.isHidden = true
        cstStackViewTrailing.constant = 20
        view.layoutIfNeeded(true)
        search("")
    }
    @IBAction func didTapFilterButton(_ sender: UIButton) {
        var screenName = String()
        switch selectedTab {
        case .posts:
            screenName = "Filter Post"
          
        case .people:
            screenName = "Filter People"
           
        case .groups:
            screenName = "Filter Groups"
           
        case .events:
            screenName = "Filter Events"
           
        case .friends:
            screenName = "Filter Friends"
           
        case .friendRequests, .friendsSort:
            break
//        case .trending:
//            break
        }
        viewModel = ReusableFiltersViewModel()
        var requiredFilters = [FilterOptions]()
        if filters.count > 0 {
            requiredFilters = filters
        } else {
            requiredFilters = viewModel.getResultedOptions(layout: selectedTab)
        }
        let filters = ReusableOptionsFilterViewController(resultedOptions: requiredFilters, layout: selectedTab, previouslySelectedFilters: filters, screenName: screenName) { selected in
            self.filters = selected
        }
        self.presentPanModal(filters)
    }
}

extension SearchDetailsController : TabbarControllerProtocol{
    func tabbarDidSelect() {
       // tableView.scrollToTop()
       // self.tableView.reloadData()
//        self.tableView.beginUpdates()
       self.tableView.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
//        self.tableView.endUpdates()
    }
    
    
}

// MARK: Utility Methods
extension SearchDetailsController {
    
    func categorySelected(with selectedCategory: String)
    {
      
        switch selectedCategory
        {
//            case "Trending":
//                    self.collectionView.isHidden = false
//                    selectedTab = .trending
            case "Posts":  selectedTab = .posts
            case "People":  selectedTab = .people
            case "Groups":  selectedTab = .groups
            case "Events":  selectedTab = .events
            case "Friends": selectedTab = .friends
           default:
            break
        }
        let selectedIndex = (self.adapter.categoryList.firstIndex(of: selectedCategory) ?? 1)
        self.selectTab(index: selectedIndex, animated: true, endEditing: false)
        self.topTabSelectionViewHeightConstraint.constant = 26
        self.tableViewTopConstraint.constant = 0
        view.endEditing(true)
        view.layoutIfNeeded(true)
        adapter.isSearching = false
        adapter.reloadData()
        getData(type: selectedTab, searchedtext: txtSearch.text ?? "", filters: self.filters)
     
    }
    func search(_ text: String) {
        if text == "" {
            filterButton.isHidden = true
            self.topTabSelectionViewHeightConstraint.constant = 26
            self.tableViewTopConstraint.constant = 0
            view.layoutIfNeeded(true)
            adapter.isSearching = false
//            self.collectionView.isHidden = selectedTab != .trending
            adapter.reloadData()
            setDataForEmptyText()
            return
        }

        
     
//        self.collectionView.isHidden = selectedTab != .trending
        filterButton.isHidden = false
        adapter.reloadData()
     
        view.layoutIfNeeded(true)
        getData(type: selectedTab, searchedtext: txtSearch.text ?? "", filters: self.filters)
    }
    
    func selectTab(index: Int, animated: Bool,endEditing: Bool) {
        
        if endEditing {
            view.endEditing(true)
        }
        
        selectedTab = SearchType.with(index: index)
//        collectionView.isHidden = selectedTab != .trending
        
        for view in tabViews {
            if view.tag == index {
                view.isHidden = false
            } else {
                view.isHidden = true
            }
        }
        tabLabels.forEach { $0.textColor = R.color.sub_title() }
        let label = tabLabels.first { $0.tag == index }
        label?.textColor = R.color.buttons_green()
        cstViewIndicatorLeading.constant = (((tabContentView.width - 40) / CGFloat(tabLabels.count)) * CGFloat(index)) + 15
        cstViewIndicatorWidth.constant = (label?.width ?? 40) + 10
        
//        self.bottomBarLeadingConstraint.constant = self.notificationLabel.frame.origin.x
//        self.bottomBarWidth.constant = self.notificationLabel.frame.width
        view.layoutIfNeeded(animated)
        
        if txtSearch.text?.count ?? 0 > 0
        {
            search(txtSearch.text ?? "")
        }
        tableView.reloadData()
    }
    func setDataForEmptyText() {
        let text = (txtSearch.text ?? "").trimmed
        if text == "" {
            self.adapter.posts = suggestedPosts
            self.adapter.friends = suggestedFriends
            self.adapter.people = suggestedPeople
            self.adapter.groups = suggestedGroups
            self.adapter.events = suggestedEvents
            tableView.reloadData()
        }
    }
}


// MARK: - TextField Delegate
extension SearchDetailsController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        btnClear.isHidden = false
        cstStackViewTrailing.constant = 16
        view.layoutIfNeeded(true)
        adapter.stopPreviousPlayingCellWithVideo {
            
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.trimmed ?? "") == "" {
            textField.text = ""
            btnClear.isHidden = true
            adapter.isSearching = false
            cstStackViewTrailing.constant = 20
            view.layoutIfNeeded(true)
        }
    }
}



// MARK: - Web APIs
extension SearchDetailsController {
    func getData(type: SearchType, searchedtext text: String,filters: [FilterOptions]) {
        let filtersForAPI = self.filters.filter { option in
            return option.valueChanged
        }
        var filterParams = getFilterParams(filters: filtersForAPI)
        filterParams["q"] = text
        filterParams["search_type"] = type.rawValue
        APIManager.social.search(query: text, searchType: type,parameters: filterParams) { result, error in
            if error == nil {
                self.adapter.friends = result?.friends ?? []
                self.adapter.people = result?.people ?? []
                self.adapter.groups = result?.groups?.groups ?? []
                self.adapter.posts = result?.posts ?? []
                self.adapter.posts.setIsReacted()
                self.adapter.posts.updateMediaArray()
                self.adapter.events = result?.events?.events() ?? []
                
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
    }
    func getFilterParams(filters: [FilterOptions]) -> [String:Any] {
        var params = [String:Any]()
        for filter in filters {
            if filter.isSwitch {
                params[filter.title.lowercased().replacingOccurrences(of: " ", with: "_")] = filter.switchValue
            } else {
            params[filter.title.lowercased().replacingOccurrences(of: " ", with: "_")] =  filter.value
            }
        }
        return params
    }
    func getSuggestedFriends() {
        self.adapter.isLoading = true
        APIManager.social.getFriendsOnly { (friends, error) in
            self.adapter.isLoading = false
            if (error == nil) {
                self.suggestedFriends = friends
                self.setDataForEmptyText()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getSuggestedPeople() {
        self.adapter.isLoading = true
        APIManager.social.suggestion(type: .peoples) { (results, error) in
            self.adapter.isLoading = false
            if (error == nil) {
                self.suggestedPeople = results?.people ?? []
                self.setDataForEmptyText()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getSuggestedEvents() {
        self.adapter.isLoading = true
        APIManager.social.suggestion(type: .events) { (results, error) in
            self.adapter.isLoading = false
            if (error == nil) {
                self.suggestedEvents = results?.events?.events() ?? []
                self.setDataForEmptyText()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getSuggestedGroups() {
        self.adapter.isLoading = true
        APIManager.social.suggestion(type: .groups) { (results, error) in
            self.adapter.isLoading = false
            if (error == nil) {
                self.suggestedGroups = results?.groups?.groups ?? []
                self.setDataForEmptyText()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getSuggestedPosts() {
        self.adapter.isLoading = true
        
        APIManager.social.suggestion(type: .posts) { (results, error) in
            if (error == nil) {
                self.suggestedPosts = results?.posts ?? []
                self.suggestedPosts.setIsReacted()
                self.suggestedPosts.updateMediaArray()
                self.setDataForEmptyText()
                self.adapter.isLoading = false
            } else {
                self.adapter.isLoading = false
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    // MARK: - Get Reels Data
//    func loadReelsData(reload: Bool) {
//        self.handleViewLoading(enable: true)
//        APIManager.social.getReelsData(skip: reload ? 0 : self.adapter.reelsCount, limit: 100) { [weak self] reels, error, skip in
//            guard let self = self else { return }
//            if let error = error {
//                self.handleError(error: error)
//            } else {
//                if skip != 0 {
//                    var updateReels = self.adapter.reels
//                    updateReels.append(contentsOf: reels ?? [] )
//                    self.adapter.reels = updateReels
//                } else {
//
//                    self.adapter.reels = reels ?? []
//                }
//            }
//        }
//    }
}
