//
//  FavoriteAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 13/12/2022.
//

import Foundation
import UIKit

class FavoriteAdapter: NSObject {
    var parent: FavoriteViewController
    var tableView: UITableView!
    private var posts: [Post] = []
    private var groups: [Group] = []
    private var events: [Event] = []
    private var friends: [SearchFriends] = []

    private var postFactory: PostFactory
    private var eventFactory: EventsFactory
    private var groupFactory: GroupsFactory
    private var friendFactory: GroupsFactory

    private var defaultType: FavoriteCategories
    private var showSkeleton: Bool = false
    private var postsTotalRecords = 0
    init(parent:FavoriteViewController, tableView: UITableView, favoriteType: FavoriteCategories) {
        self.parent = parent
        self.tableView = tableView
        self.defaultType = favoriteType
        self.postFactory = PostFactory(tableView: self.tableView)
        self.eventFactory = EventsFactory(tableView: self.tableView)
        self.groupFactory = GroupsFactory(tableView: self.tableView)
        self.friendFactory = GroupsFactory(tableView: self.tableView)
        super.init()
        self.configure()
        self.postFactory.updateDelegate(delegate: self, factoryDelegate: self)
    }
    
    func configure() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    func updateDefaultType(type:FavoriteCategories) {
        self.defaultType = type
    }
    func setSkeletonView(enable: Bool) {
        self.showSkeleton = enable
        self.tableView.reloadData()
    }
    func setPosts(post: [Post], totalRecords: Int) {
        self.postsTotalRecords = totalRecords
        self.posts = post
        self.showSkeleton = false
        self.tableView.reloadData()
    }
    func setEvents(event: [Event]) {
        self.events = event
        self.showSkeleton = false
        self.tableView.reloadData()
    }
    func setGroups(groups: [Group]) {
        self.groups = groups
        self.groupFactory.groups = groups
        self.showSkeleton = false
        self.tableView.reloadData()
    }
    
    func setFriends(friends: [SearchFriends]) {
        self.friends = friends
        //self.groupFactory.groups = groups
        self.showSkeleton = false
        self.tableView.reloadData()
    }
}

extension FavoriteAdapter:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if defaultType == .post {
            return self.postFactory.tableView(numberOfRowsInSection: section, posts: self.posts, showSkeleton: showSkeleton)
        }
        if defaultType == .events {
            return self.eventFactory.tableView(numberOfRowsInSection: section, events: self.events, showSkelton: showSkeleton)
        }
        if defaultType == .groups {
            return self.groupFactory.tableView(numberOfRowsInSection: section, showSkeleton: showSkeleton)
        }
//        if defaultType == .friends {
//            return self.groupFactory.tableView(numberOfRowsInSection: section, showSkeleton: showSkeleton)
//        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.defaultType == .post {
            return self.postFactory.getCell(posts: self.posts, indexPath: indexPath, totalRecord: self.postsTotalRecords, showSkeleton: showSkeleton)
        }
        if self.defaultType == .events {
            return self.eventFactory.getCell(events: self.events, indexPath: indexPath, totalRecord: self.events.count, showSkeleton: showSkeleton)
        }
        if self.defaultType == .groups {
            return self.groupFactory.getCell(indexPath: indexPath, totalRecord: self.groups.count, showSkeleton: showSkeleton)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if defaultType == .post {
            return postFactory.tableView(heightForRowAt: indexPath, showSkeleton: showSkeleton)
        }
        if defaultType == .events {
            return eventFactory.tableView(heightForRowAt: indexPath)
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.defaultType  == .events {
            if let event = events.object(at: indexPath.row) {
                let controller = EventDetailsController(event: event)
                let navC = parent.tabBarController?.navigationController ?? parent.navigationController
                navC?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension FavoriteAdapter: PostCellActions {
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
    
    func showAllReactions(indexPath: IndexPath, postId: String) {
        APIManager.social.getPostDetails(postId: postId) { post, error in
            if let error = error {
                self.parent.showErrorWith(message: error.message)
            } else {
                self.parent.showAllReactions(emojis: post?.reactions ?? [])
            }
        }
    }
    
    func manageFavorites(indexPath: IndexPath, postId: String) {
        let post = self.posts[indexPath.row]
        _ = post.isFavourite ?? false
        self.unfavorite(postId: post.postID, type: .posts)
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
}
extension FavoriteAdapter: PostFactoryActions {
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
        navC?.pushViewController(controller, animated: true)
    }
    
    func tapMoreButton(sender: Int) {
        guard let post = posts.object(at: sender) else { return }
        let indexPath = IndexPath(row: sender, section: 0) // assuming cell is for first or only section of table view

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        var sheetActions: [String]?

        if post.user?.isMe == true {
            sheetActions =  ["Delete"]
//
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//
//            }))
        } else {
            let favoriteTitle =  "Remove From Favorite"
           sheetActions =  [favoriteTitle, "Report"]
                showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)
//            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
//
//            }))
        }
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
//        if post.user?.isMe == true {
//            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//                let indexPath = IndexPath(row: sender, section: 1)
//                self.deletePost(post: post, indexPath: indexPath)
//            }))
//        } else {
//            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
//
//            }))
//        }
//        alert.addAction(UIAlertAction(title:"Remove from Favourite", style: .default, handler: { _ in
//            if post.isFavourite == true {
//                self.unfavorite(postId: post.postID, type: .posts)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        parent.present(alert, animated: true, completion: nil)
    }
        
        func showActionSheet(post: Post, indexPath: IndexPath, sheetOptions:[String]) {
           
            let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
                //self.selectedGender = selected
                // self.genderTextfield.text = selected
                self.sheetButtonActions(selectedOption: selected, reportContentObject: self.getReportContentObjectWithData(post: post), indexPath: indexPath)
            })
            
            self.parent.presentPanModal(genericPicker)
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
                break
            }
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
        
       
}

extension FavoriteAdapter {
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

    func unfavorite(postId: String, type: FavoriteType) {
        APIManager.social.removeFromFavorite(type: type, id: postId) { [weak self] error in
            if error == nil {
                if let index = self?.posts.firstIndex(where: { $0.postID == postId }) {
                    self?.posts.remove(at: index)
                    self?.tableView.reloadData()


                }
            } else {
                self?.parent.showErrorWith(message: error!.message)
            }
        }
    }
    private func showPostDetail(post : Post, comment: String?) {
        let controller = PostDetailsController(post: post, prefilledComment: comment)
        let navC = parent.tabBarController?.navigationController ?? parent.navigationController
        navC?.pushViewController(controller, animated: true)
    }
}
