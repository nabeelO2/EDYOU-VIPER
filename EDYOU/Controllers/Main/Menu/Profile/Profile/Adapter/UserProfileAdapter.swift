//
//  UserProfileAdapter.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit
import EmptyDataSet_Swift
import TransitionButton
import Martin

protocol UserProfileUpdateProtocol : AnyObject {
    func userProfileUpdated(user: User)
}

class UserProfileAdapter: NSObject {
    weak var tableView: UITableView!
    var parent: ProfileController
    var didScroll: (() -> Void)?
    var posts: [Post] = []
    var friends = [User]()
    var media = [GroupMedia]()
    var events = [Event]()
    var groups = [Group]() {
        didSet {
            self.groupFactory.groups = groups
        }
    }
    var isLoadingMedia = true
    var photos = [MediaAsset]()
    var videos = [MediaAsset]()
    var isLoadingFriends = true
    var showSkeleton = true
    var totalRecord: Int = -1
    var type: ProfileDetailType = .post
    var friendshipStatus: FriendShipStatusModel
    var isMe: Bool {
        return user?.userID == Cache.shared.user?.userID
    }
    
    var aboutFactory: AboutFactory
    var postFactory: PostFactory
    var eventFactory: EventsFactory
    var groupFactory: GroupsFactory
    var photosFactory: PhotosFactory
    
    // Setter Handling
    var user: User? {
        didSet {
            aboutFactory.user = user
        }
    }
    
    
    init(tableView: UITableView, friendshipStatus: FriendShipStatusModel, parent: ProfileController, didScroll: @escaping () -> Void) {
        self.friendshipStatus = friendshipStatus
        self.parent = parent
        self.didScroll = didScroll
        self.tableView = tableView
        let navC = parent.tabBarController?.navigationController ?? parent.navigationController
        self.aboutFactory = AboutFactory(table: tableView, navigationController: navC)
        self.postFactory = PostFactory(tableView: tableView)
        self.eventFactory = EventsFactory(tableView: tableView)
        self.groupFactory = GroupsFactory(tableView: tableView)
        self.photosFactory = PhotosFactory(tableView: tableView)
        super.init()
        self.postFactory.updateDelegate(delegate: self, factoryDelegate: self)
        self.aboutFactory.updateDelegate(profileUpdate: self)
        configure()
    }
    
    func configure() {
        tableView.register(ProfileHeaderInfo.nib, forCellReuseIdentifier: ProfileHeaderInfo.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
    }
}

//MARK: -TableView

extension UserProfileAdapter:UITableViewDelegate,UITableViewDataSource{
    
    private func otherProfileAndPrivate() -> Bool {
        let otherUser = Cache.shared.user?.userID != self.user?.userID
        return otherUser && (self.user?.isPrivate ?? false) && self.friendshipStatus.friendRequestStatus != .approved
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainSection = UserProfileSections(rawValue: section)
        if mainSection == .profile {
            return mainSection?.cells ?? 0
        }
        if otherProfileAndPrivate() {
            return 1
        }
        if type == .about {
            return self.aboutFactory.tableView(numberOfRowsInSection: section, user: self.user)
        }
        if type == .post {
            return self.postFactory.tableView(numberOfRowsInSection: section, posts: self.posts, showSkeleton: showSkeleton)
        }
        if type == .events {
            return self.eventFactory.tableView(numberOfRowsInSection: section, events: self.events)
        }
        if type == .groups {
            return self.groupFactory.tableView(numberOfRowsInSection: section)
        }
        if type == .photos {
            return self.photosFactory.tableView(numberOfRowsInSection: section)
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.type == .about && !self.otherProfileAndPrivate() {
            return AboutSections.allCases.count + 1 // Profile cell
        }
        return UserProfileSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section =  UserProfileSections(rawValue: indexPath.section)
        if section == .profile {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderInfo.identifier, for: indexPath) as! ProfileHeaderInfo
            cell.setData(user: user ?? User.nilUser, status: friendshipStatus, delegate: self)
            return cell
        }
        if self.otherProfileAndPrivate() {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier) as! EmptyTableCell
            cell.setConfiguration(configuration: .lock)
            return cell
        }
        if self.type == .about {
            return self.aboutFactory.tableView(cellForRowAt: indexPath, friendshipStatus: friendshipStatus, user: self.user, delegate: nil)
        }
        if self.type == .post {
            return self.postFactory.getCell(posts: self.posts, indexPath: indexPath, totalRecord: self.totalRecord, showSkeleton: showSkeleton)
        }
        if self.type == .events {
            return self.eventFactory.getCell(events: self.events, indexPath: indexPath, totalRecord: totalRecord)
        }
        if self.type == .groups {
            return self.groupFactory.getCell(indexPath: indexPath, totalRecord: totalRecord)
        }
        if self.type == .photos {
            return self.photosFactory.getPhotosCell(photos: photos, videos: videos, isLoading: isLoadingMedia, indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        if self.otherProfileAndPrivate() {
        //            return nil
        //        }
        if type == .about && section != UserProfileSections.profile.rawValue && !self.otherProfileAndPrivate() {
            return self.aboutFactory.tableView(viewForHeaderInSection: section)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        if self.otherProfileAndPrivate() {
        //            return 0
        //        }
        if type == .about && !self.otherProfileAndPrivate() {
            return self.aboutFactory.tableView(heightForHeaderInSection: section)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section =  UserProfileSections(rawValue: indexPath.section)
        if section == .listing && type == .post {
            return postFactory.tableView(heightForRowAt: indexPath, showSkeleton: showSkeleton)
        }
        if section == .listing && type == .events {
            return eventFactory.tableView(heightForRowAt: indexPath)
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

// MARK: - User posts handling

extension UserProfileAdapter : PostCellActions, PostFactoryActions {
    
    func manageFavorites(indexPath: IndexPath, postId: String) {
        let post = self.posts[indexPath.row]
        let isFavorite = post.isFavourite ?? false
        if isFavorite {
            self.unfavorite(postId: postId, type: .posts)
        } else {
            self.favorite(postId: postId, type: .posts)
        }
    }
    
    func showAllReactions(indexPath: IndexPath, postId: String) {
        APIManager.social.getPostDetails(postId: postId) { post, error in
            if let error = error {
                self.parent.showErrorWith(message: error.message)
            } else {
                self.parent.showAllReactions(emojis: post?.reactions ?? [])
            }
        }
    }
    
    func tapGroupButton(sender: Int) {
        guard let post = posts.object(at: sender), let groupID = post.groupInfo?.groupID else { return }
        let navC = parent.tabBarController?.navigationController ?? parent.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
    }
    
    func tapProfileButton(sender: Int) {
        guard let user = posts.object(at: sender)?.user else { return }
        let navC = parent.tabBarController?.navigationController ?? parent.navigationController
        let controller = ProfileController(user: user)
        navC?.popToRootViewController(animated: false)
        navC?.pushViewController(controller, animated: true)
    }
    
    func tapMoreButton(sender: Int) {
        guard let post = posts.object(at: sender) else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        let indexPath = IndexPath(row: sender, section: 0) // assuming cell is for first or only section of table view

        var sheetActions: [String]?
        let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"

        if post.user?.isMe == true {
            sheetActions =  [favoriteTitle,"Delete"]

        } else {
            sheetActions =  [favoriteTitle, "Report"]
        }
        
        showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)

    }
    
    @objc func didTapGroupButton(_ sender: UIButton) {
        
    }
    
    func showReactionPanel(indexPath: IndexPath, postId: String) {
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
            self.parent.showEmojiController { selectedEmoji in
                self.handleEmojiSelection(post: post, indexPath: indexPath, reaction: selectedEmoji, cell: cell)
            }
        } else {
            self.handleEmojiSelection(post: post, indexPath: indexPath, reaction: reaction, cell: cell)
        }
    }
    func tapOnComments(indexPath: IndexPath, comment: String?) {
        guard let post = posts.object(at: indexPath.row) else { return }
        self.showPostDetail(post: post, comment: comment)
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
                self.parent.showErrorWith(message: error!.message)
                if isAdd {
                    self.posts[indexPath.row].removeReaction(reaction)
                } else {
                    self.posts[indexPath.row].addReaction(reaction)
                }
                cell.updatePostData(data: self.posts[indexPath.row])
            }
        }
    }
    private func showPostDetail(post : Post, comment: String?) {
        let controller = PostDetailsController(post: post, prefilledComment: comment)
        let navC = parent.tabBarController?.navigationController ?? parent.navigationController
        navC?.pushViewController(controller, animated: true)
    }
}


extension UserProfileAdapter {
    func favorite(postId: String, type: FavoriteType) {
        APIManager.social.addToFavorite(type: type, id: postId) { [weak self] error in
            if error == nil {
                if type == .users {
                    self?.user?.isFavorite = true
                } else {
                    let index = self?.posts.firstIndex(where: { $0.postID == postId })
                    if let i = index {
                        self?.posts[i].isFavourite = true
                    }
                }
            } else {
                self?.parent.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(postId: String, type: FavoriteType) {
        APIManager.social.removeFromFavorite(type: type, id: postId) { [weak self] error in
            if error == nil {
                if type == .users {
                    self?.user?.isFavorite = false
                }
                else {
                    let index = self?.posts.firstIndex(where: { $0.postID == postId })
                    if let i = index {
                        self?.posts[i].isFavourite = false
                    }
                }
            } else {
                self?.parent.showErrorWith(message: error!.message)
            }
        }
    }
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
    
    func deletePost(post: Post, indexPath: IndexPath) {
        APIManager.social.deletePost(id: post.postID) { (error) in
            if error != nil {
                self.parent.showErrorWith(message: error!.message)
                
                self.tableView.beginUpdates()
                self.posts.insert(post, at: indexPath.row)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func blockUser() {
        APIManager.social.addBlockUser(userid: (self.user?.userID)!) { error in
            if error != nil {
                self.parent.showErrorWith(message: error!.message)
            } else {
                self.parent.goBack()
            }
        }
    }
    
    @objc func didTapAddFriendButton() {
        let s = friendshipStatus
        if s.friendRequestStatus == .approved {
            unfriend(button: UIButton())
        } else if s.friendRequestStatus == FriendShipStatus.none {
            addFriend(button: UIButton())
        } else if s.friendRequestStatus == FriendShipStatus.pending {
            if s.requestOrigin == .sent {
                updateRequestStatus(status: .cancel)
            } else {
                updateRequestStatus(status: .approved)
            }
        }
    }
    func addFriend(button: UIButton) {
        guard let user = self.user else { return }
        button.isUserInteractionEnabled = false
        APIManager.social.sendFriendRequest(user: user, message: "Hi add me in your friends list.") { [weak self] error in
            button.isUserInteractionEnabled = true
            guard let self = self else { return }
            if error == nil {
                self.handleAddFriendUI()
            } else {
                self.parent.showErrorWith(message: error!.message)
            }
        }
    }
    
    private func handleAddFriendUI() {
        self.friendshipStatus.friendRequestStatus = FriendShipStatus.pending
        self.friendshipStatus.requestOrigin = .sent
        self.parent.friendshipStatus = self.friendshipStatus
        self.tableView.reloadData()
        if let action = self.parent.requestSent{
            action(true)
        }
    }
    
    func unfriend(button: UIButton) {
        guard let userId = self.user?.userID else { return }
        APIManager.social.unFriend(userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if error == nil {
                    self.friendshipStatus.friendRequestStatus = FriendShipStatus.none
                    self.parent.friendshipStatus = self.friendshipStatus
                    self.tableView.reloadData()
                    if let action = self.parent.requestSent{
                        action(false)
                    }
                } else {
                    self.parent.showErrorWith(message: error!.message)
                }
            }
        }
    }
    func updateRequestStatus(status: FriendRequestStatus) {
        guard let user = user else { return }
        APIManager.social.updateFriendRequestStatus(user: user, status: status) { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                if status == .approved {
                    self.friendshipStatus.friendRequestStatus = FriendShipStatus.approved
                } else if status == .rejected {
                    self.friendshipStatus.friendRequestStatus = FriendShipStatus.none
                } else if status == .cancel {
                    self.friendshipStatus.friendRequestStatus = FriendShipStatus.none
                }
                self.parent.friendshipStatus = self.friendshipStatus
                self.tableView.reloadData()
            } else {
                self.parent.showErrorWith(message: error!.message)
            }
        }
    }
    
}

extension UserProfileAdapter : ProfileHeaderActions {
    func sendInvite() {
        //present invite screen
        
        let controller = WelcomeInviteController()
        parent.navigationController?.pushViewController(controller, animated: true)
    }
    
    func callUser() {
        guard let user = user else {return}
        if let chat = DBChatStore.getRoomInfoFrom(jid: BareJID("\(user.userID ?? "")@ejabberd.edyou.io"),isRoom:false) {
            self.initiateCallWithRoomId(room:chat)
        } else if let account = AccountManager.getAccounts().first ,let contaxt = XmppService.instance.getClient(for: account) {
            switch DBChatStore.instance.createChat(for:contaxt, with: BareJID("\(user.userID ?? "")@ejabberd.edyou.io"), name: user.name?.completeName ?? "") {
                case .created(let chat),.found(let chat):
                    self.initiateCallWithRoomId(room:chat)
                case .none:
                    self.parent.showErrorWith(message: "unable to intiate Call try again after some time")
                    break
            }
        }
    }
    
    func initiateCallWithRoomId(room: Conversation) {
        AudioVideoCallViewController.checkAudioVideoPermissions(parent: self.parent) {
            if $0 {
                generateHapticFeedback()
                APIManager.social.CallChatRoom(roomId: [room.jid.localPart ?? ""], callType: .audio,roomJID: room.jid.stringValue) { chatCall, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parent.showErrorWith(message: error.message)
                            return
                        }
                        CallManager.shared.startCall(room: room ,callType: .audio, token: chatCall?.accessToken ?? "")
                    }
                }
            }
        }
        
    }
    
    func sendMessageToUser() {
        let  userJID =  BareJID("\(self.user?.userID ?? "")@ejabberd.edyou.io")
        if let clint = XmppService.instance.connectedClients.first {
            let res =  DBChatStore.instance.createChat(for: clint.context, with:userJID , name: self.user?.name?.completeName ?? "")
            switch res {
                case .created(_),.found(_):
                    print("created")
                    DBChatStore.instance.refreshConversationsList()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        if let conversation = DBChatStore.instance.conversation(for: clint.userBareJid, with: userJID) {
                            let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                            controller.conversation = conversation
                            self.parent.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                case .none:
                    self.parent.showErrorWith(message: "Error while fetching Chat User")
                    return
            }
        } else {
            self.parent.showErrorWith(message: "Unable to connect to server")
        }
    }
    
    func addFriendAction(action: AddFriendAction, sender: UIButton) {
        if action == .addFriend {
            self.addFriend(button: sender)
        }
        if action == .cancelRequest {
            self.unfriend(button: sender)
        }
        if action == .acceptRequest {
            self.updateRequestStatus(status: .approved)
        }
        if action == .unfriend {
            self.unfriend(button: sender)
        }
    }
    
    func detailSegmentChanged(type: ProfileDetailType) {
        self.type = type
        self.tableView.reloadData()
    }
    
    func showActionSheet(post: Post , indexPath: IndexPath, sheetOptions:[String]) {
       
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            // self.genderTextfield.text = selected
            self.sheetButtonActions(selectedOption: selected, reportContentObject: self.getReportContentObjectWithData(post: post), indexPath: indexPath)
        })
        
        self.parent.presentPanModal(genericPicker)
    }
    
    func showActionSheetWithoutPost( sheetOptions:[String]) {
       
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            // self.genderTextfield.text = selected
            var reportContentObject = ReportContent()
            reportContentObject.userID = self.user?.userID
            reportContentObject.userName = self.user?.name?.completeName
            self.sheetButtonActionsWithoutPost(selectedOption: selected, reportContentObject: reportContentObject)
        })
        
        self.parent.presentPanModal(genericPicker)
    }
    
    func sheetButtonActions(selectedOption: String, reportContentObject: ReportContent, indexPath: IndexPath ) {
        guard posts.object(at: indexPath.row) != nil else { return }

        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            manageFavorites(indexPath: indexPath, postId: reportContentObject.contentID!)
        case "UnFollow":
           break
        case "Hide this Post":
             break
        case "Block":
            blockUser()
        case "Report":
            moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
            deletePost(postid: reportContentObject.contentID!, indexPath: indexPath)
        default:
            let action = AddFriendAction.from(status: friendshipStatus)
            let button = UIButton(type: .custom)
            addFriendAction(action: action, sender: button)

        }
    }
    
    func sheetButtonActionsWithoutPost(selectedOption: String, reportContentObject: ReportContent ) {
       // guard posts.object(at: indexPath.row) != nil else { return }

        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            break
        case "UnFollow":
           break
        case "Edit Profile":
            
            let controller = EditProfileViewController(user: self.user ?? User.nilUser)
            self.parent.navigationController?.pushViewController(controller, animated: true)
        case "Block":
            blockUser()
        case "Report":
            moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
           break
        default:
            let action = AddFriendAction.from(status: friendshipStatus)
            let button = UIButton(type: .custom)
            addFriendAction(action: action, sender: button)

        }
    }
    
    func deletePost(postid: String, indexPath: IndexPath) {
        let deletedPost = posts.filter({$0.postID == postid})
        self.deletePost(post: deletedPost[0], indexPath: indexPath)
       // self.tableView.beginUpdates()
        self.posts.remove(at: indexPath.row)
        self.tableView.reloadData()
//        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        self.tableView.endUpdates()
    }
    
    func moveToReportContentScreen(reportContentObject: ReportContent) {
        let navC = self.parent.tabBarController?.navigationController ?? self.parent.navigationController
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
    
//    func manageFavorites(indexPath: IndexPath, postId: String) {
//        let post = self.posts[indexPath.row]
//        let isFavorite = post.isFavourite ?? false
//        if isFavorite {
//            self.unfavorite(postId: postId)
//        } else {
//            self.favorite(postId: postId)
//        }
//    }
    
    
    func editProfile() {
        var sheetOptions: [String]?
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        let indexPath = IndexPath(row: 0, section: 0) // assuming cell is for first or only section of table view

        if Cache.shared.user?.userID == user?.userID {
            sheetOptions = [ "Edit Profile"]

        } else {
            
            let properties = Utilities.getFriendShipButtonProperties(for: friendshipStatus)
            

            
//            actionSheet.addAction(UIAlertAction(title: properties.title, style: .default, handler: { _ in
//                self.didTapAddFriendButton()
//            }))
        
            sheetOptions = ["\(properties.title)","Block", "Report"]
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        showActionSheetWithoutPost(sheetOptions: sheetOptions!)
    }
    func showEditProfilePicture() {
        //Profile picture update handling
        guard let user = user else { return }

        let controller = EditProfilePhoto(photo: user.profileImage ?? "", image: R.image.dm_profile_holder()!)

        controller.modalPresentationStyle = .fullScreen
        self.parent.present(controller, animated: true, completion: nil)
    }
}

extension UserProfileAdapter : UserProfileUpdateProtocol {
    func userProfileUpdated(user: User) {
        self.user = user
        self.tableView.reloadData()
    }
}
