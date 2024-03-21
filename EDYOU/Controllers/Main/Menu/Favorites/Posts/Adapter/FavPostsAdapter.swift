//
//  
//  FavFriendsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//
//

import UIKit
import EmptyDataSet_Swift

class FavPostsAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: FavPostsController? {
        return tableView.viewContainingController() as? FavPostsController
    }
    var isLoading = true
    var searchedPosts = [Post]()
    var posts = [Post]()
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
        
    }
    func configure() {
        tableView.register(ImagePostCell.nib, forCellReuseIdentifier: ImagePostCell.identifier)
        tableView.register(TextWithBgPostCell.nib, forCellReuseIdentifier: TextWithBgPostCell.identifier)
        tableView.register(TextPostCell.nib, forCellReuseIdentifier: TextPostCell.identifier)
        tableView.register(StoriesCell.nib, forCellReuseIdentifier: StoriesCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
    }
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = posts.filter { $0.postName?.lowercased().contains(t) == true || $0.user?.name?.completeName.lowercased().contains(t) == true }
            self.searchedPosts = f
        } else {
            self.searchedPosts = posts
        }
        tableView.reloadData()
        
    }
}





// MARK: - Actions
extension FavPostsAdapter {
    @objc func didTapAddStoryButton() {
        let controller = AddStoryController()
        controller.modalPresentationStyle = .fullScreen
        self.parent?.present(controller, animated: true, completion: nil)
    }
    @objc func didTapLikeButton(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as? PostCell
        
        if let post = searchedPosts.object(at: sender.tag) {
            
            if let r = post.myReaction {
                self.searchedPosts[sender.tag].removeReaction(r.likeEmotion ?? "")
                cell?.addReaction(self.searchedPosts[sender.tag].myReaction, totalReactions: self.searchedPosts[sender.tag].totalLikes ?? 0)
                
                APIManager.social.addReaction(postId: post.postID, isAdd: false, reaction: r.likeEmotion ?? "") { [weak self] (error) in
                    guard let self = self else { return }
                    if error != nil {
                        self.parent?.showErrorWith(message: error!.message)
                        
                        self.searchedPosts[sender.tag].addReaction(r.likeEmotion ?? "")
                        cell?.addReaction(self.searchedPosts[sender.tag].myReaction, totalReactions: self.searchedPosts[sender.tag].totalLikes ?? 0)
                    }
                }
            } else {
                
                let controller = EmojisController { (selectedEmoji) in
                    
                    self.searchedPosts[sender.tag].addReaction(selectedEmoji.encodeEmoji())
                    cell?.addReaction(self.searchedPosts[sender.tag].myReaction, totalReactions: self.searchedPosts[sender.tag].totalLikes ?? 0)
                    
                    
                    APIManager.social.addReaction(postId: post.postID, isAdd: true, reaction: selectedEmoji.encodeEmoji()) { [weak self] (error) in
                        guard let self = self else { return }
                        if error != nil {
                            self.parent?.showErrorWith(message: error!.message)
                            self.searchedPosts[sender.tag].removeReaction(selectedEmoji.encodeEmoji())
                            cell?.addReaction(self.searchedPosts[sender.tag].myReaction, totalReactions: self.searchedPosts[sender.tag].totalLikes ?? 0)
                        }
                    }
                }
                self.parent?.present(controller, animated: true, completion: nil)
                
            }
        }
        
    }
    @objc func didTapProfileButton(_ sender: UIButton) {
        guard let user = searchedPosts.object(at: sender.tag)?.user else { return }
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let post = posts.object(at: sender.tag) else { return }
        let indexPath = IndexPath(row: sender.tag, section: 0) // assuming cell is for first or only section of table view

//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
//        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
//            
//        }))
//        alert.addAction(UIAlertAction(title: "Remove from Favourite", style: .default, handler: { _ in
//            self.unfavorite(postId: post.postID)
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        parent?.present(alert, animated: true, completion: nil)
        var sheetActions: [String]?
        let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"
       sheetActions =  [favoriteTitle, "Report"]
            showActionSheet(post: post, indexPath: indexPath, sheetOptions: sheetActions!)

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


// MARK: - TableView DataSource & Delegate
extension FavPostsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        if searchedPosts.count == 0 {
            tableView.addEmptyView("No Post(s)", "You have no favourite post", EmptyCellConfirguration.group.image)
        }
        
        if isLoading {
            return 10
        }
        return searchedPosts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isLoading ? 260 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.identifier, for: indexPath) as! TextPostCell
            cell.beginSkeltonAnimation()
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
//                cell.setCVDimenstion(height, width)
//                cell.collectionVW.constant = width
            cell.collectionVH.constant = height
            cell.setData(post)
            cell.btnLike.tag = indexPath.row
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
            cell.btnLike.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
            cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
            cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
            return cell
        } else if post?.isBackground == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextWithBgPostCell.identifier, for: indexPath) as! TextWithBgPostCell
            cell.setData(post)
            cell.btnLike.tag = indexPath.row
            cell.btnMore.tag = indexPath.row
            cell.btnProfile.tag = indexPath.row
            cell.btnGroupName.tag = indexPath.row
            cell.btnLike.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
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
        cell.btnLike.tag = indexPath.row
        cell.btnMore.tag = indexPath.row
        cell.btnProfile.tag = indexPath.row
        cell.btnGroupName.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        cell.btnProfile.addTarget(self, action: #selector(didTapProfileButton(_:)), for: .touchUpInside)
        cell.btnGroupName.addTarget(self, action: #selector(didTapGroupButton(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = posts.object(at: indexPath.row) {
            let controller = PostDetailsController(post: post, prefilledComment: nil)
            parent?.tabBarController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == tableView {
//            let offsetYBottom = tableView.contentOffset.y + tableView.frame.height
//            if offsetYBottom >= (tableView.contentSize.height - 260) && posts.count < totalRecord {
//                parent?.loadDataOnScrollEnd()
//            }
//        }
//    }
}





//extension FavPostsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "No Post(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
//    }
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "You have no favourite post", attributes: [NSAttributedString.Key.font :  UIFont.systemFont(ofSize: 16)])
//    }
//}


// MARK: - APIs
extension FavPostsAdapter {
    func favorite(postId: String) {
        APIManager.social.addToFavorite(type: .posts, id: postId) { [weak self] error in
            if error == nil {
                
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
    func unfavorite(postId: String) {
        tableView.isUserInteractionEnabled = false
        APIManager.social.removeFromFavorite(type: .posts, id: postId) { [weak self] error in
            self?.tableView.isUserInteractionEnabled = true
            if error == nil {
                let searchedIndex = self?.searchedPosts.firstIndex(where: { $0.postID == postId })
                if let i = searchedIndex {
                    self?.searchedPosts.remove(at: i)
                    let indexPath = IndexPath(row: i, section: 0)
                    self?.tableView.beginUpdates()
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.tableView.endUpdates()
                }
                let index = self?.posts.firstIndex(where: { $0.postID == postId })
                if let i = index {
                    self?.posts.remove(at: i)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.tableView.reloadData()
                }
                
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
        }
    }
}
