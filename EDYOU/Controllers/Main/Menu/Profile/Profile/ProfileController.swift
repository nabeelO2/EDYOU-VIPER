//
//  UserProfileController.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class ProfileController: BaseController {
    
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var user: User
    var friendshipStatus: FriendShipStatusModel
    var loading = false
    var myGroups = [Group]()
    var adapter: UserProfileAdapter!
    var photoAdapter:PhotoCollectionAdapter!
    var images = [MediaAsset]()
    var videos = [MediaAsset]()
    var isViewDidLoad = false
    var requestSent : ((Bool)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = UserProfileAdapter(tableView: tableView, friendshipStatus: friendshipStatus, parent: self, didScroll: {})
        adapter.user = user
        self.loadImediateRequiredData()
        setupUI()
        self.isViewDidLoad = true
    }
    init(user: User) {
        self.user = user
        self.friendshipStatus = FriendShipStatusModel(friendID: user.userID, friendRequestStatus: FriendShipStatus.unknown, requestOrigin: .sent)
        super.init(nibName: ProfileController.name, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        if !self.isViewDidLoad {
            self.loadUserProfile()
        }
        self.isViewDidLoad = false
    }
    
    required init?(coder: NSCoder) {
        self.user = User.nilUser
        self.friendshipStatus = FriendShipStatusModel(friendID: user.userID, friendRequestStatus: FriendShipStatus.unknown, requestOrigin: .sent)
        super.init(coder: coder)
    }
    
    
    func setupUI() {
        lblTittle.text = self.adapter.isMe ? "My Profile" : user.name?.completeName
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Web APIs
extension ProfileController {
    
    private func loadImediateRequiredData() {
        self.loadUserProfile()
        self.loadFriendShipStatus()
        self.loadPosts()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.fetchProfileData()
        }
    }
    
    func loadUserProfile() {
        self.getUserDetails {
            self.tableView.reloadData()
        }
    }
    
    func loadPosts() {
        getPosts(limit: adapter.posts.count > 0 ? adapter.posts.count : 5, reload: true) {
            self.tableView.reloadData()
        }
    }
    
    func loadFriendShipStatus() {
        getFriendshipStatus {
            self.tableView.reloadData()
        }
    }
    
    func fetchProfileData() {
        let group = DispatchGroup()
        group.enter()
        getProfileMedia {
            print("DispatchGroup # 5")
            group.leave()
        }
        
        group.enter()
        getEvents{
            print("DispatchGroup # 5")
            group.leave()
        }
        group.enter()
        getGroups {
            print("DispatchGroup # 5")
            group.leave()
        }
        
        group.notify(queue: .global()) {
            DispatchQueue.main.async {
                print("DispatchGroup notified")
            }
        }
    }
    
    func getUserDetails(completion: (() -> Void)? = nil) {
        var userId: String? = user.userID
        if user.userID!.count == 0 || user.userID == Cache.shared.user?.userID! {
            userId = nil
        }
        APIManager.social.getUserInfo(userId: userId) { [weak self] user, error in
            guard let self = self else { return }
            
            if let u = user {
                self.user = u
                self.adapter.user = u
            } else {
                self.showErrorWith(message: error?.message ?? "Unexpected error")
            }
            completion?()
        }
    }
    func getFriendshipStatus(completion: (() -> Void)? = nil) {
        if user.userID != Cache.shared.user?.userID {
            APIManager.social.getFriendshipStatus(userId: user.userID!) { [weak self] status, error in
                guard let self = self else { return }
                
                if error == nil, let s = status {
                    self.friendshipStatus = s
                    self.adapter.friendshipStatus = s
                } else {
                    self.showErrorWith(message: error?.message ?? "Unexpected error")
                }
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    func getPosts(limit: Int = 15, postType: PostType = .personal, reload: Bool = false, completion: (() -> Void)? = nil) {
        loading = true
        self.adapter.showSkeleton = true
        APIManager.social.getHomePosts(userId: user.userID, postType: postType, skip: reload ? 0 : adapter.posts.count, limit: limit) { [weak self] posts, error in
            guard let self = self else { return }
            self.loading = false
            self.adapter.showSkeleton = false
            if error == nil {
                self.adapter.posts.updateRecord(with: posts?.posts ?? [])
                self.adapter.totalRecord = posts?.total ?? 0
            } else {
                self.showErrorWith(message: error!.message)
            }
            completion?()
        }
    }
    
    func favorite(userId: String) {
        APIManager.social.addToFavorite(type: .friends, id: userId) { [weak self] error in
            if error == nil {
                self?.user.isFavorite = true
            } else {
                self?.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(userId: String) {
        APIManager.social.removeFromFavorite(type: .friends, id: userId) { [weak self] error in
            if error == nil {
                self?.user.isFavorite = false
            } else {
                self?.showErrorWith(message: error!.message)
            }
        }
    }
    
    func getFriends(completion: (() -> Void)? = nil) {
        APIManager.social.getFriends(userId: user.userID) { [weak self] friends, error in
            guard let self = self else { return }
            
            if error == nil {
                self.adapter.friends = (friends?.friends ?? []).sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") })
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoadingFriends = false
            completion?()
        }
    }
    
    func getProfileMedia(completion: (() -> Void)? = nil) {
        APIManager.social.getProfileMedia(userId: user.userID!) { media, error in
            if error == nil {
                self.adapter.isLoadingMedia = false
                self.adapter.photos = (media?.images ?? []).map({ PostMedia(url: $0, type: .image) })
                self.adapter.videos = (media?.videos ?? []).map({ PostMedia(url: $0, type: .video) })
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoadingMedia = false
            completion?()
        }
    }
    
    func getEvents(completion: (() -> Void)? = nil) {
        let userId: String? = user.userID
        APIManager.social.getEvents(query: .me, userId: userId) { [weak self] events, error in
            guard let self = self else { return }
            if error == nil {
                self.adapter.events = events ?? []
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            completion?()
        }
    }
    
    func getGroups(completion: (() -> Void)? = nil) {
        let userId: String? = user.userID
        APIManager.social.getGroups(userId:userId) { [weak self] my, joined, invited, pending, error in
            guard let self = self else { return }
            if error == nil {
                var g = my
                g.append(contentsOf: joined)
                self.adapter.groups = g
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            completion?()
        }
    }
}

