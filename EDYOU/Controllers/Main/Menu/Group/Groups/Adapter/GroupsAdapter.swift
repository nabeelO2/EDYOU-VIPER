//
//  
//  GroupsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//
//

import UIKit
//import EmptyDataSet_Swift

class GroupsAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    weak var tableView: UITableView!
    
    var parent: GroupsController? {
        return collectionView.viewContainingController() as? GroupsController
    }
    var isLoading = true
    var groups = [Group]()
    var searchedGroups = [Group]()
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    var totalRecord: Int = -1
    var groupType = GroupsController.GroupType.my
    weak var delegate: PostCellActions?
    weak var factoryDelegate: PostFactoryActions?
    var cellHeightDictionary = NSMutableDictionary()
    
    enum GroupAction {
        case accepted, rejected
    }
    var didRemove: ((_ group: Group, _ action: GroupAction) -> Void)?
    var groupCategories = ["Filter", "Groups", "Browse"]
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, tableView: UITableView, delegate: PostCellActions? = nil, factoryDelegate: PostFactoryActions? = nil, didRemove: @escaping (_ group: Group, _ action: GroupAction) -> Void) {
        super.init()
        
        self.delegate = delegate
        self.factoryDelegate = factoryDelegate
        self.didRemove = didRemove
        self.tableView = tableView
        self.collectionView = collectionView
        configure()
    }
    
    func configure() {
        collectionView.register(EventsSubNavBarCellItem.nib, forCellWithReuseIdentifier: EventsSubNavBarCellItem.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.register(NewGroupCell.nib, forCellReuseIdentifier: NewGroupCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(NoPostsCell.nib, forCellReuseIdentifier: NoPostsCell.identifier)
        tableView.register(NoMorePostCell.nib, forCellReuseIdentifier: NoMorePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
    }
    
    func search(_ text: String) {
        
        //        cellHeightDictionary = NSMutableDictionary()
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            if parent?.selectedTab == .public {
                self.searchGroupsOnline(type: .groups, searchedtext: t)
            } else if parent?.selectedTab == .my {
                let f = groups.filter { $0.groupName?.lowercased().contains(t) == true }
                self.searchedGroups = f
            }
        } else {
            self.searchedGroups = groups
        }
        
        self.tableView.reloadData()
        
        
        
    }
    func searchGroupsOnline(type: SearchType, searchedtext text: String) {
        var params = [String: Any]()
        params["q"] = text
        params["search_type"] = type.rawValue
        APIManager.social.search(query: text, searchType: type,parameters: params) { result, error in
            if error == nil {
                self.searchedGroups = result?.groups?.groups ?? []
            } else {
                self.parent?.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
        }
    }
}


// MARK: - Actions
extension GroupsAdapter {
    @objc func didTapAcceptButton(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? GroupCell, let group = searchedGroups.object(at: sender.tag), let groupId = group.groupID {
            cell.activityIndicator.startAnimating()
            cell.viewAcceptReject.isHidden = true
            cell.layoutIfNeeded(true)
            
            parent?.view.isUserInteractionEnabled = false
            acceptInvitation(groupId: groupId) { [weak self] error in
                self?.parent?.view.isUserInteractionEnabled = true
                
                cell.activityIndicator.stopAnimating()
                cell.layoutIfNeeded()
                
                if error == nil {
                    if let index = self?.searchedGroups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                        self?.searchedGroups.remove(at: index)
                    }
                    if let index = self?.groups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                        self?.groups.remove(at: index)
                    }
                    self?.tableView.reloadData()
                    self?.didRemove?(group, .accepted)
                }
            }
        }
    }
    
    @objc func didTapRejectButton(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? GroupCell, let group = searchedGroups.object(at: sender.tag), let groupId = group.groupID {
            cell.activityIndicator.startAnimating()
            cell.viewAcceptReject.isHidden = true
            parent?.view.layoutIfNeeded(true)
            
            parent?.view.isUserInteractionEnabled = false
            rejectInvitation(groupId: groupId) { [weak self]  error  in
                self?.parent?.view.isUserInteractionEnabled = true
                
                cell.activityIndicator.stopAnimating()
                cell.layoutIfNeeded()
                
                if error == nil {
                    if let index = self?.searchedGroups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                        self?.searchedGroups.remove(at: index)
                    }
                    if let index = self?.groups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                        self?.groups.remove(at: index)
                    }
                    self?.collectionView.reloadData()
                    self?.didRemove?(group, .rejected)
                }
            }
        }
    }
}

// MARK: - CollectionView DataSource and Delegates
extension GroupsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        if (parent?.selectedTab == .my || parent?.selectedTab == .public) {
            if (searchedGroups.count == 0) {
                  tableView.addEmptyView(groupType.noResultsTitle, groupType.noResultsDescription, EmptyCellConfirguration.group.image)
                return 0
            } else {
                return isLoading ? 4 : searchedGroups.count
            }
        } else {
            tableView.restore()
            if filteredPosts.count == 0 {
                tableView.addEmptyView(groupType.noResultsTitle, groupType.noResultsDescription, EmptyCellConfirguration.group.image)
            }
            if isLoading {
                return 10
            }
            return filteredPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (parent?.selectedTab == .my) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
            if (isLoading) {
                cell.beginSkeltonAnimation()
            } else {
                cell.setData(searchedGroups[indexPath.row])
            }
            if (parent?.selectedFilter == .invitations) {
                cell.joinGroupView.isHidden = false
                cell.joinedGroupActivityView.isHidden = true
                cell.btnJoinGroup.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
                cell.btnJoinGroup.tag = indexPath.row
            } else {
                cell.btnViewGroupActivity.addTarget(self, action: #selector(showGroupDetailTapped), for: .touchUpInside)
                cell.btnViewGroupActivity.tag = indexPath.row
            }
            return cell
        } else if parent?.selectedTab == .public {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
            
            if (isLoading) {
                cell.beginSkeltonAnimation()
            } else {
                cell.setData(searchedGroups[indexPath.row])
            }
            
            let group: Group?
            if (indexPath.row >= 0 && searchedGroups.count > indexPath.row) {
                 group = searchedGroups[indexPath.row]
            } else {
                return cell
            }

            if let groupRequestMembers = group?.requestMembers {
                if !groupRequestMembers.contains(where: { reqMember in
                    if reqMember.userID == Cache.shared.user?.userID {
                        return true
                    } else {
                        return false
                    }
                }) {
                    if let groupMembers = group?.groupMembers {
                        if !groupMembers.contains(userId: Cache.shared.user?.userID ?? ""){
                            cell.joinGroupView.isHidden = false
                            cell.joinedGroupActivityView.isHidden = true
                            cell.btnJoinGroup.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
                            cell.btnJoinGroup.tag = indexPath.row
                        }
                    }
                }
            }
            return cell
        } else {
            
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
                cell.beginSkeltonAnimation()
                return cell
            }
            
            if self.filteredPosts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoPostsCell.identifier, for: indexPath) as! NoPostsCell
                return cell
            }
            let post = filteredPosts.object(at: indexPath.row)
            if (post?.medias.count ?? 0) > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier, for: indexPath) as! ImagePostCell
                let dimenstion = post?.medias.first?.url.getDimenstions()
                let w = Double(dimenstion?.0 ?? 0)
                let h = Double(dimenstion?.1 ?? 0)
                print(dimenstion)
                let ratio = h > 0 ? Double(h / w) : Double(1.1)
                let width = Double(parent?.view.frame.width ?? tableView.frame.width)
                var height =  width * ratio
                if height == 0 {
                    height = width * 1.1
                }
//                cell.setCVDimenstion(height, width)
//                cell.collectionVW.constant = width
                cell.collectionVH.constant = height
                cell.setData(post)
                cell.indexPath = indexPath
                cell.btnMore.tag = indexPath.row
                cell.btnProfile.tag = indexPath.row
                cell.btnGroupName.tag = indexPath.row
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                cell.actionDelegate = self
                return cell
            } else if post?.isBackground == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextWithBgPostCell.identifier, for: indexPath) as! TextWithBgPostCell
                cell.setData(post)
                cell.indexPath = indexPath
                cell.actionDelegate = self
                cell.btnMore.tag = indexPath.row
                cell.btnProfile.tag = indexPath.row
                cell.btnGroupName.tag = indexPath.row
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            cell.setData(post)
            cell.indexPath = indexPath
            cell.actionDelegate = self
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (parent?.selectedTab == .my || parent?.selectedTab == .public) {
            return isLoading ? 260 : UITableView.automaticDimension
        } else {
            if isLoading {
                return 260
            }
            if let d = cellHeightDictionary.object(forKey: indexPath) as? NSDictionary, let height = d["height"] as? CGFloat, let id = d["id"] as? String, id == filteredPosts.object(at: indexPath.row)?.postID {
                print("Height: \(height) - index: \(indexPath.row)")
                return height
            }
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !(parent?.selectedTab == .my || parent?.selectedTab == .public) {
            if isLoading == false {
                let d: NSDictionary = [
                    "height": cell.frame.height,
                    "id": filteredPosts.object(at: indexPath.row)?.postID ?? ""
                ]
                cellHeightDictionary.setObject(d, forKey: indexPath as NSCopying)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if parent?.selectedTab != .newsFeed {
            if let g = searchedGroups.object(at: indexPath.row), isLoading == false {
                let controller = GroupDetailsController(group: g)
                if parent?.selectedTab == .my && parent?.selectedFilter == .invitations {
                    controller.shouldCallInvite = true
                }
                parent?.navigationController?.pushViewController(controller, animated: true)
            }
        }else {
            if let post = filteredPosts.object(at: indexPath.row) {
                self.showPostDetail(post: post, comment: nil)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (parent?.selectedTab == .newsFeed && AppDefaults.shared.groupFilterOption == "") {
            if scrollView == tableView {
                let offsetYBottom = tableView.contentOffset.y + tableView.frame.height
                if offsetYBottom >= (tableView.contentSize.height - 260) && posts.count < totalRecord {
                    parent?.loadDataOnScrollEnd()
                }
            }
        }
    }
    
    @objc func joinGroupTapped(_ sender: UIButton) {
        if (parent?.selectedTab == .my || parent?.selectedTab == .public) {
            if let groupId = searchedGroups[sender.tag].groupID, let group = self.searchedGroups.object(at: sender.tag) {
                acceptInvitation(groupId: groupId) { [weak self] error in
                    self?.parent?.view.isUserInteractionEnabled = true
                    
                    
                    if error == nil {
                        if self?.parent?.selectedTab == .my{
                            if let index = self?.searchedGroups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                                self?.searchedGroups.remove(at: index)
                                if let index = self?.groups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                                    self?.groups.remove(at: index)
                                    self?.didRemove?(group, .accepted)
                                    self?.tableView.reloadData()
                                }
                            }
                        } else if self?.parent?.selectedTab == .public {
                            if group.privacy == "private" {
                                self?.parent?.pendingGroups.insert(group, at: 0)
                            } else {
                                self?.parent?.jointedGroups.insert(group, at: 0)
                            }
                            self?.parent?.getSuggestedGroups(refreshTable: true)
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    @objc func showGroupDetailTapped(_ sender: UIButton) {
        if (parent?.selectedTab == .my) {
            if let g = searchedGroups.object(at: sender.tag), isLoading == false {
                let controller = GroupDetailsController(group: g)
                parent?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @objc func didTapProfileButton(_ sender: UIButton) {
        guard let user = filteredPosts.object(at: sender.tag)?.user else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let post = filteredPosts.object(at: sender.tag) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        if post.user?.isMe == true {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
                let indexPath = IndexPath(row: sender.tag, section: 1)
                self.deletePost(post: post, indexPath: indexPath)
                
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                
            }))
        }
        alert.addAction(UIAlertAction(title: post.isFavourite == true ? "Remove from Favourite" : "Add to Favourite", style: .default, handler: { _ in
            if post.isFavourite == true {
                self.unfavorite(postId: post.postID)
            } else {
                self.favorite(postId: post.postID)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parent?.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapGroupButton(_ sender: UIButton) {
        guard let post = filteredPosts.object(at: sender.tag), let groupID = post.groupInfo?.groupID else { return }
        
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
    }
}


extension GroupsAdapter : PostCellActions {
    func manageFavorites(indexPath: IndexPath, postId: String) {
        let post = self.posts[indexPath.row]
        let isFavorite = post.isFavourite ?? false
        if isFavorite {
            self.unfavorite(postId: postId)
        } else {
            self.favorite(postId: postId)
        }
    }
    
    func showAllReactions(indexPath: IndexPath, postId: String) {
        APIManager.social.getPostDetails(postId: postId) { post, error in
            if let error = error {
                self.parent?.showErrorWith(message: error.message)
            } else {
                self.parent?.showAllReactions(emojis: post?.reactions ?? [])
            }
        }
    }
    
    func showReactionPanel(indexPath: IndexPath, postId: String) {
        if let d = cellHeightDictionary.object(forKey: indexPath) as? NSDictionary, let id = d["id"] as? String, id == postId {
            cellHeightDictionary.removeObject(forKey: indexPath)
        }
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.setNeedsDisplay()
            tableView.endUpdates()
        }
    }
    
    func tapOnReaction(indexPath: IndexPath, reaction: String) {
        guard let post = filteredPosts.object(at: indexPath.row) else { return }
        guard let cell = self.tableView.cellForRow(at: indexPath) as? PostCell else { return }
        if reaction.isEmpty {
            self.parent?.showEmojiController(completion: { selectedEmoji in
                self.handleEmojiSelection(post: post, indexPath: indexPath, reaction: selectedEmoji, cell: cell)
            })
        } else {
            self.handleEmojiSelection(post: post, indexPath: indexPath, reaction: reaction, cell: cell)
        }
    }
    
    func tapOnComments(indexPath: IndexPath, comment: String?) {
        guard let post = filteredPosts.object(at: indexPath.row) else { return }
        self.showPostDetail(post: post, comment: comment)
    }
    
    private func showPostDetail(post : Post, comment: String?) {
        let controller = PostDetailsController(post: post, prefilledComment: comment)
        parent?.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleEmojiSelection(post: Post, indexPath: IndexPath, reaction: String,cell: PostCell) {
        var addEmoji = true
        if let myReaction = post.myReaction?.likeEmotion {
            self.filteredPosts[indexPath.row].removeReaction(myReaction)
            addEmoji = myReaction != reaction.encodeEmoji()
        }
        if addEmoji {
            self.filteredPosts[indexPath.row].addReaction(reaction.encodeEmoji())
        }
        cell.updatePostData(data: self.filteredPosts[indexPath.row])
        self.postEmojiReaction(postId: post.postID, isAdd: addEmoji, reaction: reaction.encodeEmoji(), cell: cell, indexPath: indexPath)
    }
    
    private func postEmojiReaction(postId: String, isAdd: Bool, reaction: String, cell:PostCell, indexPath: IndexPath) {
        APIManager.social.addReaction(postId: postId, isAdd: isAdd, reaction: reaction) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                
                if isAdd {
                    self.filteredPosts[indexPath.row].removeReaction(reaction)
                } else {
                    self.filteredPosts[indexPath.row].addReaction(reaction)
                }
                
                cell.updatePostData(data: self.filteredPosts[indexPath.row])
            }
        }
    }
}

// MARK: - APIs
extension GroupsAdapter {
    func favorite(postId: String) {
        APIManager.social.addToFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                let index = self?.posts.firstIndex(where: { $0.postID == postId })
                if let i = index {
                    self?.posts[i].isFavourite = true
                    self?.filteredPosts[i].isFavourite = true
                    self?.tableView.reloadData()
                }
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
    
    func unfavorite(postId: String) {
        APIManager.social.removeFromFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                let index = self?.posts.firstIndex(where: { $0.postID == postId })
                if let i = index {
                    self?.posts[i].isFavourite = false
                    self?.filteredPosts[i].isFavourite = false
                    self?.tableView.reloadData()
                }
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
    
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
    
    func deletePost(post: Post, indexPath: IndexPath) {
        APIManager.social.deletePost(id: post.postID) { (error) in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            } else {
                self.parent?.getPosts(limit: 10, reload: true)
            }
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension GroupsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GroupFilterDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //collectionView.isUserInteractionEnabled = !isLoading
        return groupCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemName = UILabel(frame: CGRect.zero)
        itemName.text = groupCategories[indexPath.row]
        itemName.sizeToFit()
        var width: CGFloat = 0
        
        if (indexPath.row == 0) {
            width = itemName.frame.width + 70
        } else {
            width = itemName.frame.width + 40
        }
        
        return CGSize(width: width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsSubNavBarCellItem.identifier, for: indexPath) as! EventsSubNavBarCellItem
        let row = indexPath.row
        cell.containerView.backgroundColor = UIColor(hexString: "F3F5F8")
        
        if (row == 0) {
            cell.design(showWithIcons: true, text: self.groupCategories[row])
            cell.leadingIcon.image = R.image.filter_icon()
        } else {
            cell.design(showWithIcons: false, text: self.groupCategories[row])
            
            if (parent?.selectedTab == .public && row == 2) {
                cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
            } else if (parent?.selectedTab == .my && row == 1) {
                cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if (row == 0) {
            // open filters
            if (parent?.selectedTab == .newsFeed) {
                let controller = GroupFilterController()
                controller.groupFIlterDelegate = self
                parent?.navigationController?.pushViewController(controller, animated: true)
            }
        } else if (row == 1) {
            // configure my groups screen design
            if parent?.selectedTab == .my {
                parent?.selectedTab = .newsFeed
                parent?.changeTableDesign(selectedTab: .newsFeed)
            } else {
                parent?.selectedTab = .my
                parent?.changeTableDesign(selectedTab: .my)
            }
        } else {
            if parent?.selectedTab == .public {
                parent?.selectedTab = .newsFeed
                parent?.changeTableDesign(selectedTab: .newsFeed)
            } else {
                // configure public group dashboard
                parent?.selectedTab = .public
                parent?.changeTableDesign(selectedTab: .public)
            }
        }
    }
    
    func filterGroupPosts() {
        let selectedOption = AppDefaults.shared.groupFilterOption
        
        if (selectedOption == "photo") {
            self.filteredPosts = posts.filter({
                $0.postAsset?.images?.count ?? 0 > 0
            })
        } else if (selectedOption == "video") {
            self.filteredPosts = posts.filter({
                $0.postAsset?.videos?.count ?? 0 > 0
            })
        } else if (selectedOption == "text") {
            self.filteredPosts = posts.filter({
                $0.postAsset?.videos?.count ?? 0 == 0 && $0.postAsset?.images?.count ?? 0 == 0 && $0.eventID == nil
            })
        } else if (selectedOption == "event") {
            self.filteredPosts = posts.filter({
                $0.eventID != nil
            })
        } else {
            self.filteredPosts = posts
        }
        
        self.isLoading = false
        self.tableView.reloadData()
    }
}


//extension GroupsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
//    
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let title =
//        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black])
//    }
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let title = groupType.noResultsDescription
//        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: R.color.sub_title()!])
//    }
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return EmptyCellConfirguration.group.image
//    }
//    
//}


extension GroupsAdapter {
    func acceptInvitation(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        if parent?.selectedFilter == .invitations && parent?.selectedTab == .my {
            APIManager.social.acceptGroupInvite(groupId: groupId) { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.parent?.showErrorWith(message: error!.message)
                }
                completion(error)
            }
        } else {
            APIManager.social.joinGroup(groupId: groupId) { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.parent?.showErrorWith(message: error!.message)
                }
                completion(error)
            }
        }
    }
    
    func rejectInvitation(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.social.rejectGroupInvite(groupId: groupId) { [weak self] error in
            guard let self = self else { return }
            
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error)
        }
    }
}
