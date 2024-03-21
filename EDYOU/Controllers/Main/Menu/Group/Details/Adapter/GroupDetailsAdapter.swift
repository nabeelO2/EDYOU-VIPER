//
//  
//  GroupDetailsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//
//

import UIKit

enum GroupDataFilterType: Int, CaseIterable {
    case all = 1
    case photos
    case video
    case text
}


class GroupDetailsAdapter: NSObject {
    
    // MARK: - Properties
    private weak var tableView: UITableView!
    
    var parent: GroupDetailsController? {
        return tableView.viewContainingController() as? GroupDetailsController
    }
    var group: Group
    var isLoading = true
    private var totalRecord: Int = -1
    private var posts: [Post] = []
    private var filteredPosts: [Post] = []
    private var selectedPostFilter: GroupDataFilterType = .all
    var isAllInviteFriendRequestSucceded = true
    var cellHeightDictionary = NSMutableDictionary()
    
    var postCount: Int {
        return self.posts.count
    }
    
    // MARK: - Initializers
    init(tableView: UITableView, group: Group) {
        self.group = group
        super.init()
        
        self.tableView = tableView
        configure()
    }
    
    func configure() {
        tableView.register(GroupDetailCell.nib, forCellReuseIdentifier: GroupDetailCell.identifier)
        tableView.register(GroupHeaderImageTableViewCell.nib, forCellReuseIdentifier: GroupHeaderImageTableViewCell.identifier)
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(NoPostsCell.nib, forCellReuseIdentifier: NoPostsCell.identifier)
        tableView.register(NoMorePostCell.nib, forCellReuseIdentifier: NoMorePostCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        filteredPosts = posts
    }
    
    func reloadData(posts: [Post], total: Int , isUpdate: Bool) {
        if isUpdate {
            self.posts.updateRecord(with: posts)
            self.filteredPosts = self.posts
        } else {
            self.posts = posts
            self.filteredPosts = posts            
        }
        self.filterSelected(filter: self.selectedPostFilter)
        self.tableView.reloadData()
    }
    
}


// MARK: - Actions
extension GroupDetailsAdapter {
    @objc func didTapCreatePostButton() {
        if let id = group.groupID {
            let controller = NewPostController()
            controller.groupId = id
            controller.selectedGroup = group
            controller.isScreenPresentFromGroup = true
            controller.modalPresentationStyle = .fullScreen
            self.parent?.present(controller, animated: true, completion: nil)
        }
    }
    @objc func didTapInviteFriendsButton() {
        let indexPath = IndexPath(row: 0, section: 1)
        if let cell = tableView.cellForRow(at: indexPath) as? GroupDetailCell {
            guard let id = group.groupID else { return }
            let controller = SelectFriendsController(groupId: id, type: .notJoined) { [weak self] users in
                guard let self = self else { return }
                
                if users.count > 0 {
                    cell.isUserInteractionEnabled = false
                    
                    self.inviteFriends(friends: users) {
                        cell.isUserInteractionEnabled = true
                    }
                }
            }
            controller.modalPresentationStyle = .fullScreen
            self.parent?.present(controller, animated: true, completion: nil)
        }
    }
    @objc func didTapJoinButton() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupDetailCell
        print("Call Join Request")
        cell?.isUserInteractionEnabled = false
        
        self.join { status in
            if status {
                self.parent?.loadAPIsInGroups = true
                self.parent?.getDetails()
            } else {
                cell?.isUserInteractionEnabled = true
            }
        }
    }
    @objc func didTapManageButton() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupDetailCell
        let isAdmin = group.groupAdmins?.contains(where: { $0.userID == Cache.shared.user?.userID }) ?? false
        
        if isAdmin {
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            let controller = ManageGroupController(group: group)
            navC?.pushViewController(controller, animated: true)
        } else {
            let isMember = group.groupMembers?.contains(where: { $0.userID == Cache.shared.user?.userID }) ?? false
            if isMember || group.groupJoinedStatus == GroupJoinedStatus.joined.rawValue {
                
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Leave Group", style: .default, handler: { _ in
                    self.leaveGroup()
                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.parent?.present(actionSheet, animated: true, completion: nil)
                
            } else {
                print("Call Join Request")
                cell?.isUserInteractionEnabled = false
                
                self.join { status in
                    if status {
                        self.parent?.getDetails()
                    } else {
                        cell?.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @objc func didTapEditButton() {
        
        let controller = EditGroupController(group: group)
        let navC = UINavigationController(rootViewController: controller)
        navC.isNavigationBarHidden = true
        navC.modalPresentationStyle = .fullScreen
        parent?.present(navC, animated: true, completion: nil)
        
    }
    @objc func didTapPhotosButton() {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        guard let id = group.groupID else { return }
        let controller = PhotosController(id: id, type: .group)
        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapPostLikeButton(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as? PostCell
        
        if let post = filteredPosts.object(at: sender.tag) {
            
            if let r = post.myReaction {
                self.filteredPosts[sender.tag].removeReaction(r.likeEmotion ?? "")
                cell?.addReaction(self.filteredPosts[sender.tag].myReaction, totalReactions: self.filteredPosts[sender.tag].totalLikes ?? 0)
                
                APIManager.social.addReaction(postId: post.postID, isAdd: false, reaction: r.likeEmotion ?? "") { [weak self] (error) in
                    guard let self = self else { return }
                    if error != nil {
                        self.parent?.showErrorWith(message: error!.message)
                        self.filteredPosts[sender.tag].addReaction(r.likeEmotion ?? "")
                        cell?.addReaction(self.filteredPosts[sender.tag].myReaction, totalReactions: self.filteredPosts[sender.tag].totalLikes ?? 0)
                    }
                }
            } else {
                
                let controller = EmojisController { (selectedEmoji) in
                    self.filteredPosts[sender.tag].addReaction(selectedEmoji.encodeEmoji())
                    cell?.addReaction(self.filteredPosts[sender.tag].myReaction, totalReactions: self.filteredPosts[sender.tag].totalLikes ?? 0)
                    APIManager.social.addReaction(postId: post.postID, isAdd: true, reaction: selectedEmoji.encodeEmoji()) { [weak self] (error) in
                        guard let self = self else { return }
                        if error != nil {
                            self.parent?.showErrorWith(message: error!.message)
                            self.filteredPosts[sender.tag].removeReaction(selectedEmoji.encodeEmoji())
                            cell?.addReaction(self.filteredPosts[sender.tag].myReaction, totalReactions: self.filteredPosts[sender.tag].totalLikes ?? 0)
                        }
                    }
                }
                self.parent?.present(controller, animated: true, completion: nil)
                
            }
        }
        
    }
    @objc func didTapPostMoreButton(_ sender: UIButton) {
        guard let post = filteredPosts.object(at: sender.tag) else { return }
        
        let indexPath = IndexPath(row: sender.tag, section: 0) // assuming cell is for first or only section of table view
        var sheetActions: [String]?
        if post.user?.isMe == true {
            sheetActions =  ["Delete"]

        } else {
            let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"
           sheetActions =  [favoriteTitle, "Report"]
                showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)

        }
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
//        if post.user?.isMe == true {
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//                let indexPath = IndexPath(row: sender.tag, section: 1)
//                self.deletePost(post: post, indexPath: indexPath)
//            }))
//        } else {
//            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
//                
//            }))
//        }
//        alert.addAction(UIAlertAction(title: post.isFavourite == true ? "Remove from Favourite" : "Add to Favourite", style: .default, handler: { _ in
//            if post.isFavourite == true {
//                self.unfavorite(postId: post.postID)
//            } else {
//                self.favorite(postId: post.postID)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        parent?.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(post: Post, indexPath: IndexPath, sheetOptions:[String]) {
       
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            // self.genderTextfield.text = selected
            self.sheetButtonActions(selectedOption: selected, reportContentObject: self.getReportContentObjectWithData(post: post), indexPath: indexPath)
        })
        
        self.parent!.presentPanModal(genericPicker)
    }
    
    func sheetButtonActions(selectedOption: String, reportContentObject: ReportContent, indexPath: IndexPath ) {
        guard let post = posts.object(at: indexPath.row) else { return }

        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            manageFavorites(indexPath: indexPath, postId: reportContentObject.contentID!)
        case "UnFollow":
            break
        case "Hide this Post":
             break
        case "Report":
            moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
            break
        default:
            favorite(postId: reportContentObject.contentID!)

        }
    }
    
    
    
    func moveToReportContentScreen(reportContentObject: ReportContent) {
        let navC = self.parent?.tabBarController?.navigationController ?? self.parent?.navigationController
        // let group = Group(groupID: groupID)
        let controller = ReportViewController(nibName: "ReportViewController", bundle: nil)
        controller.reportObject = reportContentObject
        navC?.pushViewController(controller, animated: true)
    }
    
    func getReportContentObjectWithData(post: Post) -> ReportContent {
        var reportContentObject = ReportContent()
        reportContentObject.contentID = post.postID
        reportContentObject.contentType = post.postType
        reportContentObject.userName = post.user?.name?.completeName
        reportContentObject.userID = post.userID
        return reportContentObject
    }
    
    
    
}


// MARK: - TableView DataSource and Delegates
extension GroupDetailsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        if isLoading {
            return 1
        }
        return filteredPosts.count == 0 ? 1 : filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return UITableView.automaticDimension
        } else {
            if let d = cellHeightDictionary.object(forKey: indexPath) as? NSDictionary, let height = d["height"] as? CGFloat, let id = d["id"] as? String, id == filteredPosts.object(at: indexPath.row)?.postID {
                return height
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupHeaderImageTableViewCell.identifier, for: indexPath) as! GroupHeaderImageTableViewCell
//            cell.headerImage.setImage(url: self.group.groupIcon, placeholder: UIImage(named: "group_cover_placeholder"))
            cell.setData(image: self.group.groupIcon, delegate: self)
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupDetailCell.identifier, for: indexPath) as! GroupDetailCell
            cell.setData(group, filter: self.selectedPostFilter, delegate: self)
            cell.btnCreatePost.addTarget(self, action: #selector(didTapCreatePostButton), for: .touchUpInside)
            cell.btnInvite.addTarget(self, action: #selector(didTapInviteFriendsButton), for: .touchUpInside)
            cell.btnJoin.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
            cell.btnPhotos.addTarget(self, action: #selector(didTapPhotosButton), for: .touchUpInside)
            cell.isUserInteractionEnabled = true
            return cell
        }
        
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
            cell.btnMore.addTarget(self, action: #selector(didTapPostMoreButton(_:)), for: .touchUpInside)
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
            cell.btnMore.addTarget(self, action: #selector(didTapPostMoreButton(_:)), for: .touchUpInside)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
        cell.setData(post)
        cell.indexPath = indexPath
        cell.actionDelegate = self
        cell.btnMore.tag = indexPath.row
        cell.btnProfile.tag = indexPath.row
        cell.btnGroupName.tag = indexPath.row
        cell.btnMore.addTarget(self, action: #selector(didTapPostMoreButton(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if let post = filteredPosts.object(at: indexPath.row) {
                let controller = PostDetailsController(post: post, prefilledComment: nil)
                let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                navC?.pushViewController(controller, animated: true)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading == false {
            let d: NSDictionary = [
                "height": cell.frame.height,
                "id": filteredPosts.object(at: indexPath.row)?.postID ?? ""
            ]
            cellHeightDictionary.setObject(d, forKey: indexPath as NSCopying)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let offsetYBottom = tableView.contentOffset.y + tableView.frame.height
            if offsetYBottom >= (tableView.contentSize.height - 260) && posts.count < totalRecord {
                parent?.loadDataOnScrollEnd()
            }
        }
    }
}


// MARK: - Web APIs
extension GroupDetailsAdapter: GroupDetailCellAction {
    func filterSelected(filter: GroupDataFilterType) {
        selectedPostFilter = filter
        switch selectedPostFilter {
        case .all:
            filteredPosts = posts
            break
        case .text:
            self.filteredPosts = posts.filter({
                $0.postAsset?.videos?.count ?? 0 == 0 && $0.postAsset?.images?.count ?? 0 == 0 && $0.eventID == nil
            })
            break
        case .photos:
            self.filteredPosts = posts.filter({
                $0.postAsset?.images?.count ?? 0 > 0
            })
        case .video:
            self.filteredPosts = posts.filter({
                $0.postAsset?.videos?.count ?? 0 > 0
            })
            break
        }
        self.tableView.reloadData()
    }
    
    
    func join(completion: @escaping (_ status: Bool) -> Void) {
        guard let id = group.groupID else { return }
        let status = group.groupJoinedStatusEnum
        if status == .waiting_for_my_approval {
            APIManager.social.acceptGroupInvite(groupId: id) { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.parent?.showErrorWith(message: error!.message)
                }
                completion(error == nil)
            }
        } else {
        APIManager.social.joinGroup(groupId: id) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
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
                self.parent?.showSuccessMessage(message: "Successfully invited")
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
                self.parent?.showErrorWith(message: error!.message)
            }
            completion()
        }
    }
    
    func leaveGroup() {
        guard  let id = group.groupID else { return }
        self.parent?.startLoading(title: "Leaving Group...")
        APIManager.social.leaveGroup(groupId: id) { error in
            
            if error != nil {
                self.parent?.stopLoading()
                self.parent?.showErrorWith(message: error!.message)
            } else {
                self.parent?.getDetails()
            }
            
        }
    }
    func rejectInvite() {
        guard  let id = group.groupID else { return }
        self.parent?.startLoading(title: "Reject Invite...")
        APIManager.social.rejectGroupInvite(groupId: id, completion: { error in
            if error != nil {
                self.parent?.stopLoading()
                self.parent?.showErrorWith(message: error!.message)
            } else {
                self.parent?.getDetails()
            }
        })
    }
    func manageGroupFavorites() {
        guard  let groupID = group.groupID else { return }
        let isFavorite = group.isFavorite ?? false
        if isFavorite {
            self.unfavorite(postId: groupID, type: .groups)
        } else {
            self.favorite(postId: groupID, type: .groups)
        }
    }
    func favorite(postId: String, type: FavoriteType = .posts) {
        APIManager.social.addToFavorite(type: type, id: postId) { [weak self] error in
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
    func unfavorite(postId: String, type: FavoriteType = .posts) {
        APIManager.social.removeFromFavorite(type: type, id: postId) { [weak self] error in
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
extension GroupDetailsAdapter : PostCellActions {
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

extension GroupDetailsAdapter: GroupHeaderImageProtocol {
    func backActionTapped() {
        self.parent?.didTapBackButton()
    }
    func moreActionTapped() {
        self.parent?.didTapMoreButton()
    }
}
