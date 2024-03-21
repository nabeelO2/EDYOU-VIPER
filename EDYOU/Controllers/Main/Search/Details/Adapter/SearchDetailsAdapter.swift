//
//
//  SearchDetailsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 19/10/2021.
//
//

import UIKit

class SearchDetailsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
//    weak var collectionView: UICollectionView!
    var isLoading = true

    var parent: SearchDetailsController? {
        return tableView.viewContainingController() as? SearchDetailsController
    }
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    
    var reels: [Reels] = [] {
        didSet {
            self.reloadData()
        }
    }
    var reelsCount: Int {
        return reels.count
    }
    var isSearching : Bool = false
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    var people: [User] = []
    var requestSents: [User] = []
    var groups: [Group] = []
    var friends: [User] = []
    var posts: [Post] = []{
        didSet{
            let videoPost = posts.filter({ post in
                if  post.medias.count > 0{
                    return post.medias[0].type == .video
                }
                return false
               
            })
//            print(videoPost)
            self.videoIndexes.removeAll()
            videoPost.forEach { post in
                if let index = posts.firstIndex(where: { postInner in
                    post.postID == postInner.postID
                }){
                    self.videoIndexes.append(index)
                   // print(self.videoIndexes)
                }
            }
        }
        
    }
    var events: [Event] = []
    
    var categoryList = ["Posts" , "People", "Groups", "Events", "Friends"]
    
    var VideoPlayingIndex = -1
    var videoIndexes = [Int]()
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
//        self.collectionView = collectionView
        configure()
    }
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.register(SearchCategoryCell.nib, forCellReuseIdentifier: SearchCategoryCell.identifier)
        tableView.register(NewGroupCell.nib, forCellReuseIdentifier: NewGroupCell.identifier)
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(EventTableCell.nib, forCellReuseIdentifier: EventTableCell.identifier)
        tableView.register(AddFriendTableViewCell.nib, forCellReuseIdentifier: AddFriendTableViewCell.identifier)
//        self.collectionView.register(TrendingViewCell.nib, forCellWithReuseIdentifier: TrendingViewCell.identifier)
//        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
//          layout.delegate = self
//        }
        tableView.dataSource = self
        tableView.delegate = self
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self

    }
    
    func reloadData() {
//        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
}



// MARK: - Actions
extension SearchDetailsAdapter {
    @objc func didTapAddStoryButton() {
        let controller = AddStoryController()
        controller.modalPresentationStyle = .fullScreen
        self.parent?.present(controller, animated: true, completion: nil)
    }
    @objc func didTapEventLikeButton(_ sender: UIButton) {
        guard let event = events.object(at: sender.tag) else { return }
        let isLiked = event.peoplesProfile?.likes?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isLiked == true ? .leave : .like
        update(event: event, action: action) { status in
            if status {
                if self.events[sender.tag].peoplesProfile == nil {
                    self.events[sender.tag].peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                if action == .like {
                    self.events[sender.tag].peoplesProfile?.likes?.append(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.events[sender.tag].peoplesProfile?.likes?.remove(userId: Cache.shared.user?.userID ?? "")
                }
                
                self.tableView.reloadData()
            }
        }
    }
    @objc func didTapPostLikeButton(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as? PostCell
        
        tableView.reloadRows(at: [indexPath], with: .none)
        if let post = posts.object(at: sender.tag) {
            
            if let r = post.myReaction {
                self.posts[sender.tag].removeReaction(r.likeEmotion ?? "")
                cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
                
                APIManager.social.addReaction(postId: post.postID, isAdd: false, reaction: r.likeEmotion ?? "") { [weak self] (error) in
                    guard let self = self else { return }
                    if error != nil {
                        self.parent?.showErrorWith(message: error!.message)
                        
                        self.posts[sender.tag].addReaction(r.likeEmotion ?? "")
                        cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
                    }
                }
            } else {
                parent?.showEmojiController(completion: { selectedEmoji in
                    self.posts[sender.tag].addReaction(selectedEmoji.encodeEmoji())
                    cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
                    
                    
                    APIManager.social.addReaction(postId: post.postID, isAdd: true, reaction: selectedEmoji.encodeEmoji()) { [weak self] (error) in
                        guard let self = self else { return }
                        if error != nil {
                            self.parent?.showErrorWith(message: error!.message)
                            self.posts[sender.tag].removeReaction(selectedEmoji.encodeEmoji())
                            cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
                        }
                    }
                })
//                let controller = EmojisController { (selectedEmoji) in
                    
//                    self.posts[sender.tag].addReaction(selectedEmoji.encodeEmoji())
//                    cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
//
//
//                    APIManager.social.addReaction(postId: post.postID, isAdd: true, reaction: selectedEmoji.encodeEmoji()) { [weak self] (error) in
//                        guard let self = self else { return }
//                        if error != nil {
//                            self.parent?.showErrorWith(message: error!.message)
//                            self.posts[sender.tag].removeReaction(selectedEmoji.encodeEmoji())
//                            cell?.addReaction(self.posts[sender.tag].myReaction, totalReactions: self.posts[sender.tag].totalLikes ?? 0)
//                        }
//                    }
//                }
//                self.parent?.present(controller, animated: true, completion: nil)
                
            }
        }
        
    }
    @objc func didTapProfileButton(_ sender: UIButton) {
        guard let user = posts.object(at: sender.tag)?.user else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag) else { return }
        let indexPath = IndexPath(row: sender.tag, section: 0) // assuming cell is for first or only section of table view

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        var sheetActions: [String]?
        let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"

        if post.user?.isMe == true {
            sheetActions =  [favoriteTitle,"Delete"]
//
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//
//            }))
        } else {
           sheetActions =  [favoriteTitle, "Report"]
                showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)
//            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
//
//            }))
        }
//        alert.addAction(UIAlertAction(title: "Add to Favourite", style: .default, handler: { _ in
//
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       // parent?.present(alert, animated: true, completion: nil)
    }
    @objc func didTapGroupButton(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag), let groupID = post.groupInfo?.groupID else { return }
        
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
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
            saveSettings(contentID: reportContentObject.contentID!, contentKey: "unfollow_posts")
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
    
    func manageFavorites(indexPath: IndexPath, postId: String) {
        let post = self.posts[indexPath.row]
        let isFavorite = post.isFavourite ?? false
        if isFavorite {
            self.unfavorite(postId: postId)
        } else {
            self.favorite(postId: postId)
        }
    }
    
}



// MARK: - TableView DataSource and Delegates
extension SearchDetailsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching
        {
           return categoryList.count
        }
        else
        {
            if isLoading {
                return 10
            }
            if parent?.selectedTab == .friends {
                return friends.count
            } else if parent?.selectedTab == .people {
                return people.count
            } else if parent?.selectedTab == .groups {
                return groups.count
            } else if parent?.selectedTab == .events {
                return events.count
            }
            return posts.count
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching
        {
            return 36
   
        }
        else
        {
            if isLoading {
                return 260
            }
            if parent?.selectedTab == .friends {
                return 60
            } else if parent?.selectedTab == .people {
                return 64
            } else if parent?.selectedTab == .groups {
                return UITableView.automaticDimension
            } else if parent?.selectedTab == .events {
                return indexPath.row == 0 ?  159 : 150
            }
            return UITableView.automaticDimension
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchCategoryCell.identifier, for: indexPath) as! SearchCategoryCell
            cell.update(with: categoryList[indexPath.row])
            return cell
        }
        else
        {
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
                cell.beginSkeltonAnimation()
                return cell
            }
            
            if parent?.selectedTab == .friends {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
                cell.setData(friends[indexPath.row])
                cell.hideSktButtonsSubViews()
                return cell
                
            } else if parent?.selectedTab == .people {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendTableViewCell.identifier, for: indexPath) as! AddFriendTableViewCell
                let isRequestSent = requestSents.first(where: {$0.userID == people[indexPath.row].userID})
                cell.setData(people[indexPath.row], isRequestSent != nil)
                cell.endSkeltonAnimation()
                cell.delegate = self
                cell.selectionStyle = .none
                
//                let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
//                cell.setData(people[indexPath.row])
//                cell.hideSktButtonsSubViews()
                return cell
                
            } else if parent?.selectedTab == .groups {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
                cell.setData(groups[indexPath.row])
                let group = groups[indexPath.row]
                if let groupMembers = group.groupMembers {
                    if !groupMembers.contains(userId: Cache.shared.user?.userID ?? ""){
                        cell.joinGroupView.isHidden = false
                        cell.joinedGroupActivityView.isHidden = true
                        cell.btnJoinGroup.addTarget(self, action: #selector(joinGroupTapped), for: .touchUpInside)
                        cell.btnJoinGroup.tag = indexPath.row
                    }
                }
                cell.topConsraintWithView.constant = indexPath.row == 0 ? 23 : 12
                return cell
                
            } else if parent?.selectedTab == .events {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventTableCell.identifier, for: indexPath) as! EventTableCell
                cell.setData(events[indexPath.row])
                cell.containerViewTopConstraint.constant = indexPath.row == 0 ? 24 : 15
                return cell
            }
            
            
           
            
            let post = posts.object(at: indexPath.row)
            
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
                cell.actionDelegate = self
                cell.indexPath = indexPath
//                cell.setCVDimenstion(height, width)
//                cell.collectionVW.constant = width
                cell.collectionVH.constant = height
                
                cell.setData(post)
                cell.btnLike.tag = indexPath.row
                cell.btnMore.tag = indexPath.row
                cell.btnProfile.tag = indexPath.row
                cell.btnGroupName.tag = indexPath.row
//                cell.btnLike.addTarget(self, action: #selector(didTapPostLikeButton(_:)), for: .touchUpInside)
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
                cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                return cell
            } else if post?.isBackground == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextWithBgPostCell.identifier, for: indexPath) as! TextWithBgPostCell
                cell.setData(post)
                cell.actionDelegate = self
                cell.indexPath = indexPath
                cell.btnLike.tag = indexPath.row
                cell.btnMore.tag = indexPath.row
                cell.btnProfile.tag = indexPath.row
                cell.btnGroupName.tag = indexPath.row
//                cell.btnLike.addTarget(self, action: #selector(didTapPostLikeButton(_:)), for: .touchUpInside)
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
                cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            if indexPath.row >= posts.count {
                cell.beginSkeltonAnimation()
            } else {
                cell.setData(post)
            }
            cell.actionDelegate = self
            cell.indexPath = indexPath
            cell.btnLike.tag = indexPath.row
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
//            cell.btnLike.addTarget(self, action: #selector(didTapPostLikeButton(_:)), for: .touchUpInside)
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            return cell
        }
        
    }
    @objc func joinGroupTapped(_ sender: UIButton) {
        if (parent?.selectedTab == .groups) {
            if let groupId = groups[sender.tag].groupID, let group = self.groups.object(at: sender.tag) {
                acceptInvitation(groupId: groupId) { [weak self] error in
                    self?.parent?.view.isUserInteractionEnabled = true
                    
                    
                    if error == nil {
                        if let index = self?.groups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                            self?.groups.remove(at: index)
                        }
                        
                        if let index = self?.groups.firstIndex(where: { $0.groupID == groupId }), index >= 0 {
                            self?.groups.remove(at: index)
                        }
                        self?.tableView.reloadData()
                        //self?.didRemove?(group, .accepted)
                    }
                }
            }
        }
    }
    func acceptInvitation(groupId: String, completion: @escaping (_ error: ErrorResponse?) -> Void) {
        APIManager.social.joinGroup(groupId: groupId) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print("didSelectRowAt")
        if isSearching
        {
            parent?.categorySelected(with: categoryList[indexPath.row])
        }
        else
        {
            let t = parent?.selectedTab ?? .posts
            switch (t) {
            case .friends:
                if let user = friends.object(at: indexPath.row) {
                    let controller = ProfileController(user: user)
                    let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                    navC?.pushViewController(controller, animated: true)
                }
                break
            case .people:
                if let user = people.object(at: indexPath.row) {
                    let controller = ProfileController(user: user)
                    let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                    controller.requestSent = { res in
                        if res{//add
                            self.requestSents.append(user)
                        }
                        else{//remove
                            if let userIndex = self.requestSents.firstIndex(where: {$0.userID == user.userID}){
                                self.requestSents.remove(at: userIndex)
                            }
                        }
                        self.tableView.reloadData()
                    }
                    navC?.pushViewController(controller, animated: true)
                }
                break
            case .groups:
                if let g = groups.object(at: indexPath.row) {
                    let controller = GroupDetailsController(group: g)
                    navigationController?.pushViewController(controller, animated: true)
                }
                break
            case .posts:
                if let post = posts.object(at: indexPath.row) {
                    let controller = PostDetailsController(post: post, prefilledComment: nil)
                    navigationController?.pushViewController(controller, animated: true)
                }
                break
            case .events:
                if let event = events.object(at: indexPath.row) {
                    let controller = EventDetailsController(event: event)
                    navigationController?.pushViewController(controller, animated: true)
                }
                return
            case .friendRequests, .friendsSort:
                break
//            case .trending:
//                break
            }
        }
        
    }
}

// MARK: - APIs
extension SearchDetailsAdapter {
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
}

extension SearchDetailsAdapter : AddFriendCellDelegate
{
    func addFriend(user: User, _ onSuccess: @escaping (Any) -> Void) {
        
        self.addFriendAPI(user: user) { success in
            self.requestSents.append(user)
            onSuccess(success)
        }
    }
    
    func addFriendAPI(user: User, _ onSuccess: @escaping (Any) -> Void)
    {
        APIManager.social.sendFriendRequest(user: user, message: "Hi add me in your friends list.") { [weak self] error in
         
            guard let self = self else { return }
            if error == nil {
               // self.parent?.getSuggestedPeople()
               onSuccess(true)
            } else {
              
                if error!.message != "Record already exist"
                {
                    onSuccess(false)
                    self.parent?.showErrorWith(message: error!.message)
                }
                else
                {
                  //  self.parent?.getSuggestedPeople()
                    onSuccess(true)
                }
            }
        }
        
    }
}

// MARK: - APIs
extension SearchDetailsAdapter {
    func favorite(postId: String, type: String = "posts") {
        APIManager.social.addToFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                let index = self?.posts.firstIndex(where: { $0.postID == postId })
                if let i = index {
                    self?.posts[i].isFavourite = true
                }
                self?.tableView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(postId: String, type: String = "posts") {
        APIManager.social.removeFromFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                let index = self?.posts.firstIndex(where: { $0.postID == postId })
                if let i = index {
                    self?.posts[i].isFavourite = false
                }
                self?.tableView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
            
        }
    }
    
    
    func saveSettings(contentID: String, contentKey: String) {
        APIManager.reportContentManager.profileSaveSettings(contentID: contentID, contentKey: contentKey) { error in
            if let err = error {
                self.parent?.showErrorWith(message: err.message)
            } else {
            }
        }
    }
    
    func deletePost(post: Post, indexPath: IndexPath) {
        APIManager.social.deletePost(id: post.postID) { (error) in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                self.tableView.beginUpdates()
                self.posts.insert(post, at: indexPath.row)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            } else {
                self.tableView.reloadData()
            }
        }
        
    }
}


extension SearchDetailsAdapter{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
              var parentCenter = tableView.center
            parentCenter.y = parentCenter.y + 32

            var playingCells = [PostVideoCell]()
            
//            let visibleCells = tableView.visibleCells
            let visibleRect = tableView.bounds
            for cell in tableView.visibleCells {
                // Do something with the cell
                let intersection = visibleRect.intersection(cell.frame)
                let visibleHeight = intersection.height / cell.frame.height
                if visibleHeight >= 0.4 {
//                    cell.backgroundColor = UIColor.red
                    
                    if let cell = cell as? ImagePostCell {
                        if let videoCell = cell.collectionView.visibleCells.first as? PostVideoCell{
                            
                            //if cell is in top stop cell otherwise play
                            stopPreviousPlayingCellWithVideo {
                                playingCells.append(videoCell)
                                DispatchQueue.main.async {
//                                    videoCell.layoutSubviews()
//
//                                    videoCell.play()
                                }
                            }
                        }
                    }
                } else {
//                    cell.backgroundColor = UIColor.white
                    stopPreviousPlayingCellWithVideo {

                    }
                }

            }
            if playingCells.count > 0 {
                let cell = playingCells[playingCells.count-1]
                cell.play()
            }
          
            
        }
    }

    func manageVideo() {
        
        tableView.visibleCells.forEach({ cell in
            // Get the embedded UICollectionView
            let contentView = cell.contentView.subviews.first! as UIView
            
            let collectionViews = contentView.subviews.filter{$0 is UICollectionView}
            guard let collectionView = collectionViews.first as? UICollectionView else { return }
            
            // Get the active UICollectionViewCell in the UICollectionView
            if let activeCell = collectionView.visibleCells.first
            {
                // Do something with the active UICollectionViewCell
                if let videoCell = activeCell as? PostVideoCell {
                  
                    print("11::play \(videoCell.postData.url)")
                    
                    stopPreviousCell()

                    VideoPlayingIndex = tableView.indexPath(for: cell)?.row ?? -1
                    
                 
                }
                else{
                    stopPreviousCell()
                }
                
            }
            else{
                stopPreviousCell()
            }
        })
        
        func stopPreviousCell(){
            if let cell = tableView.cellForRow(at: IndexPath(row: VideoPlayingIndex, section: 0)) as? ImagePostCell{
                let contentView = cell.contentView.subviews.first! as UIView
                let collectionViews = contentView.subviews.filter{$0 is UICollectionView}
                guard let collectionView = collectionViews.first as? UICollectionView else { return }
                if let activeCell = collectionView.visibleCells.first{
                    if let videoCell = activeCell as? PostVideoCell {
                        videoCell.player.pause()
                       // print("11::pause \(videoCell.postData.url)")
                    }
                }
            }
        }
    }
   
        func stopPreviousPlayingCell(_ onResponse: @escaping (() -> Void)){
            let visibleCells = tableView.visibleCells
            visibleCells.indices.forEach { index in
              
//            if let cell = tableView.cellForRow(at: IndexPath(row: VideoPlayingIndex, section: 0)){
                if let cell = visibleCells[index] as? ImagePostCell {
                    
                    if let videoCell = cell.collectionView.visibleCells.first as? PostVideoCell{
                    
                        videoCell.player.pause()
                        returnResponse(index)
                    }
                    else{ returnResponse(index) }
                }
                else{returnResponse(index)}
            }
            returnResponse(visibleCells.count)
            func returnResponse(_ index : Int){
                if index == visibleCells.count{
                    onResponse()
                }
            }
        }
    
    
    func stopPreviousPlayingCellWithVideo(_ onResponse: @escaping (() -> Void)){
        videoIndexes.forEach { index in
             let indexP = IndexPath(row: index, section: 0)
                if let cell = tableView.cellForRow(at: indexP) as? ImagePostCell{
                    if let videoCell = cell.collectionView.visibleCells.first as? PostVideoCell{
                        if videoCell.player != nil {
                            videoCell.player.pause()
                        }
                       
//                        returnResponse(index)
                    }
                }
            
        }

        onResponse()
    }
    
   
}

extension SearchDetailsAdapter : PostCellActions {
    
    
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
//        if let d = cellHeightDictionary.object(forKey: indexPath) as? NSDictionary, let id = d["id"] as? String, id == postId {
//            cellHeightDictionary.removeObject(forKey: indexPath)
//        }
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.setNeedsDisplay()
            tableView.endUpdates()
        }
    }
    
    func tapOnReaction(indexPath: IndexPath, reaction: String) {
        guard let post = posts.object(at: indexPath.row) else { return }
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
//        guard let post = posts.object(at: indexPath.row) else { return }
//        self.showPostDetail(post: post, comment: comment)
    }
    
    private func handleEmojiSelection(post: Post, indexPath: IndexPath, reaction: String,cell: PostCell) {
        var addEmoji = true
        if let myReaction = post.myReaction?.likeEmotion {
            self.posts[indexPath.row].removeReaction(myReaction)
            addEmoji = myReaction != reaction.encodeEmoji()
        }
        if addEmoji {
            self.posts[indexPath.row].addReaction(reaction.encodeEmoji())
        }
        cell.updatePostData(data: self.posts[indexPath.row])
        self.postEmojiReaction(postId: post.postID, isAdd: addEmoji, reaction: reaction.encodeEmoji(), cell: cell, indexPath: indexPath)
    }
    
    private func postEmojiReaction(postId: String, isAdd: Bool, reaction: String, cell:PostCell, indexPath: IndexPath) {
        APIManager.social.addReaction(postId: postId, isAdd: isAdd, reaction: reaction) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                if isAdd {
                    self.posts[indexPath.row].removeReaction(reaction)
                } else {
                    self.posts[indexPath.row].addReaction(reaction)
                }
                cell.updatePostData(data: self.posts[indexPath.row])
                //                cell.addReaction(self.posts[indexPath.row].myReaction, totalReactions: self.posts[indexPath.row].totalLikes ?? 0)
            }
        }
    }
    
    
    func manageHidePost(post: Post, indexPathofRow: IndexPath) {
        var saved = AppDefaults.shared.savedHidePosts
        if let index = saved.firstIndex(of: post.postID), index >= 0 {
            saved.remove(at: index)
            self.posts[indexPathofRow.row].isHidePost = false
//            cellHeightDictionary = [:]
        } else {
            saved.append(post.postID )
            self.posts[indexPathofRow.row].isHidePost = true
        }
        AppDefaults.shared.savedHidePosts = saved
        // UIView.performWithoutAnimation {
        //            self.tableView.beginUpdates()
        //            self.tableView.reloadRows(at: [indexPathofRow], with: .automatic)
        //            self.tableView.endUpdates()
        self.tableView.reloadData()
        //}
    }
    
    @objc func topLeaderAction(_ sender : UIButton){
        
//        let tmp = leaders.filter { obj in
//            obj.rank != 0 && obj.score != 0 && obj.user != nil
//        }
//
//        if let user = tmp.object(at: sender.tag)?.user {
//
//            let controller = ProfileController(user: user)
//            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
//            navC?.pushViewController(controller, animated: true)
//
//        }
    }
}
