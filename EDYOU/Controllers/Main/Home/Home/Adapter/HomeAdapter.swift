//
//  HomeAdapter.swift
//  EDYOU
//
//  Created by  Mac on 09/09/2021.
//

import UIKit
import AVKit
import PanModal

class HomeAdapter: NSObject {
    
    
    // MARK: - Properties
    
    weak var tableView: UITableView!
    var parent: HomeController? {
        return tableView.viewContainingController() as? HomeController
    }
    var ispendingPost = false{
        didSet{
            
            tableView.reloadData()
            
        }
    }
//    var pendingParamters : [String : Any]?
//    var pendingMedia : [Media]?
    
    var posts: [Post] = [] {
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
    var lastPlayduartion : [Int:Float] = [:]
    var totalRecord: Int = -1
    var isLoading = true
    var events = [Event]()
    var leaders = [Leader]()
    var type: PostType = .post
    var cellHeightDictionary = NSMutableDictionary()
    
    var VideoPlayingIndex = -1
    var videoIndexes = [Int]()
    enum PostType {
        case event, post, leaderboard
    }
    private var lastContentOffset: CGFloat = 0
    var storyADP:StoryAdapater!
   // var cellHeights: [IndexPath: CGFloat] = [:]
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        storyADP = StoryAdapater(tableView: tableView)
        configure()
    }
    func configure() {
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(StoriesCell.nib, forCellReuseIdentifier: StoriesCell.identifier)
        tableView.register(NoPostsCell.nib, forCellReuseIdentifier: NoPostsCell.identifier)
        tableView.register(NoMorePostCell.nib, forCellReuseIdentifier: NoMorePostCell.identifier)
        tableView.register(EventTableCell.nib, forCellReuseIdentifier: EventTableCell.identifier)
        tableView.register(HidePostTableViewCell.nib, forCellReuseIdentifier: HidePostTableViewCell.identifier)
        tableView.register(LeaderboardTabCell.nib, forCellReuseIdentifier: LeaderboardTabCell.identifier)
        tableView.register(TopLeadersCell.nib, forCellReuseIdentifier: TopLeadersCell.identifier)
        tableView.register(RankHeaderCell.nib, forCellReuseIdentifier: RankHeaderCell.identifier)
        tableView.register(RankCell.nib, forCellReuseIdentifier: RankCell.identifier)
        tableView.register(StoriesCell.nib, forCellReuseIdentifier: StoriesCell.identifier)
        tableView.register(UploadPostCell.nib, forCellReuseIdentifier: UploadPostCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 800
       
    }
    
}

// MARK: - Actions
extension HomeAdapter {
    @objc func didTapProfileButton(_ sender: UIButton) {
        if let groupInfo = posts.object(at: sender.tag)?.groupInfo {
            didTapGroupButton(sender)
        }
        else{
            guard let user = posts.object(at: sender.tag)?.user else { return }
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            let controller = ProfileController(user: user)
            navC?.popToRootViewController(animated: false)
            navC?.pushViewController(controller, animated: true)
        }
        
    }
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag) else { return }
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        var sheetActions: [String]?
        if post.user?.isMe == true {
            sheetActions =  [favoriteTitle,"Delete"]
            showActionSheet(post: post,  indexPath: indexPath, sheetOptions: sheetActions!)
            
        } else {
            sheetActions =  [favoriteTitle,"Hide this Post", "Report"]
            showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)
        }
    }
    @objc func didTapGroupButton(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag), let groupID = post.groupInfo?.groupID else { return }
        
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
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
    
    @objc func didTapUnHidePost(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag) else { return }
        let indexPath = IndexPath(row: sender.tag, section: 0)
        manageHidePost(post: post, indexPathofRow: indexPath)
    }
    
    @objc func didTapReportPost(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag) else { return }
        moveToReportContentScreen(reportContentObject: self.getReportContentObjectWithData(post: post))
        
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
            manageHidePost(post: post, indexPathofRow: indexPath)
            //  saveSettings(contentID: reportContentObject.contentID!, contentKey: "hide_posts")
        case "Report":
            moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
            deletePostWithAlert(postid: reportContentObject.contentID!, indexPath: indexPath)
        default:
            favorite(postId: reportContentObject.contentID!)
            
        }
    }//kd9j-ujt1
    
    func deletePost(postid: String, indexPath: IndexPath) {
        let deletedPost = posts.filter({$0.postID == postid})
        self.deletePost(post: deletedPost[0], indexPath: indexPath)
        
    }
    func deletePostWithAlert(postid: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete post permanently?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deletePost(postid: postid, indexPath: indexPath)
        }))
        self.parent!.present(alert, animated: true, completion: nil)
        
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


// MARK: - TableView DataSource & Delegate
extension HomeAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        var totalRows = 0
        if isLoading {
            totalRows = 10
        }
        else if type == .event {
            totalRows = events.count
        }
        else if type == .leaderboard {
            totalRows = leaders.count
        }
    
        
        else if posts.count == 0 {
            switch parent?.selectedPostType {
            case .groups:
                tableView.addEmptyView(EmptyCellConfirguration.group.title, EmptyCellConfirguration.group.shortDescription, EmptyCellConfirguration.group.image)
                break
            case .event:
                tableView.addEmptyView(EmptyCellConfirguration.events.title, EmptyCellConfirguration.events.shortDescription, EmptyCellConfirguration.events.image)
                break
            default:
                tableView.addEmptyView(EmptyCellConfirguration.posts.title, EmptyCellConfirguration.posts.shortDescription, EmptyCellConfirguration.posts.image)
                break
                
            }
            
            totalRows = 1
        }
        else{
            totalRows = posts.count + 1
        }
        
        if ispendingPost{
            totalRows += 1
        }
        return totalRows
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && type == .post {
            let top : CGFloat = 0//Application.shared.safeAreaInsets.top
            return top + 165 //parent?.storyTblVHeight ?? 120
        }
        if ispendingPost && indexPath.row == 1{
            return 56
        }
        
        let post = posts.object(at: indexPath.row )
        
        if type == .leaderboard {
            if indexPath.row == 0{
                return 64
            }
            else if indexPath.row == 1{
//                return 260//leader
                return UITableView.automaticDimension
            }
            else{
                return 128//rank
            }
            
        }
        
        if isLoading {
            
            return 260
            
            
        }
        if type == .event {
            return 150
        }
        
        if (post?.isHidePost ?? false) {
            return UITableView.automaticDimension
        }
        
        
        if let d = cellHeightDictionary.object(forKey: indexPath) as? NSDictionary, let height = d["height"] as? CGFloat, let id = d["id"] as? String, id == posts.object(at: indexPath.row)?.postID {
            return height
        }
        
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && type == .post {
            return
        }

        let post = posts.object(at: indexPath.row )
        let hidePost = post?.isHidePost ?? false
        if isLoading == false && type != .event && type != .leaderboard &&  hidePost {
            let d: NSDictionary = [
                "height": cell.frame.height,
                "id": posts.object(at: indexPath.row)?.postID ?? ""
            ]
            cellHeightDictionary.setObject(d, forKey: indexPath as NSCopying)
        }
        if type == .leaderboard{
          //  print("leaderboard")
            
            
        }
        else if let cell = cell as? ImagePostCell {
            
            cell.collectionView.tag = indexPath.row
            if let videoCell = cell.collectionView.visibleCells.first as? PostVideoCell{
                //                videoCell.imgPost.image = nil
                videoCell.resetVideoData()
                if let value = lastPlayduartion[indexPath.row] {
                    var time2: CMTime = CMTimeMake(value: Int64(value * 1000 as Float), timescale: 1000)
                    let dur = videoCell.player?.currentItem?.duration ?? CMTime.zero
                    
                    //                    let duration = Float(CMTimeGetSeconds( ?? CMTime.zero))
                    if time2 >= dur{
                        time2 = CMTime.zero
                    }
                    videoCell.player?.seek(to: time2)
                    
                }
                if indexPath.row == videoIndexes[0]{
                    //play bedefault cell
                    
                }
                else{
                    videoCell.layoutSubviews()
                    
                }
                
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        if indexPath.row == 0 && (type == .post) {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoriesCell.identifier, for: indexPath) as! StoriesCell
            cell.tabPersonalProfile = {
                self.storyADP.didTapAddStoryButton()
            }
            cell.stories = self.storyADP.getStories()
            cell.parent = parent
            cell.collectionView.reloadData()
            return cell
        }


        if isLoading {
            if type == .leaderboard{
                if indexPath.row == 0{
                    if let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTabCell.identifier, for: indexPath) as? LeaderboardTabCell{
                        cell.beginSkeltonAnimation()
                        return cell
                    }
                    
                    
                    
                }
                else if indexPath.row == 1{
                    if let cell = tableView.dequeueReusableCell(withIdentifier: TopLeadersCell.identifier, for: indexPath) as? TopLeadersCell{
                        
                        cell.beginSkeltonAnimation()
                        return cell
                    }
                    
                    
                }
                else{
                    
                    if let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.identifier, for: indexPath) as? RankCell{
                        //                    cell.bgView.isHidden = true
                        cell.bgV.layer.cornerRadius = 8
//                        cell.bgV.layer.borderWidth = 1.0
                        cell.topSepratorV.isHidden = true//indexPath.row != 2
                        cell.beginSkeltonAnimation()
                        return cell
                    }
                }
                
            }
            else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
                cell.beginSkeltonAnimation()
                return cell
                
            }
            
        }
        if ispendingPost && indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: UploadPostCell.identifier, for: indexPath) as! UploadPostCell
            cell.progressLbl.text = "Posting..."
            cell.thumbnailImgV.image = nil
//            if let parameters = self.pendingParamters{
//                self.pendingParamters = nil
//                if let media = pendingMedia{
//                    self.pendingMedia = nil
//                    cell.createPost(parameters, media) { reloadData in
//                        if reloadData ?? false{
//                            self.ispendingPost = false
//                            self.parent?.getPosts(limit: self.posts.count > 0 ? self.posts.count : 5, reload: true)
//                        }
//                    }
//                }else{
//                    cell.createPost(parameters, []) { reloadData in
//                        if reloadData ?? false{
//                            self.ispendingPost = false
//                            self.parent?.getPosts(limit: self.posts.count > 0 ? self.posts.count : 5, reload: true)
//
//                        }
//                    }
//                }
//
//            }
            return cell
        }
        if type == .event {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableCell.identifier, for: indexPath) as! EventTableCell
            if isLoading {
                cell.showSkeleton()
            }
            else {
                cell.setData(events[indexPath.row])
            }
            return cell
        }
        
        if type == .leaderboard {
            if indexPath.row == 0{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTabCell.identifier, for: indexPath) as! LeaderboardTabCell
                cell.selectedTab(parent?.typeFilter ?? .friends)
                cell.tabChange = { tag in
                   
                    //0 for friends
                    //1 for school
                    //2 for today
                    //3 for national
                   
                    switch tag {
                    case 0:
                        print("Friends")
//                        self.showFriendsDropDown()
                        self.parent?.getLeaders(type: .friends,reload: true)
                        break
                    case 1:
                        print("School")
                        self.parent?.getLeaders(type: .school,reload: true)
                        break
                    case 2:
                        print("Today")
                        
                        self.showDropDown()
                        break
                    case 3:
                        print("national")
                       // self.showDropDown()
                        self.parent?.getLeaders(type: .national,reload: true)
                        break
                    default:
                        break
                    }
                }
                let filter = parent?.leaderFilterBy.getValue() ?? ""
                
//                cell.tabLabels[2].text = filter.capitalized
                
//                cell.tabLabels[0].text = getFilterType(parent?.filterTag ?? 0)
                cell.tabLabels[0].text = filter.capitalized
                cell.endSkeltonAnimation()
                return cell
                //                cell.bgView.isHidden = false
            }
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: TopLeadersCell.identifier, for: indexPath) as! TopLeadersCell
                //                cell.bgView.isHidden = false
                
               
                let filter = parent?.leaderFilterBy ?? .all
               
                cell.setupData(leaders[indexPath.row],selectedFilter: filter)
                
                cell.endSkeltonAnimation()
                return cell
            }
            
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: RankCell.identifier, for: indexPath) as! RankCell
//                if indexPath.row < leaders.count{
                    cell.setupData(leaders[indexPath.row])
//                }
                cell.bgV.layer.cornerRadius = 8
//                        cell.bgV.layer.borderWidth = 1.0
                cell.topSepratorV.isHidden = true//indexPath.row != 2
                cell.endSkeltonAnimation()
                return cell
            }
            
        }
        
        
        
        
        
        let post = posts.object(at: indexPath.row - 1 )
        if (post?.isHidePost ?? false) {
            let cell = tableView.dequeueReusableCell(withIdentifier: HidePostTableViewCell.identifier, for: indexPath) as! HidePostTableViewCell
            cell.reportPostButton.tag = indexPath.row - 1
            cell.unhidePostButton.tag = indexPath.row - 1
            cell.reportPostButton.addTarget(self, action: #selector(didTapReportPost(_:)), for: .touchUpInside)
            cell.unhidePostButton.addTarget(self, action: #selector(didTapUnHidePost(_:)), for: .touchUpInside)
            
            return cell
            
        } else {
            
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
                cell.btnMore.tag = indexPath.row - 1
                cell.btnProfile.tag = indexPath.row - 1
                cell.btnGroupName.tag = indexPath.row - 1
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
                cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                cell.actionDelegate = self
                
               // cellHeights[indexPath] = cell.frame.height
                
                if indexPath.row == 0{
                    //print 0 index
                    //                    print("first index ")
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.09) {
                        if cell.collectionView.visibleCells.first is PostVideoCell{
                            //                            print("video cells : \(videoCell)")
                            self.scrollViewDidEndDragging(tableView, willDecelerate: false)
                        }
                    }
                }
                return cell
            } else if post?.isBackground == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextWithBgPostCell.identifier, for: indexPath) as! TextWithBgPostCell
                cell.setData(post)
                cell.indexPath = indexPath
                cell.actionDelegate = self
                cell.btnMore.tag = indexPath.row - 1
                cell.btnProfile.tag = indexPath.row - 1
                cell.btnGroupName.tag = indexPath.row - 1
                cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
                cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
                cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            cell.setData(post)
            cell.indexPath = indexPath 
            cell.actionDelegate = self
            cell.btnMore.tag = indexPath.row - 1
            cell.btnProfile.tag = indexPath.row - 1
            cell.btnGroupName.tag = indexPath.row - 1
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && type == .post {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        if type == .event {
            if let event = events.object(at: indexPath.row) {
                let controller = EventDetailsController(event: event)
                parent?.tabBarController?.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }
        else if type == .leaderboard {
            
            if indexPath.row > 0{
                if let user = leaders[indexPath.row].user {
                    
                    let controller = ProfileController(user: user)
                    let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
                    navC?.pushViewController(controller, animated: true)
                    
                }
                
            }
            
            
            return
        }
        else {
            if let post = posts.object(at: indexPath.row-1) {
                if !post.isHidePost{
                    self.stopPreviousPlayingCellWithVideo {
                        self.showPostDetail(post: post, comment: nil)
                    }
                }
                
            }
        }
    }
    private func showPostDetail(post : Post, comment: String?) {
        let controller = PostDetailsController(post: post, prefilledComment: comment)
        parent?.tabBarController?.navigationController?.pushViewController(controller, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = self.parent?.topVHeight.constant ?? Application.shared.safeAreaInsets.top
        self.parent?.topView.backgroundColor = R.color.navigationColor()
        if lastContentOffset > scrollView.contentOffset.y && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
            // move up
//            print("Scroll Direction up\(lastContentOffset)")
            // swipes from top to bottom of screen -> down
//            UIView.animate(withDuration: 0.5) {
////                self.parent?.navigationController?.setNavigationBarHidden(false, animated: false)
//            }
//            if lastContentOffset > 100{
//                parent?.tableviewTopConstraint.constant  = 0
//            }
            UIView.animate(withDuration: 0.5) { //1
                 
                self.parent?.topViewTopConstraint.constant = 0
                
//                self.parent?.topView.frame = CGRect(x: 0, y:0, width: self.tableView.frame.width, height: height) //2
//                self.button.center = self.view.center //3
            }
       
            
        } else if lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0 {
            // move down
//            if lastContentOffset < 100{
//                parent?.tableviewTopConstraint.constant  = lastContentOffset
//            }
           
//            print("Scroll Direction down\(lastContentOffset)")
//            UIView.animate(withDuration: 0.5) {
////                self.parent?.navigationController?.setNavigationBarHidden(true, animated: false)
//            }
//            parent?.tableviewTopConstraint.constant  = 150
           
            let height = self.tableView.contentSize.height
            let tblVHeight = self.tableView.height - Application.shared.safeAreaInsets.top - Application.shared.safeAreaInsets.bottom
            if height > tblVHeight{
                
                UIView.animate(withDuration: 0.5) {
                    
                    self.parent?.topViewTopConstraint.constant = -140
                
                }
            }
        }
        
        // update the new position acquired
        lastContentOffset = scrollView.contentOffset.y
        
        if scrollView == tableView {
            
            
            let offsetYBottom = tableView.contentOffset.y + tableView.frame.height
            if offsetYBottom >= (tableView.contentSize.height - 260) && posts.count < totalRecord {
                if type != .leaderboard{
                    parent?.loadDataOnScrollEnd()
                }
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? ImagePostCell {
            
            if let videoCell = cell.collectionView.visibleCells.first as? PostVideoCell{
                lastPlayduartion =  [indexPath.row : videoCell.playerTime]
                videoCell.player?.pause()
            }
        }
        
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !(scrollView.isDecelerating) && !(scrollView.isDragging) {
            // manageVideo()
            
            
        }
    }
    
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
    
    private func showFriendsDropDown(){
        let options = ["Friends", "National", "School"]
        let previousSelectedOption = parent?.typeFilter.rawValue.capitalized
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "", completion: { selected in
            if (selected.contains("Friends")) {
               
                self.parent?.getLeaders(type: .friends,reload: true)
               
            } else if (selected.contains("National")) {
                
                self.parent?.getLeaders(type: .national,reload: true)
            }
            else if (selected.contains("School")) {
                
                self.parent?.getLeaders(type: .school,reload: true)
            }
           
        })
        self.parent?.presentPanModal(userEventFilter)
    }
    
    private func showDropDown(){
        let options = ["Today", "Weekly","Monthly","Yearly"]
        let previousSelectedOption = parent?.leaderFilterBy.getValue().capitalized
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "", completion: { selected in
            if (selected.contains("Today")) {
                self.parent?.leaderFilterBy = .daily
               
               
            } else if (selected.contains("Weekly")) {
                self.parent?.leaderFilterBy = .weekly
                
            }else if (selected.contains("Monthly")) {
                self.parent?.leaderFilterBy = .monthly
               
            }else if (selected.contains("Yearly")) {
                self.parent?.leaderFilterBy = .yearly
                
            }
           
        })
        self.parent?.presentPanModal(userEventFilter)
    }
    private func getFilterType(_ tag : Int)->String{
        switch tag {
        case 1:
            return "Friends"
            
        case 2:
            return "National"
            
        default:
            return "School"
            
        }
    }
    
}

extension HomeAdapter : PostCellActions {
    
    
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
        guard let post = posts.object(at: indexPath.row-1) else { return }
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
        guard let post = posts.object(at: indexPath.row) else { return }
        self.showPostDetail(post: post, comment: comment)
    }
    
    private func handleEmojiSelection(post: Post, indexPath: IndexPath, reaction: String,cell: PostCell) {
        var addEmoji = true
        if let myReaction = post.myReaction?.likeEmotion {
            self.posts[indexPath.row-1].removeReaction(myReaction)
            addEmoji = myReaction != reaction.encodeEmoji()
        }
        if addEmoji {
            self.posts[indexPath.row-1].addReaction(reaction.encodeEmoji())
        }
        cell.updatePostData(data: self.posts[indexPath.row-1])
        self.postEmojiReaction(postId: post.postID, isAdd: addEmoji, reaction: reaction.encodeEmoji(), cell: cell, indexPath: indexPath)
    }
    
    private func postEmojiReaction(postId: String, isAdd: Bool, reaction: String, cell:PostCell, indexPath: IndexPath) {
        APIManager.social.addReaction(postId: postId, isAdd: isAdd, reaction: reaction) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                if isAdd {
                    self.posts[indexPath.row-1].removeReaction(reaction)
                } else {
                    self.posts[indexPath.row-1].addReaction(reaction)
                }
                cell.updatePostData(data: self.posts[indexPath.row-1])
                //                cell.addReaction(self.posts[indexPath.row].myReaction, totalReactions: self.posts[indexPath.row].totalLikes ?? 0)
            }
        }
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
    
    func manageHidePost(post: Post, indexPathofRow: IndexPath) {
        var saved = AppDefaults.shared.savedHidePosts
        if let index = saved.firstIndex(of: post.postID), index >= 0 {
            saved.remove(at: index)
            self.posts[indexPathofRow.row].isHidePost = false
            cellHeightDictionary = [:]
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
        
        let tmp = leaders.filter { obj in
            obj.rank != 0 && obj.score != 0 && obj.user != nil
        }
        
        if let user = tmp.object(at: sender.tag)?.user {
            
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            navC?.pushViewController(controller, animated: true)
            
        }
    }
}

// MARK: - APIs
extension HomeAdapter {
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
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
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
            } else {
                self.tableView.beginUpdates()
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.reloadData()
                self.tableView.endUpdates()
                
            }
        }
        
    }
    
}

//extension HomeAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: EmptyCellConfirguration.posts.title, attributes: [NSAttributedString.Key.font :  UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black])
//    }
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let description = "Add a new feeds for university friends" //NetworkMonitor.shared.isInternetAvailable ? "Add a new feeds for university friends" : "please check your internet connection"
//        return NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: R.color.sub_title()!])
//    }
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return EmptyCellConfirguration.posts.image
//    }
//}

extension HomeAdapter{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let y = tableView.contentOffset.y
//        print("ScrolltableView : \(y)")
        let tblVHeight = tableView.frame.height
//        print("ScrolltableViewHeight : \(tblVHeight)")
//        print("::content : y \(y)")
        if y > 0 &&  y < tblVHeight{
            // Scrolling down, header disappears with animation
//            print("Scroll down")
//            UIView.animate(withDuration: 0.3) {
//                self.headerView.frame.origin.y = CGFloat(-self.yourHeaderHeight)
            
//            }
        } else if y <= 0  {
//            print("Scroll up")
//            print("Scroll equal to 0")
//            UIView.animate(withDuration: 0.5) {
//                parent?.navigationController?.setNavigationBarHidden(false, animated: false)
//            }
            
            // Scrolling up, header reappears with animation
//            UIView.animate(withDuration: 0.3) {
//                self.headerView.frame.origin.y = 0
//            }
        }
        
    }
}

