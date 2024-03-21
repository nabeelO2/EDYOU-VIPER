//
//  GroupDetailCell.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit

protocol GroupDetailCellAction {
    func filterSelected(filter: GroupDataFilterType)
}

class GroupDetailCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMembers: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var imagePrivacy: UIImageView!
    @IBOutlet weak var viewSeparatorCreatePost: UIView!
    @IBOutlet weak var stkCreatePost: UIStackView!
    
    @IBOutlet weak var filterStack: UIStackView!
    @IBOutlet weak var membersImagesStackVIew: UIStackView!
    @IBOutlet weak var userOneImage: UIImageView!
    @IBOutlet weak var userTwoImage: UIImageView!
    @IBOutlet weak var userThreeImage: UIImageView!
    @IBOutlet weak var userFourImage: UIImageView!
    @IBOutlet weak var userFiveImage: UIImageView!
    @IBOutlet weak var joinedUserTotalCountView: UIView!
    @IBOutlet weak var joinedUserTotalCountLabel: UILabel!
    
    @IBOutlet weak var filterPhotosButton: UIButton!
    @IBOutlet weak var filterVideosButton: UIButton!
    @IBOutlet weak var filterTextButton: UIButton!
    
    @IBOutlet weak var AllButton: UIButton!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnCreatePost: UIButton!
    @IBOutlet weak var btnPhotos: UIButton!
    
    @IBOutlet weak var joinAndWaitingForApprovalView: UIView!
    var delegate: GroupDetailCellAction!
    
    var placeholderPicture: UIImage {
        return R.image.profile_image_dummy()!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func actApplyFilter(_ sender: UIButton) {
        let filter = GroupDataFilterType.init(rawValue: sender.tag)!
        self.setSelectedFilter(filter: filter)
        self.delegate.filterSelected(filter: filter)
    }
    
    func setData(_ group: Group, filter: GroupDataFilterType, delegate: GroupDetailCellAction) {
        self.delegate = delegate
        lblName.text = group.groupName ?? "N/A"
        lblDescription.text = group.groupDescription
        joinAndWaitingForApprovalView.isHidden = true
        membersImagesStackVIew.isHidden = true
        userOneImage.isHidden = true
        userTwoImage.isHidden = true
        userThreeImage.isHidden = true
        userFourImage.isHidden = true
        userFiveImage.isHidden = true
        joinedUserTotalCountView.isHidden = true
        
        if ((group.groupMembers?.count ?? 0) > 0) {
            membersImagesStackVIew.isHidden = false
            
            if let count = group.groupMembers?.count {
                if (count == 0) {
                    membersImagesStackVIew.isHidden = true
                } else if (count == 1) {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                } else if (count == 2) {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    userTwoImage.isHidden = false
                    userTwoImage.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                } else if (count == 3) {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    userTwoImage.isHidden = false
                    userTwoImage.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    userThreeImage.isHidden = false
                    userThreeImage.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                } else if (count == 4) {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    userTwoImage.isHidden = false
                    userTwoImage.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    userThreeImage.isHidden = false
                    userThreeImage.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                    userFourImage.isHidden = false
                    userFourImage.setImage(url: group.groupMembers?[3].profileImage, placeholder: placeholderPicture)
                } else if (count == 5) {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    userTwoImage.isHidden = false
                    userTwoImage.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    userThreeImage.isHidden = false
                    userThreeImage.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                    userFourImage.isHidden = false
                    userFourImage.setImage(url: group.groupMembers?[3].profileImage, placeholder: placeholderPicture)
                    userFiveImage.isHidden = false
                    userFiveImage.setImage(url: group.groupMembers?[4].profileImage, placeholder: placeholderPicture)
                } else {
                    userOneImage.isHidden = false
                    userOneImage.setImage(url: group.groupMembers?[0].profileImage, placeholder: placeholderPicture)
                    userTwoImage.isHidden = false
                    userTwoImage.setImage(url: group.groupMembers?[1].profileImage, placeholder: placeholderPicture)
                    userThreeImage.isHidden = false
                    userThreeImage.setImage(url: group.groupMembers?[2].profileImage, placeholder: placeholderPicture)
                    userFourImage.isHidden = false
                    userFourImage.setImage(url: group.groupMembers?[3].profileImage, placeholder: placeholderPicture)
                    userFiveImage.isHidden = false
                    userFiveImage.setImage(url: group.groupMembers?[4].profileImage, placeholder: placeholderPicture)
                    joinedUserTotalCountView.isHidden = false
                    
                    let remainingUsers = count - 5
                    joinedUserTotalCountLabel.text = "\(remainingUsers)+"
                }
            }
        }
        
        let m = group.groupMembers?.count == 1 ? "member" : "members"
        lblMembers.text = "\(group.groupMembers?.count ?? 0) \(m)"
        lblPrivacy.text = "\((group.privacy ?? "Public").capitalized) Group"
        
        if let privacy = group.privacy {
            imagePrivacy.image = privacy == "public" ? R.image.language_icon() : R.image.private_group_icon()
        }
        
        let isAdmin = group.groupAdmins?.contains(where: { $0.userID == Cache.shared.user?.userID })
        if isAdmin == true || group.groupOwner?.userID == Cache.shared.user?.userID {
            stkCreatePost.isHidden = false
            viewSeparatorCreatePost.isHidden = false
            btnInvite.isHidden = false
            btnJoin.isHidden = true
        } else {
            let isMember = group.groupMembers?.contains(where: { $0.userID == Cache.shared.user?.userID })
            if let isMember = isMember,isMember {
                joinAndWaitingForApprovalView.isHidden = false
                btnJoin.isHidden = false
            }
            btnInvite.isHidden = isMember == false
            stkCreatePost.isHidden = isMember == false
            viewSeparatorCreatePost.isHidden = isMember == false
        }
        var groupJoinedStatus = String()
        if let receivedInvitations = group.recievedInvitations {
            if receivedInvitations.contains(where: { user in
                if user.userID == Cache.shared.user?.userID {
                    groupJoinedStatus = user.groupMemberStatus ?? ""
                    return true
                } else {
                    return false
                }
            }) {
                
            }
        }
        if groupJoinedStatus == "" {
        if let sendInvitations = group.sentInvitations {
            if sendInvitations.contains(where: { user in
                if user.userID == Cache.shared.user?.userID {
                    groupJoinedStatus = user.groupMemberStatus ?? ""
                    return true
                } else {
                    return false
                }
            }) {
                
            }
        }
        }
        print(groupJoinedStatus)
        let memberStatus = GroupMemberStatus(rawValue: groupJoinedStatus ) ?? .defaultState
        switch memberStatus {
        case .waiting_for_admin_approval:
            joinAndWaitingForApprovalView.isHidden = false
            btnJoin.isHidden = true
        case .waiting_for_my_approval:
            joinAndWaitingForApprovalView.isHidden = false
            btnJoin.isHidden = false
        case .joined_via_invite:
            joinAndWaitingForApprovalView.isHidden = true
            btnJoin.isHidden = true
        case .joined_by_me:
            joinAndWaitingForApprovalView.isHidden = true
            btnJoin.isHidden = true
        case .rejected_by_admin:
            joinAndWaitingForApprovalView.isHidden = false
            btnJoin.isHidden = false
        case .defaultState:
            let isMember = group.groupMembers?.contains(where: { $0.userID == Cache.shared.user?.userID })
            if let isMember = isMember,isMember {
                joinAndWaitingForApprovalView.isHidden = true
                btnJoin.isHidden = true
            } else {
                joinAndWaitingForApprovalView.isHidden = false
                btnJoin.isHidden = false
            }
        }
        self.resetAllFilters()
        self.setSelectedFilter(filter: filter)
    }
    
    func setSelectedFilter(filter: GroupDataFilterType) {
        self.filterStack.arrangedSubviews.forEach { view in
            if view.tag == filter.rawValue {
                view.backgroundColor = UIColor.init(hexString: "EBF8EF")
            }
        }
    }
    
    func resetAllFilters() {
        self.filterStack.arrangedSubviews.forEach { view in
            view.backgroundColor = UIColor.init(hexString: "F3F5F8")
        }
    }
    
}
