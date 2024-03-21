//
//  ProfileHeaderInfo.swift
//  EDYOU
//
//  Created by Admin on 27/05/2022.
//

import UIKit
import SDWebImage
import RealmSwift

protocol ProfileHeaderActions :  AnyObject{
    func detailSegmentChanged(type: ProfileDetailType)
    func editProfile()
    func showEditProfilePicture()
    func addFriendAction(action: AddFriendAction, sender: UIButton)
    func callUser()
    func sendMessageToUser()
    func sendInvite()
}
class ProfileHeaderInfo: UITableViewCell {
    
    @IBOutlet weak var stackLinks: UIStackView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileVerifiedLogo: UIImageView!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var btnAddPhoto: UIButton!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var lblProfileNameDescription: UILabel!
    @IBOutlet weak var hireMeView: UIView!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnSendMessage: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var lblPostCount: UILabel!
    @IBOutlet var tabImages: [UIImageView]!
    @IBOutlet weak var tabsStack: UIStackView!
    @IBOutlet weak var cstViewIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var btnCustomLink: UIButton!
    @IBOutlet weak var btnDrabbleLink: UIButton!
    @IBOutlet weak var btnTweeterLink: UIButton!
    @IBOutlet weak var btnLinkedInLink: UIButton!
    @IBOutlet weak var btnFacebookLink: UIButton!
    @IBOutlet weak var btnInstaLink: UIButton!
    @IBOutlet weak var lblFollowerCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblGroupCount: UILabel!
    @IBOutlet weak var lblWorkTiittle: UILabel!
    @IBOutlet weak var workView: UIView!
    @IBOutlet weak var constLinksHeight: NSLayoutConstraint!
    @IBOutlet weak var btnInvite: UIButton!
    
    var type: ProfileDetailType = .post
    weak var delegate : ProfileHeaderActions?
    var user: User!
    var currentIndex = 0
    var action: AddFriendAction?
    
    let animationDuration: TimeInterval = 0.25
    let switchingInterval: TimeInterval = 3
    var transition = CATransition()
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(actSwipeGesture(_:)))
        swipeGestureRecognizerLeft.direction = .left
        self.coverPhoto.addGestureRecognizer(swipeGestureRecognizerLeft)
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(actSwipeGesture(_:)))
        swipeGestureRecognizerRight.direction = .right
        self.coverPhoto.addGestureRecognizer(swipeGestureRecognizerRight)
        self.coverPhoto.isUserInteractionEnabled = true
        self.pageControl.backgroundStyle = .prominent
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.layoutIfNeeded()
            self.manageUI(tag: 0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setData(user:User, status: FriendShipStatusModel, delegate : ProfileHeaderActions) {
        workView.isHidden = true
        self.delegate = delegate
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        if let coverPhotoUrl = user.coverPhotosArray.first?.coverPhotoURL {
            coverPhoto.setImage(url: coverPhotoUrl, placeholder: R.image.ic_cover_photo_placeholder()!)
            coverPhoto.contentMode = .scaleAspectFill
        } else {
            coverPhoto.contentMode = .center
        }
        if let img = R.image.dm_profile_holder(){
            profilePhoto.setImage(url: user.profileImage, placeholder: img)
        }
       
        lblProfileName.text = user.formattedUserName.capitalized
        lblProfileNameDescription.text = user.college
        
        if let str = user.major_end_year?.toDate?.stringValue(format: "yyyy"){
            if let startYear = user.major_start_year?.toDate?.stringValue(format: "yyyy"){
                lblProfileNameDescription.text = "\(user.college  ?? "N/A") \(startYear)-\(str)"
            }else{
                lblProfileNameDescription.text = "\(user.college  ?? "N/A") \(str)"
            }
            
        }
        lblPostCount.text = "\(user.posts)"
        lblGroupCount.text = "\( user.groups )"
        lblFollowerCount.text = "\( user.followers)"
        lblFollowingCount.text = "\(user.friends)"
        let action = AddFriendAction.from(status: status)
        self.action = action
        btnFollow.isHidden = true
        print(action.title)
        btnFollow.setTitle(action.title, for: .normal)
        btnFollow.addTarget(self, action: #selector(self.handleFriendshipActions(sender:)), for: .touchUpInside)
        let ishireMe = user.hireMe
        ishireMe ? (hireMeView.isHidden = false) : (hireMeView.isHidden = true)
        self.user = user
        
        if user.isMe == true {
            btnCall.isHidden = true
            btnSendMessage.isHidden = true
            btnFollow.isHidden = true
            addBtnView.isHidden = false
            btnInvite.isHidden = false
            
        } else {
            addBtnView.isHidden = true
            btnCall.isHidden = false
            btnSendMessage.isHidden = false
            btnInvite.isHidden = true
        }
        
        profileVerifiedLogo.isHidden = !user.isUserVerified
        
        switch action {
        case .none:
            if user.userID != Cache.shared.user?.userID {
                btnCall.isHidden = !user.isCallAllowed
                btnSendMessage.isHidden = !user.isMessageAllowed
            }
            break
        case .unfriend:
            btnCall.isHidden = !user.isCallAllowed
            btnSendMessage.isHidden = !user.isMessageAllowed
            btnFollow.isHidden = true
            break
        case .addFriend:
            btnCall.isHidden = true
            btnSendMessage.isHidden = true
            btnFollow.isHidden = false
            break
        case .cancelRequest:
            btnCall.isHidden = true
            btnSendMessage.isHidden = true
            btnFollow.isHidden = false
            break
        case .acceptRequest:
            btnCall.isHidden = true
            btnSendMessage.isHidden = true
            btnFollow.isHidden = false
            break
        }
        self.lblProfileName.text = user.name?.completeName.capitalized
        self.setCoverImage()
        self.handleSocialLinks()
        
        guard  let degreeCompletionDate = user.education.first?.completeDate else {
            return
        }
        guard  let instituteName = user.education.first?.instituteName else {
            return
        }
        self.lblProfileNameDescription.text = "\(instituteName) \(degreeCompletionDate)"

    }
    
    @IBAction func actCallUser(_ sender: UIButton) {
        self.delegate?.callUser()
    }
    @IBAction func actInviteUser(_ sender: UIButton) {
        self.delegate?.sendInvite()
    }
    @IBAction func actSendMessage(_ sender: UIButton) {
        self.delegate?.sendMessageToUser()
    }
    @IBAction func DidTapSegmentButtons(_ sender: UIButton) {
        type = ProfileDetailType(rawValue: sender.tag) ?? .post
        self.manageUI(tag: sender.tag)
        self.delegate?.detailSegmentChanged(type: type)
    }
    
    private func manageUI(tag: Int) {
        
        tabImages.forEach { image in
            let postType = ProfileDetailType(rawValue: image.tag)
            image.image = postType?.unselectedImage
        }
        let imageView = tabImages.first { $0.tag == tag }
        imageView?.image = self.type.selectedImage
        tabsStack.arrangedSubviews.forEach { view in
            if view.tag == tag {
                cstViewIndicatorLeading.constant = 16 + view.frame.origin.x
                cstViewIndicatorWidth.constant = view.bounds.size.width
                self.indicatorView.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func didTapMore(_ sender: UIButton) {
        delegate?.editProfile()
    }
    
    @IBAction func didTapProfilePhoto(_ sender: Any) {
        if self.user.isMe {
            delegate?.showEditProfilePicture()
        }
    }
    
    @objc func actSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        let coverPhotos = user.coverPhotosArray 
        
        if sender.direction == .left {
            currentIndex += 1
        } else {
            currentIndex -= 1
        }
        if currentIndex >= coverPhotos.count {
            currentIndex = 0
        }
        else if currentIndex <= 0 {
            currentIndex = coverPhotos.count - 1
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.setCoverImage()
        CATransaction.commit()
    }
    
    private func setCoverImage() {
        self.pageControl.isHidden = !(self.user.coverPhotosArray.count > 1)
        let imagesCount = user.coverPhotosArray.count
        if imagesCount == 0 || self.currentIndex >= imagesCount { return }
        self.pageControl.numberOfPages = user.coverPhotosArray.count
        self.pageControl.currentPage = currentIndex
        guard let imageUrl = user.coverPhotosArray[currentIndex].coverPhotoURL else { return }
        coverPhoto.sd_imageIndicator = SDWebImageActivityIndicator.gray
        coverPhoto.setImage(url: imageUrl, placeholderColor: R.color.image_placeholder()) {
            self.coverPhoto.sd_imageIndicator = nil
        }
       
//
    }
}
extension ProfileHeaderInfo {
    func handleSocialLinks() {
        
        stackLinks.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let socialLinks = self.user.socialLinks.toArray(type: SocialLink.self)
        var sortedTags : [SocialLinkNetwork] = []
        self.stackLinks.isHidden = socialLinks.count == 0
        self.constLinksHeight.constant = socialLinks.count == 0 ? 0 : 30
        for links in socialLinks {
            guard let socialEnum = SocialLinkNetwork(rawValue: links.socialNetworkName ?? "") else { continue }
            sortedTags.append(socialEnum)
        }
        sortedTags.sort(by: {$0.tags < $1.tags})
        
        sortedTags.forEach { element in
            let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
            button.setImage(element.icon, for: .normal)
            button.tag = element.tags
            stackLinks.addArrangedSubview(button)
            button.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func openLink(sender: UIButton) {
        guard let link = SocialLinkNetwork(tag: sender.tag) else { return }
        var value = ""
        self.user.socialLinks.forEach({ socialValue  in
            if socialValue.socialNetworkName == link.rawValue {
                value = socialValue.socialNetworkURL!
            }
        })
        if !(value.contains("http") || value.contains("https")) {
            value = "https://" + value
        }
        Utilities.openURL(urlString: value)
    }
    
    @objc private func handleFriendshipActions(sender: UIButton) {
        guard let action = action else { return }
        self.delegate?.addFriendAction(action: action, sender: sender)
    }
    
}



