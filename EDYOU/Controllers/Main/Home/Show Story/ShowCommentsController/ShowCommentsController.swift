//
//  ShowCommentsController.swift
//  EDYOU
//
//  Created by imac3 on 28/08/2023.
//



import UIKit
import DPTagTextView
import ActiveLabel
import PanModal


class ShowCommentsController: BaseController {

    @IBOutlet weak var appIconImgV: UIImageView!
    @IBOutlet weak var imgProfileHeader: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var btnGroupName: UIButton!
    @IBOutlet weak var imgArrowGroup: UIImageView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cstViewCommentBottom: NSLayoutConstraint!
    @IBOutlet weak var txtComment: DPTagTextView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var viewImageAttachment: UIView!
    @IBOutlet weak var lblImageName: UILabel!
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var tableViewTagUsers: UITableView!
    @IBOutlet weak var viewSeparatorTableViewTagUsers: UIView!
    @IBOutlet weak var cstTableViewTagUsersHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var cstTxtCommentHeight: NSLayoutConstraint!
    @IBOutlet weak var commentBGV: UIView!
    @IBOutlet weak var userProfileBGV: UIView!
    @IBOutlet weak var topSepratorV: UIView!
    @IBOutlet weak var postNotAvailableBGV: UIView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var ImageProfileHeaderGroup: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var tablviewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var imgProfileCmntPrV: UIImageView!
    @IBOutlet weak var lblNameCmntPrV: UILabel!
    @IBOutlet weak var lblCommentCmntPrV: ActiveLabel!
    @IBOutlet weak var lblTimeCmntPrV: UILabel!
    @IBOutlet weak var lblInstituteNameCmntPrV: UILabel!
    
    var post: Post
    var prefilledComment: String?
    var commentImage: UIImage?
    var tagUserAdapter: NewPostTagUsersAdapter!
    var parentCommentId: String?
    
    var adapter: ShowCommentsAdapter!
    var comments: [Comment] = []
    private var commentId : String?
    
    var closeCallback : (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let y = self.post.user?.education.first?.degreeEnd?.toDate?.stringValue(format: "yy", timeZone: .current) {
            lblInstituteName.text = "\(self.post.user?.education.first?.instituteName ?? "N/A"), \(y)"
        }
      
        if self.post.groupInfo != nil
        {
//            lblName.text = self.post.groupInfo?.groupName
//            lblInstituteName.text = self.post.user?.name?.completeName ?? "N/A"
//            imgProfileHeader.image = UIImage(named: "group_placeholder")
//            imgProfileHeader.setImage(url: self.post.groupInfo?.groupIcon, placeholder:UIImage(named: "group_placeholder"))
            ImageProfileHeaderGroup.isHidden = false
            ImageProfileHeaderGroup.setImage(url: self.post.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
            
        }
        else
        {
//            imgProfileHeader.setImage(url: self.post.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
//            lblName.text = self.post.user?.college ?? "N/A"
//            lblInstituteName.text = self.post.user?.instituteName ?? "N/A"
        }

//        imgArrowGroup.isHidden = true
//        lblGroupName.isHidden = true
//        btnGroupName.isHidden = true
        
//        let date = self.post.createdAt?.toDate
//        lblDate.text = date?.timeAgoDisplay()
//        self.setUserInformation()
        
        imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
        
        adapter = ShowCommentsAdapter(tableView: tableView, post: post)
        getPostDetails()
        
        tagUserAdapter = NewPostTagUsersAdapter(tableView: tableViewTagUsers, didSelectUser: { [weak self] user in
            guard let self = self else { return }
            let name = user.name?.completeName.replacingOccurrences(of: " ", with: "_") ?? ""
            self.txtComment.addTag(tagText: "@\(name)", id: user.userID!)
            self.tableViewTagUsers.isHidden = true
            self.viewSeparatorTableViewTagUsers.isHidden = self.tableViewTagUsers.isHidden
            
        })
        
        setupUI()
        getFriends()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        closeCallback?()
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstViewCommentBottom.constant = 120 + (frame.height - Application.shared.safeAreaInsets.bottom )
            
//            tablviewBottomHeight.constant = Application.shared.safeAreaInsets.bottom - frame.height
        } else {
            cstViewCommentBottom.constant = 100
            previewCell.isHidden = true
//            tablviewBottomHeight.constant = 0
        }
        view.layoutIfNeeded(true)
        
    }
    init(post: Post, prefilledComment: String?, commentId : String? = nil) {
        self.post = post
        self.prefilledComment = prefilledComment
        self.commentId = commentId
        super.init(nibName: ShowCommentsController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        post = Post(userID: "", postID: "")
        super.init(coder: coder)
    }
    
    
}


// MARK: - Actions
extension ShowCommentsController {
    
    @IBAction func didTapCloseButton(_ sender: Any) {
       dismiss(animated: true)
    }
    
    @IBAction func didTapProfileButton(_ sender: Any) {
        guard let user = post.user else { return }
        let navC = self.navigationController
        let controller = ProfileController(user: user)
        navC?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapGroupButton(_ sender: Any) {
        guard let groupID = post.groupInfo?.groupID else { return }
        
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        let group = Group(groupID: groupID)
        let controller = GroupDetailsController(group: group)
        navC?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        ImagePicker.shared.openGalleryWithType(from: self, mediaType: Constants.imageMediaType) { data in
            self.commentImage = data.image
            self.lblImageName.text = "\(Date().currentTimeMillis())\(data.fileName.asStringOrEmpty())"
            self.viewImageAttachment.isHidden = false
        }
    }
    
    @IBAction func didTapSendButton(_ sender: Any) {
        let t = (txtComment.text ?? "").trimmed
        if (t.count > 0) {
            view.endEditing(true)
            addComment()
        }
    }
    
    @IBAction func didTapMoreButton(_ sender: Any) {
        view.endEditing(true)
      
        let favoriteTitle = post.isFavourite! ? "Remove From Favorite":"Add to Favorite"

        var sheetActions: [String]?
        if post.user?.isMe == true {
            sheetActions =  [favoriteTitle,"Delete"]
            showActionSheet(post: post,   sheetOptions: sheetActions!)

        } else {
           sheetActions =  [favoriteTitle,"Hide this Post", "Report"]
                showActionSheet(post: post,  sheetOptions: sheetActions!)
        }
        
    }
    
    func showActionSheet(post: Post, sheetOptions:[String]) {
        var reportContentObject = ReportContent()
        reportContentObject.contentID = post.postID
        reportContentObject.contentType = post.postType
        reportContentObject.userName = post.user?.name?.completeName
        reportContentObject.userID = post.userID
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            // self.genderTextfield.text = selected
            self.sheetButtonActions(selectedOption: selected, reportContentObject: reportContentObject)
        })
        
        self.parent!.presentPanModal(genericPicker)
    }
    
    func sheetButtonActions(selectedOption: String, reportContentObject: ReportContent ) {
        switch selectedOption {
        case "Add to Favorite", "Remove From Favorite":
            self.manageFavorites( postId: reportContentObject.contentID!)
        case "UnFollow":
            saveSettings(contentID: reportContentObject.contentID!, contentKey: "unfollow_posts")
        case "Hide this Post":
            manageHidePost(post: post)
        case "Report":
            moveToReportContentScreen(reportContentObject: reportContentObject)
        case "Delete":
            
            deletePost(post: post)
        default:
            break
            //favorite(postId: reportContentObject.contentID!)

        }
    }
    
    
    
    func moveToReportContentScreen(reportContentObject: ReportContent) {
        let navC = self.navigationController ?? self.parent?.navigationController
        // let group = Group(groupID: groupID)
        let controller = ReportViewController(nibName: "ReportViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: controller)
        controller.reportObject = reportContentObject
        navC?.present(navController, presentationStyle: .fullScreen)
    }
    
    func manageFavorites( postId: String) {
        let isFavorite = post.isFavourite ?? false
        if isFavorite {
            self.adapter.unfavorite(postId: postId)
        } else {
            self.adapter.favorite(postId: postId)
        }
    }
    
    func saveSettings(contentID: String, contentKey: String) {
        APIManager.reportContentManager.profileSaveSettings(contentID: contentID, contentKey: contentKey) { error in
            if let err = error {
                self.showErrorWith(message: err.message)
            } else {
            }
        }
    }
    
    func deletePost(post: Post) {
        APIManager.social.deletePost(id: post.postID) { (error) in
            if error != nil {
                self.navigationController?.popViewController(animated: true)
                
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
        
    }
    
    func manageHidePost(post: Post) {
        var saved = AppDefaults.shared.savedHidePosts
        if let index = saved.firstIndex(of: post.postID), index >= 0 {
            saved.remove(at: index)
            self.post.isHidePost = false
        } else {
            saved.append(post.postID )
            self.post.isHidePost = true
        }
        AppDefaults.shared.savedHidePosts = saved
        self.navigationController?.popViewController(animated: true)
    }
    
    func previewReplyCell(_ comment : Comment){
        imgProfileCmntPrV.setImage(url: comment.owner?.profileImage, placeholder: R.image.profile_image_dummy())
//        lblNameCmntPrV.text = comment.owner?.name?.completeName
//        lblCommentCmntPrV.text = comment.formattedText
        lblTimeCmntPrV.text = comment.createdAt?.toDate?.timeAgoDisplay()
        lblInstituteNameCmntPrV.text = comment.owner?.instituteName
        previewCell.isHidden = false
    }
}


// MARK: - Utlity Methods
extension ShowCommentsController {
    func setupUI() {
        txtComment.text = prefilledComment
        let h = " ".height(withWidth: txtComment.width, font: txtComment.font ?? UIFont.systemFont(ofSize: 14))
        txtComment.textContainerInset = UIEdgeInsets(top: (txtComment.height - h) / 2, left: 0, bottom: 0, right: 0)
        txtComment.textContainer.lineFragmentPadding = 0
        
        txtComment.dpTagDelegate = self // set DPTagTextViewDelegate Delegate
        txtComment.setTagDetection(false) // true :- detecte tag on tap , false :- Search Tags using mentionSymbol & hashTagSymbol.
        txtComment.mentionSymbol = "@" // Search start with this mentionSymbol.
        txtComment.hashTagSymbol = "#" // Search start with this hashTagSymbol for hashtagging.
        txtComment.allowsHashTagUsingSpace = true // Add HashTag using space
        setTextViewFont(size: 14, color: .black, placeholderColor: R.color.sub_title() ?? .lightGray)
    }
    
    func setUserInformation() {
        
        var instituteName = self.post.user?.getCurrentEducation()?.instituteName ?? "N/A"
        
        
        self.lblInstituteName.text = instituteName
        
        if let group = self.post.groupInfo {
//            lblName.text = group.groupName
            lblInstituteName.text = self.post.user?.college ?? ""
//            imgProfileHeader.image = R.image.profileImagePlaceHolder()
//            imgProfileHeader.setImage(url: self.post.groupInfo?.groupIcon,placeholder: R.image.event_placeholder_square())
            ImageProfileHeaderGroup.isHidden = false
            ImageProfileHeaderGroup.setImage(url: self.post.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        } else {
//            imgProfileHeader.setImage(url: self.post.user?.profileImage, placeholder: R.image.profileImagePlaceHolder())
//            lblName.text = self.post.user?.name?.completeName ?? ""
            lblInstituteName.text = self.post.user?.college ?? ""
        }
        if let str = post.user?.major_end_year?.toDate?.stringValue(format: "yyyy"){
            lblInstituteName.text = "\(lblInstituteName.text ?? ""), \(str)"
        }
    }
    
    func setTextViewFont(size: CGFloat, color: UIColor, placeholderColor: UIColor) {
        
        txtComment.textViewAttributes = [NSAttributedString.Key.foregroundColor: color,
                                      NSAttributedString.Key.font:  UIFont.systemFont(ofSize: size )]
        
        txtComment.mentionTagTextAttributes = [NSAttributedString.Key.foregroundColor: R.color.accentColor() ?? .blue,
                                            NSAttributedString.Key.backgroundColor: UIColor.clear,
                                            NSAttributedString.Key.font:  UIFont.systemFont(ofSize: size )]
        
        
        txtComment.hashTagTextAttributes = [NSAttributedString.Key.foregroundColor: R.color.buttons_green() ?? .green,
                                         NSAttributedString.Key.backgroundColor: UIColor.clear,
                                         NSAttributedString.Key.font:  UIFont.systemFont(ofSize: size )]
        
        txtComment.textViewDidChange(txtComment)
        
        lblPlaceholder.textColor = placeholderColor
        lblPlaceholder.font = UIFont.systemFont(ofSize: size )
        
    }
}

// MARK: - TextView Delegate
extension ShowCommentsController: DPTagTextViewDelegate {
    func textViewDidBeginEditing(_ textView: DPTagTextView) {
        tableView.scrollToBottom()
    }
    func dpTagTextView(_ textView: DPTagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {
        
        if !isHashTag {
            tagUserAdapter.search(text: strSearch)
            cstTableViewTagUsersHeight?.constant = CGFloat(tagUserAdapter.filteredUsers.count) * 50
            
            if (strSearch.count == 0) {
                tableViewTagUsers.isHidden = true
            } else {
                tableViewTagUsers.isHidden = tagUserAdapter.filteredUsers.count == 0
                
            }
            view.layoutIfNeeded(true) {
                self.tableViewTagUsers.reloadData()
            }
            
        } else {
            tableViewTagUsers.isHidden = true
        }
        viewSeparatorTableViewTagUsers.isHidden = tableViewTagUsers.isHidden
    }
    
    func textViewDidChange(_ textView: DPTagTextView) {
        lblPlaceholder.isHidden = (textView.text ?? "").count > 0
        let text = textView.text ?? ""
        let h = text.height(withWidth: textView.width, font: textView.font ?? UIFont.systemFont(ofSize: 14))
        cstTxtCommentHeight.constant = h
        view.layoutIfNeeded(true)
        
        if textView.text.last == " " || textView.text.last == "@" {
            tableViewTagUsers.isHidden = true
        }
        viewSeparatorTableViewTagUsers.isHidden = tableViewTagUsers.isHidden
    }
    func dpTagTextView(_ textView: DPTagTextView, didRemoveTag tag: DPTag) {
        print("[dpTagTextView didRemoveTag]")
    }
}


// MARK: - Web APIs
extension ShowCommentsController {
    func getFriends() {
        APIManager.social.getFriendsOnly { [weak self] friends, error in
            guard let self = self else { return }
            
            if error == nil {
                self.tagUserAdapter.users = friends
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getPostDetails(isScrollToEnd: Bool = false) {
        //self.startLoading(title: "")
        
        self.adapter.isLoading = true
        APIManager.social.getPostDetails(postId: post.postID,commentId: commentId ?? "") { post, error in
            self.adapter.isLoading = false
            if let p = post, error == nil {
                self.post = p
                self.adapter.post = p
                
                if (self.adapter.post.comments?.count ?? 0) > 0 {
                    self.tableView.isHidden = false
                    self.postNotAvailableBGV.isHidden = true
                    
                }
                else{
                    self.tableView.isHidden = true
                    self.postNotAvailableBGV.isHidden = false
                }
            } else {
               // self.showErrorWith(message: error?.message ?? "Unexpected error")
                
                self.hideViewsIfItemNotFound()
                return
            }
            self.tableView.reloadData()
//            self.setUserInformation()
            if isScrollToEnd {
                self.tableView.scrollToBottom(isAnimated: true)
            }
            else if let commentId = self.commentId{
                if let post = post{
                    if let index = post.comments?.firstIndex(where: { comment in
                        comment.commentID == commentId
                    }){
                        //get index of comment
                         let commentIndexToScroll = IndexPath(row: index, section: 1)
                        self.tableView.scrollToRow(at: commentIndexToScroll, at: .top, animated: true)
                        
                    }
                    else{
                        
                        for (index,comment) in post.comments!.enumerated(){
                            if let indexInner = comment.childComments.firstIndex(where: { comment in
                                comment.commentID == commentId
                            }){
                                //get index of comment
                                let commentIndexToScroll = IndexPath(row: index, section: 1)
                                self.tableView.scrollToRow(at: commentIndexToScroll, at: .top, animated: true)
                                
                            }
                            
                        }
    //                    post?.comments?.forEach({ comment in
    //                        comment.commentID == commentId
    //                    })
                    }

                }
                
            }
        }

        
          
    }
    private func hideViewsIfItemNotFound(){
        self.tableView.isHidden = true
        
        self.commentBGV.isHidden = true
        self.userProfileBGV.isHidden = true
        self.btnMore.isHidden = true
        self.imgMore.isHidden = true
        self.topSepratorV.isHidden = true
        self.postNotAvailableBGV.isHidden = false
        self.appIconImgV.isHidden = false
    }
    func addComment() {
        
        btnSend.isUserInteractionEnabled = false
        var postText = txtComment.text ?? ""
        var taggedFriends = [String]()
        
        for tag in txtComment.arrTags {
            if !tag.isHashTag {
                postText = postText.replacingOccurrences(of: tag.name, with: "id{\(tag.id)}")
                taggedFriends.append(tag.id)
            }
        }
        
        var parameters: [String: Any] = [
            "message": postText,
            
        ]
        if !taggedFriends.isEmpty {
            parameters["tag_friends"] = taggedFriends
        }
        
        var media = [Media]()
        if let img = commentImage, let m = Media(withImage: img, key: "images") {
            media.append(m)
        }
        
        progressBar.isHidden = media.count == 0
        let type : CommentType = self.parentCommentId == nil ? .parent : .child
        APIManager.social.addComment(postId: post.postID, commentId: self.parentCommentId, type: type, parameters: parameters, media: media) { [weak self] progress in
            self?.progressBar.progress = progress
        } completion: { [weak self] data, error in
            guard let self = self else { return }
            self.btnSend.isUserInteractionEnabled = true
            
            if error == nil {
                self.txtComment.clearText()
                self.parentCommentId = nil
                self.viewImageAttachment.isHidden = true
                self.progressBar.isHidden = true
                self.textViewDidChange(self.txtComment)
                
                self.getPostDetails(isScrollToEnd: true)
                
            } else {
                self.progressBar.isHidden = true
                self.showErrorWith(message: error?.message ?? "Unexpected error")
            }
        }
    }
    
}

extension ShowCommentsController: PanModalPresentable {

    var panScrollable: UIScrollView? {
        return tableView
    }

    var showDragIndicator: Bool {
        return false
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var shortFormHeight: PanModalHeight {
        let height = (self.view.frame.height - Application.shared.safeAreaInsets.top - Application.shared.safeAreaInsets.bottom) * 0.90
        return .contentHeight(height)
    }

    var longFormHeight: PanModalHeight {
        let height = (self.view.frame.height - Application.shared.safeAreaInsets.top - Application.shared.safeAreaInsets.bottom) * 0.90
        return .contentHeight(height)
    }
}
