//
//  ReelsCommentsController.swift
//  EDYOU
//
//  Created by  Mac on 17/09/2021.
//

import UIKit
import DPTagTextView
import TransitionButton

class ReelsCommentsController: BaseController {
    @IBOutlet weak var lblTitle: UILabel!
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
    @IBOutlet weak var btnSend: TransitionButton!
    @IBOutlet weak var cstTxtCommentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imgProfile: UIImageView!
    var reels: Reels
    var prefilledComment: String?
    var commentImage: UIImage?
    var tagUserAdapter: NewPostTagUsersAdapter!
    var parentCommentId: String?
    
    lazy var adapter: ReelsCommentsAdapater = ReelsCommentsAdapater(tableView: self.tableView, reels: self.reels)
    
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadReelsComments()
        imgProfile.setImage(url: Cache.shared.user?.profileImage, placeholder: R.image.profile_image_dummy())
        self.handleTagList()
        self.setupUI()
        getFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstViewCommentBottom.constant = Application.shared.safeAreaInsets.bottom - frame.height
        } else {
            cstViewCommentBottom.constant = 0
        }
        view.layoutIfNeeded(true)
        
    }
    init(reels: Reels) {
        self.reels = reels
        super.init(nibName: ReelsCommentsController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.reels = Reels()
        super.init(coder: coder)
    }
    
    @IBAction func actClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
// MARK: - Tag List Handling
extension ReelsCommentsController {
    func handleTagList() {
        tagUserAdapter = NewPostTagUsersAdapter(tableView: tableViewTagUsers, didSelectUser: { [weak self] user in
            guard let self = self else { return }
            let name = user.name?.completeName.replacingOccurrences(of: " ", with: "_") ?? ""
            self.txtComment.addTag(tagText: "@\(name)", id: user.userID!)
            self.tableViewTagUsers.isHidden = true
            self.viewSeparatorTableViewTagUsers.isHidden = self.tableViewTagUsers.isHidden
        })
    }
}

// MARK: - Actions
extension ReelsCommentsController {
    
    @IBAction func didTapSendButton(_ sender: Any) {
        let t = (txtComment.text ?? "").trimmed
        if (t.count > 0) {
            view.endEditing(true)
            addComment()
        }
    }
}


// MARK: - Utlity Methods
extension ReelsCommentsController {
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
        setTextViewFont(size: 17, color: .black, placeholderColor: R.color.sub_title() ?? .lightGray)
    }
    func setTextViewFont(size: CGFloat, color: UIColor, placeholderColor: UIColor) {
        
        txtComment.textViewAttributes = [NSAttributedString.Key.foregroundColor: color,
                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: .regular)]
        
        txtComment.mentionTagTextAttributes = [NSAttributedString.Key.foregroundColor: R.color.accentColor() ?? .blue,
                                            NSAttributedString.Key.backgroundColor: UIColor.clear,
                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: .regular)]
        
        
        txtComment.hashTagTextAttributes = [NSAttributedString.Key.foregroundColor: R.color.buttons_green() ?? .green,
                                         NSAttributedString.Key.backgroundColor: UIColor.clear,
                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: size, weight: .regular)]
        
        txtComment.textViewDidChange(txtComment)
        
        lblPlaceholder.textColor = placeholderColor
        lblPlaceholder.font =  UIFont.systemFont(ofSize: size)
        
    }
}

// MARK: - TextView Delegate
extension ReelsCommentsController: DPTagTextViewDelegate {
    func textViewDidBeginEditing(_ textView: DPTagTextView) {
        tableView.scrollToBottom()
    }
    func dpTagTextView(_ textView: DPTagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {
        
        if !isHashTag {
            tagUserAdapter.search(text: strSearch)
            cstTableViewTagUsersHeight.constant = CGFloat(tagUserAdapter.filteredUsers.count) * 50
            
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
extension ReelsCommentsController {
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
    
    func addComment() {
        guard let videoId = self.reels.videoId else { return }
        btnSend.isUserInteractionEnabled = false
        var postText = txtComment.text ?? ""
        var taggedFriends = [String]()
        for tag in txtComment.arrTags {
            if !tag.isHashTag {
                postText = postText.replacingOccurrences(of: tag.name, with: "id{\(tag.id)}")
                taggedFriends.append(tag.id)
            }
        }
        self.btnSend.startAnimation()
        APIManager.social.addReelsComment(videoId: videoId, commentId: nil, type: CommentType.parent, tagFriends: taggedFriends, message: postText) { result, error in
            self.btnSend.stopAnimation()
            if let error = error {
                self.showErrorWith(message: error.message)
            } else {
                self.txtComment.clearText()
                self.loadReelsComments()
            }
        }
    }
}



// MARK: - Load Comments
extension ReelsCommentsController {
    func loadReelsComments() {
        guard let videoId = self.reels.videoId else { return }
        APIManager.social.getReelsComments(videoId: videoId) { comments, error in
            if let error = error {
                self.showErrorWith(message: error.message)
            } else {
                self.reels.comments = comments
                self.adapter.reloadTable()
            }
        }
    }
}
