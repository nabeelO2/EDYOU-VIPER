//
//  ShowCommentsAdapter.swift
//  EDYOU
//
//  Created by imac3 on 29/08/2023.
//

import Foundation

import UIKit

class ShowCommentsAdapter:NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var isLoading = true

    var parent: ShowCommentsController? {
        return tableView.viewContainingController() as? ShowCommentsController
    }
    
    var post: Post {
        didSet {
            self.sortPostComments()
        }
    }
    
    // MARK: - Initializers
    init(tableView: UITableView, post: Post) {
        self.post = post
        super.init()

        self.tableView = tableView
        configure()
    }
    
    var postComments: [Comment] = []
    
    func configure() {
//        tableView.register(PostDetailsImageCell.nib, forCellReuseIdentifier: PostDetailsImageCell.identifier)
//        tableView.register(PostDetailsTextCell.nib, forCellReuseIdentifier: PostDetailsTextCell.identifier)
        tableView.register(PostDetailsTextWithBgCell.nib, forCellReuseIdentifier: PostDetailsTextWithBgCell.identifier)
        tableView.register(CommentsHeaderTableViewCell.nib, forCellReuseIdentifier: CommentsHeaderTableViewCell.identifier)
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}



// MARK: - Actions
extension ShowCommentsAdapter {
    @objc func didTapLikeCommentButton(_ sender: UIButton) {
        let comment = self.postComments[sender.tag]
        guard let id = comment.commentID else { return }

        self.parent?.showEmojiController(completion: { selected in
            
            APIManager.social.like(postId: self.post.postID, commentId: id, isLiked: true, type: comment.commentType, emoji: selected) { error in
                if error == nil {
                    //self.parent?.getPostDetails()
                } else {
                    self.parent?.showErrorWith(message: error!.message)
                }
            }
            
        })
    }
    
    @objc func didTapPostProfileButton(_ sender: UIButton) {
        guard let user = post.user else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.popToRootViewController(animated: false)

        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapTotalLikesButton(_ sender: UIButton) {
        let controller = UsersListController(title: "Likes", users: post.reactions?.users ?? [])
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapCommentProfileButton(_ sender: UIButton) {
        guard let user = post.comments?.object(at: sender.tag)?.owner else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapGroupButton(_ sender: UIButton) {
        guard let groupID = post.groupInfo?.groupID else { return }
        
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
    }
}


// MARK: - TableView DataSource and Delegates
extension ShowCommentsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isLoading {
            return 3
        } else {
            return self.postComments.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            cell.beginSkeltonAnimation()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        cell.setData(self.postComments[indexPath.row], actionDelegate: self)
        cell.isUserInteractionEnabled = true
        cell.btnLike.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        cell.btnReply.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(didTapLikeCommentButton(_:)), for: .touchUpInside)
        cell.btnReply.addTarget(self, action: #selector(showReplyForComment(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if  self.postComments.count > 0 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: CommentsHeaderTableViewCell.identifier)
            
            (headerView as? CommentsHeaderTableViewCell)?.topView.isHidden = true
            (headerView as? CommentsHeaderTableViewCell)?.closeBtn.isHidden = false
            (headerView as? CommentsHeaderTableViewCell)?.closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            return headerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.postComments.count > 0 { return 44}
        else  { return 0 }
    }
    func stopPreviousPlayingCellWithVideo(_ onResponse: @escaping (() -> Void)){
        tableView.visibleCells.forEach { cell in
//             let indexP = IndexPath(row: index, section: 0)
                if let cell = cell as? PostDetailsImageCell{
                    if let videoCell = cell.collectionView.visibleCells.first as? PostImageCell{
                        videoCell.pause()
//                        returnResponse(index)
                    }
                }
            
        }

        onResponse()
    }
    
    @objc func closeAction(){
        parent?.dismiss(animated: true)
    }
    
}


extension ShowCommentsAdapter: PostCellActions {
    
    func manageFavorites(indexPath: IndexPath, postId: String) {
        let isFavorite = post.isFavourite ?? false
        if isFavorite {
            self.unfavorite(postId: postId)
        } else {
            self.favorite(postId: postId)
        }
    }
    
    func showAllReactions(indexPath: IndexPath, postId: String) {
       
        self.parent?.showAllReactions(emojis: self.post.reactions ?? [])
    }
    
    func tapOnComments(indexPath: IndexPath, comment: String?) {
        
    }
    
    func showReactionPanel(indexPath: IndexPath, postId: String) {
        
    }
    
    func tapOnReaction(indexPath: IndexPath, reaction: String) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? PostDetailCellUpdateProtocol else { return }
        if reaction.isEmpty {
            self.parent?.showEmojiController(completion: { selectedEmoji in
                self.handleEmojiSelection(post: self.post, indexPath: indexPath, reaction: selectedEmoji, cell: cell)
            })
        } else {
            self.handleEmojiSelection(post: post, indexPath: indexPath, reaction: reaction, cell: cell)
        }
    }
    
    private func handleEmojiSelection(post: Post, indexPath: IndexPath, reaction: String,cell: PostDetailCellUpdateProtocol) {
        var addEmoji = true
        if let myReaction = post.myReaction?.likeEmotion {
            self.post.removeReaction(myReaction)
            addEmoji = myReaction != reaction.encodeEmoji()
        }
        if addEmoji {
            self.post.addReaction(reaction.encodeEmoji())
        }
        cell.updatePostData(data: self.post)
        self.postEmojiReaction(postId: post.postID, isAdd: addEmoji, reaction: reaction.encodeEmoji(), cell: cell, indexPath: indexPath)
    }
    
    private func postEmojiReaction(postId: String, isAdd: Bool, reaction: String, cell:PostDetailCellUpdateProtocol, indexPath: IndexPath) {
        APIManager.social.addReaction(postId: postId, isAdd: isAdd, reaction: reaction) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                if isAdd {
                    self.post.removeReaction(reaction)
                } else {
                    self.post.addReaction(reaction)
                }
                cell.updatePostData(data: self.post)
            }
        }
    }
    
}

extension ShowCommentsAdapter {
    @objc func showReplyForComment(sender: UIButton) {
        let comment = self.postComments[sender.tag]
        var commentId = comment.commentID ?? ""
        if comment.commentType == .child {
            commentId = comment.parentCommentId ?? ""
        }
        self.parent?.parentCommentId = commentId
        self.parent?.txtComment.becomeFirstResponder()
        self.parent?.previewReplyCell(comment)
        
    }
}

extension ShowCommentsAdapter {
    func sortPostComments() {
        
        var tempComments: [Comment] = []
        for comment in (self.post.comments ?? []) {
            tempComments.append(comment)
            tempComments.append(contentsOf: comment.childComments)
        }
        self.postComments = tempComments
    }
}

extension ShowCommentsAdapter: CommentActionProtocol {
    func moreOptionTappedForComment(comment: Comment) {
        if comment.owner?.isMe ?? false {
            self.showDeleteOption(comment: comment)
        } else {
            self.showReportOption(comment: comment)
        }
    }
    
    func profileTappedForComment(comment: Comment) {
        if comment.owner?.isMe ?? false {
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            let controller = ProfileController(user: User.me)
            navC?.pushViewController(controller, animated: true)
        } else {
            guard let user = comment.owner else { return }
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            let controller = ProfileController(user: user)
            navC?.pushViewController(controller, animated: true)
        }
    }
    
    private func showDeleteOption(comment: Comment) {
        self.parent?.showConfirmationAlert(title: "Are you sure?", description: "You want to delete this comment", buttonTitle: "Delete", style: .destructive, alertStyle: .actionSheet, onConfirm: {
            self.deleteCommentOnPost(comment: comment)
        }, onCancel: {
//            print("Cancelled")
        })
    }
    
    private func showReportOption(comment: Comment) {
        self.parent?.showConfirmationAlert(title: "Are you sure?", description: "You want to report this comment", buttonTitle: "Report", style: .destructive, alertStyle: .actionSheet, onConfirm: {
            self.moveToReportContentScreen(reportContentObject: self.getReportContentObjectWithData(comment: comment))
        }, onCancel: {
//            print("Cancelled")
        })
    }
    
    private func deleteCommentOnPost(comment: Comment) {
        APIManager.social.deleteComment(postId: post.postID, comment: comment) { error in
            if let error = error {
                self.parent?.showErrorWith(message: error.message)
            } else {
                self.removeCommentFromPost(comment: comment)
            }
        }
    }
    
    private func removeCommentFromPost(comment: Comment) {
        if comment.commentType == .parent {
            if let index = self.post.comments?.firstIndex(where: {$0.commentID == comment.commentID}) {
                self.post.comments?.remove(at: index)
            }
        } else if let parentId = comment.parentCommentId {
            if let parentComment = self.post.comments?.filter({$0.commentID == parentId}).first {
                if let index = parentComment.childComments.firstIndex(where: {$0.commentID == comment.commentID}) {
                    parentComment.childComments.remove(at: index)
                }
            }
        }
        self.sortPostComments()
        self.tableView.reloadData()
    }
}

extension ShowCommentsAdapter {
    
    func moveToReportContentScreen(reportContentObject: ReportContent) {
        let navC = self.parent?.tabBarController?.navigationController ?? self.parent?.navigationController
        // let group = Group(groupID: groupID)
        let controller = ReportViewController(nibName: "ReportViewController", bundle: nil)
        controller.reportObject = reportContentObject
        navC?.pushViewController(controller, animated: true)
    }
    
    func getReportContentObjectWithData(comment: Comment) -> ReportContent {
        var reportContentObject = ReportContent()
        reportContentObject.contentID = comment.commentID
        reportContentObject.contentType = comment.commentType.rawValue
        reportContentObject.userName = comment.owner?.name?.completeName
        reportContentObject.userID = comment.userID
        return reportContentObject
    }
    
    func favorite(postId: String) {
        APIManager.social.addToFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                self?.post.isFavourite = true
                self?.tableView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(postId: String) {
        APIManager.social.removeFromFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                self?.post.isFavourite = false
                self?.tableView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
            
        }
    }
}
