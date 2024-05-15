//
//  HomeController.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import UIKit
import Bugsnag

class HomeController: BaseController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNavBar: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet var tabImages: [UIImageView]!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet var tabSeperators: [UIView]!
    @IBOutlet weak var viewBadgeNotifications: UIView!
    @IBOutlet weak var lblBadgeNotifications: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollViewTabs: UIScrollView!
    @IBOutlet weak var tabsStack: UIStackView!
//    var storyTableView: UITableView!
    @IBOutlet weak var topVHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableviewTopConstraint: NSLayoutConstraint!
    @IBOutlet var tabButtons: [UIButton]!
    // MARK - Properties
    var adapter: HomeAdapter!
//    var storyAdapter: StoryAdapater!
    
    var selectedPostType: PostType = .public
    var eventsIAmInvited: [Event] = []
    var presenter : HomePresenterProtocol!
    var leaderResult : LeaderFilter?{
        didSet{
            filterLeader()
        }
    }
    var leaderFilterBy : LeaderBoardPeriodFilter = .yearly{
        didSet{
            getLeaders(type: typeFilter,reload: true)
        }
    }
    
    var loading = false
    var typeFilter : LeaderBoardTypeFilter = .national
    
    var topHeaderV : TopHeaderV!
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // addLogo()
        presenter.viewDidLoad()
//        navigationController?.navigationBar.backgroundColor = R.color.navigationColor() ?? .green
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationController?.hidesBarsOnSwipe = false
        
        adapter = HomeAdapter(tableView: tableView)
//        getMyEvents()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.appEnteredFromBackground),
//                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        if let param = UserDefaults.standard.dictionary(forKey: "pendingPostParam"){
            let attachments = loadMediaFromFile()
            uploadNewPost(param, attachments)
        }else{
            getPosts(limit: adapter.posts.count > 0 ? adapter.posts.count : 5, reload: true)
        }
        
        if adapter.storyADP.isGetStories {
            getStories()
        }
        topVHeight.constant = Application.shared.safeAreaInsets.top + 80
//        tableviewTopConstraint.constant = topVHeight.constant  -  Application.shared.safeAreaInsets.top - 16
//        FriendManager.shared.fetchChatRoomsFromRealm { friends in
//            print(friends)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewdidAppear")
        
        
       // self.tableView.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        topViewTopConstraint.constant = 0
        adapter.stopPreviousPlayingCellWithVideo {
            super.viewWillDisappear(animated)
        }
    }

    private func addStoryHeaderView() {
        
    }
    
   
    
    func uploadNewPost(_ parameters : [String : Any], _ media : [Media]){
        print(parameters)
        let privacy = parameters["privacy"] as? String ?? self.selectedPostType.rawValue
        selectPrivacyTab(privacy)
        saveToFileUsingJSON(attachments: media, filename: "pendingPost.json")
        UserDefaults.standard.setValue(parameters, forKey: "pendingPostParam")
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            self.adapter.pendingParamters = parameters
//            self.adapter.pendingMedia = media
            self.adapter.ispendingPost = parameters.count > 0
               
        DispatchQueue.main.asyncAfter(deadline: .now()+0.9) {
            self.createPost(parameters, media)
        }
       
    }
    private func selectPrivacyTab(_ privacy : String){
        var newSelectedPostType : PostType = selectedPostType
        switch privacy {
        case "friends":
            newSelectedPostType = .friends
            
            break
        case "groups":
            newSelectedPostType = .groups
            
            break
        case "events":
            newSelectedPostType = .event
           
            break
        case "my_school_only":
            newSelectedPostType = .school
           
            break
        default:
            newSelectedPostType = .public
            
            break
        }
        
        if newSelectedPostType != selectedPostType{
            //refresh selected post type
            selectedPostType = newSelectedPostType
            let tag = getTag(from: selectedPostType)
            if let button = tabButtons.first(where: {$0.tag == tag}){
                didTapTabButton(button)
            }
            
        }
        
    }
    func saveToFileUsingJSON(attachments: [Media], filename: String) {
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(attachments) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
            print(fileURL)
            try? encodedData.write(to: fileURL)
        }
    }
    func loadMediaFromFile() -> [Media] {
        let filename = "pendingPost.json"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            let mediaArray = try JSONDecoder().decode([Media].self, from: data)
            return mediaArray
        } catch {
            print("Error decoding file at \(fileURL): \(error)")
            return []
        }
    }
    private func getTag(from type : PostType)->Int{
        switch type{
        case .groups:
            return 2
        case .event:
            return 3
        
        case .school:
            return 4
        
        case .friends:
            return 1
        case .leaderboard:
            return 6
        default:
            return 0
        }
    }
    func loadDataOnScrollEnd() {
        if loading == false { 
            getPosts()
        }
    }
    
    private func getSelectedTabFromTableView()->Int{
       if let cell = tableView.visibleCells.first as? LeaderboardTabCell{
           return cell.tabSegment.selectedSegmentIndex
        }
        return 0
    }
    
    func createPost(_ parameters : [String : Any], _ attachments : [Media]){
        let uploadPostCell = getUploadPostCell()
        uploadPostCell?.thumbnailImgV.image = nil
        if let media = attachments.first{
            if let data = media.data{//image
                uploadPostCell?.thumbnailImgV.image = UIImage(data: data)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            
            APIManager.fileUploader.createPost(parameters: parameters, media: attachments) { progress in
               
                uploadPostCell?.progressV.progress = progress
            } completion: { response, error in
               
                if error == nil {
                    uploadPostCell?.progressLbl.text = "Done"
                    self.removeFileFromDirectory(filename: "pendingPost.json")
                    UserDefaults.standard.setValue(nil, forKey: "pendingPostParam")
                    self.adapter.ispendingPost = false
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.getPosts(limit: self.adapter.posts.count > 0 ? self.adapter.posts.count : 5, reload: true)
                    }
                    
                }else{
                    uploadPostCell?.progressLbl.text = "Something went wrong"
                    uploadPostCell?.crossBtn.isHidden = false
                    uploadPostCell?.reloadBtn.isHidden = false
                    
                }
                
            }
        }
    }
    
    func getUploadPostCell()->UploadPostCell?{
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UploadPostCell{
            return cell
        }
        return nil
    }
    
    func removeFileFromDirectory(filename: String) {
        let fileManager = FileManager.default
        
        // Specify the directory path where the file exists
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Construct the full file path
        let filePath = documentsDirectory.appendingPathComponent(filename).path
        
        do {
            try fileManager.removeItem(atPath: filePath)
            print("File '\(filename)' removed successfully.")
        } catch {
            print("Error removing file '\(filename)': \(error)")
        }
    }
}
extension HomeController : TabbarControllerProtocol{
    func tabbarDidSelect() {
        //tableView.scrollToTop()
       // self.tableView.reloadData()
       // self.tableView.beginUpdates()
//        self.tableView.setContentOffset( CGPoint(x: 0.0, y: 1.0), animated: false)
       // self.tableView.endUpdates()
        
    }
    
    
}

// MARK: - Actions
extension HomeController {
    
    @IBAction func didTapProfile(_ sender: Any) {
        adapter.ispendingPost = false
        let controller = ProfileController(user: User.me)
        tabBarController?.navigationController?.pushViewController(controller, animated: true)
        
    }
    @objc func moveToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    @IBAction func didTapTabButton(_ sender: UIButton) {
        
        selectTopTab(from: sender.tag)
        updatePostType(index: sender.tag)
        if sender.tag == 6 {
            adapter.type = .leaderboard
            getLeaders(type: typeFilter,reload: true)
        }
        else if sender.tag == 3 {
            adapter.type = .event
//            getEvents()
        }
        else {
            adapter.isLoading = true
            getPosts(reload: true)
            adapter.type = .post
        }
        view.layoutIfNeeded(true)
        tableView.reloadData()

        if sender.tag >= 4 {
//            scrollViewTabs.setContentOffset(CGPoint(x: scrollViewTabs.contentSize.width - scrollViewTabs.frame.width, y: 0), animated: true)
        } else {
            scrollViewTabs.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        self.tableView.beginUpdates()
        self.tableView.setContentOffset( CGPoint(x: 0.0, y: -100.0), animated: false)
        self.tableView.endUpdates()

       
    }
    func selectTopTab(from tag : Int){
        
        tabLabels.forEach { $0.textColor = R.color.sub_title() }
        tabImages.forEach { $0.isHidden = true }
        tabSeperators.forEach{ $0.isHidden = true }
        tabLabels.first { $0.tag == tag }?.textColor = R.color.buttons_green()
        tabImages.first { $0.tag == tag }?.isHidden = false
        let sepView = tabSeperators.first { $0.tag == tag }
        sepView?.isHidden = false
    }
//    func didTapTabButton(with tag: Int) {
//
//        updatePostType(index: tag)
////        tableView.tableHeaderView = storyTableView
//        storyTableView.isHidden = false
//        if tag == 6 {
//            adapter.type = .leaderboard
//            getLeaders(type: typeFilter,reload: true)
////            tableView.tableHeaderView = nil
//            storyTableView.isHidden = true
//            storyTableVHeightConstraint.constant = 0
//            stackHeightConstraint.constant = 46
//        }
//        else if tag == 3 {
//            adapter.type = .event
//            getEvents()
//            storyTableView.isHidden = true
//            storyTableVHeightConstraint.constant = 0
//            stackHeightConstraint.constant = 46
//        }
//        else {
//            adapter.isLoading = true
//            getPosts(reload: true)
//            adapter.type = .post
//            storyTableView.isHidden = false
//            storyTableVHeightConstraint.constant = 105
//            stackHeightConstraint.constant = 120
//        }
//        view.layoutIfNeeded(true)
//        tableView.reloadData()
//
//        if tag >= 4 {
////            scrollViewTabs.setContentOffset(CGPoint(x: scrollViewTabs.contentSize.width - scrollViewTabs.frame.width, y: 0), animated: true)
//        } else {
//            scrollViewTabs.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        }
//        self.tableView.beginUpdates()
//        self.tableView.setContentOffset( CGPoint(x: 0.0, y: 0.0), animated: false)
//        self.tableView.endUpdates()
//
//
//    }
    @IBAction func didTapNotificationButton() {
        let controller = NotificationsController()
        tabBarController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func updatePostType(index: Int) {
        switch index {
        case 0: return selectedPostType = .public
        case 1: return selectedPostType = .friends
        case 2: return selectedPostType = .groups
        case 4: return selectedPostType = .school
        case 5: return selectedPostType = .trending
        case 6: return selectedPostType = .leaderboard
        default: return
        }
    }
    
    
}

//  MARK: - Utility Methods
//extension HomeController {
//
//}

// MARK: - Web APIs
extension HomeController {
    func getStories() {
        APIManager.social.getHomeStories(skip: 0, limit: 200) { [weak self] stories, error in
            guard let self = self else { return }
            if error == nil {
                self.adapter.storyADP.setStories(story: stories)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func getPosts(limit: Int = 5, reload: Bool = false) {
        loading = true
        if selectedPostType == .leaderboard {
            return
        }
        APIManager.social.getHomePosts(postType: selectedPostType, skip: reload ? 0 : adapter.posts.count, limit: limit) { [weak self] posts, error in
            guard let self = self else { return }
            self.adapter.isLoading = false
            self.loading = false
            if error == nil {
                if reload {
                    self.adapter.posts = posts?.posts ?? []
                } else {
                    self.adapter.posts.updateRecord(with: posts?.posts ?? [])
                }
                self.adapter.totalRecord = posts?.total ?? 0
            } else {
                if error?.message.lowercased() == "could not validate credentials. please use valid token or re-login"{
                    //logout users
                    APIManager.auth.logout { response, error in
                        XMPPAppDelegateManager.shared.logoutFromXMPP()
                        Keychain.shared.clear()
                        RealmContextManager.shared.clearRealmDB()
                        Cache.shared.clear()
                        UIApplication.shared.unregisterForRemoteNotifications()
                        Application.shared.switchToLogin()
                    }

                }
                else{
                    self.showErrorWith(message: error!.message)
                }
                
            }
            self.reloadTableViewWithDelay()
        }
    }
    
    func emptyAdapterList(){
        adapter.leaders.removeAll()
        tableView.reloadData()
    }
    
    func getLeaders(type : LeaderBoardTypeFilter = .national,reload: Bool = false) {
        typeFilter = type
        loading = true
        self.adapter.isLoading = true
        emptyAdapterList()
        
        APIManager.social.getLeaderwithFilter(type: type,filter: leaderFilterBy) {[weak self] leader, error in
            
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            self.loading = false
            
            if error == nil {
                if reload {
                    
                    self.leaderResult = leader
                }
                else {
                    
                }
                
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
    }
   
    private func filteredLeaders()->[Leader]{
        switch leaderFilterBy {
        case .all:
            return  leaderResult?.all_time as? [Leader] ?? []
        case .weekly:
            return  leaderResult?.weekly as? [Leader] ?? []
        case .daily:
            return  leaderResult?.daily as? [Leader] ?? []
        case .monthly:
            return  leaderResult?.monthly as? [Leader] ?? []
        case .yearly:
            return  leaderResult?.yearly as? [Leader] ?? []
        }

    }
    private func filterLeader(){
        let leaders = filteredLeaders()
        
//        if leaders.count > 0{
        
           
        self.adapter.leaders = leaders.filter({ obj in
            obj.user != nil
        })
        let dummy = Leader(rank: 0, score: 0)
     
        self.adapter.leaders.insert(dummy, at: 0)
        
           self.reloadTableViewWithDelay()
        
//        }
        
    }
    

    
//    func getNotifications(){
//        APIManager.social.getNotifications { [weak self] notifications, error in
//            guard let self = self else { return }
//            if error == nil {
//                let unreadCount = notifications.unreadCount()
//                if unreadCount > 99 {
//                    lblBadgeNotifications.text = "99+"
//                } else {
//                    lblBadgeNotifications.text = "\(unreadCount)"
//                }
//                viewBadgeNotifications.isHidden = unreadCount == 0
//                
//            } else {
//                self.showErrorWith(message: error!.message)
//            }
//        }
//    }
    
//    func getEvents() {
//        APIManager.social.getEvents(query: .public) { [weak self] events, error in
//            guard let self = self else { return }
//            self.adapter.isLoading = false
//            if error == nil {
//                self.adapter.events = events ?? []
//            } else {
//                self.showErrorWith(message: error!.message)
//            }
//        }
//    }
    
//    func getMyEvents() {
//        APIManager.social.getMyEvents(query: .me) { [weak self] eventsIAmGoing, eventsICreated, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested, error  in
//            guard let self = self else { return }
//            
//            if error == nil {
//                self.eventsIAmInvited = eventsIAmInvited ?? []
//                if (self.eventsIAmInvited.count > 0) {
//                    let controller = EventInviteController()
//                    controller.allInvitedEvents = self.eventsIAmInvited
//                    self.presentPanModal(controller)
//                }
//            }
//        }
//    }
    
    func reloadTableViewWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableView.reloadData()
        }
    }
     
    @objc func appEnteredFromBackground() {
       // ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView, appEnteredFromBackground: true)
    }
}

extension HomeController : HomeViewProtocol{
    func prepareUI() {
        
    }
    func setProfileImage(){
        imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
    }
    func updateNotificationBadge(_ text: String) {
        lblBadgeNotifications.text = text
    }
    func hideNotificationBadge(_ isHidden: Bool) {
        viewBadgeNotifications.isHidden = isHidden
    }
}
