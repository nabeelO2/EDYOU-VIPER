//
//  AddFriendTableViewCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit
protocol AddFriendCellDelegate: AnyObject {
    func addFriend(user: User,_ onSuccess: @escaping(Any) -> Void)
  
}
class AddFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    var friendshipStatus: FriendShipStatusModel!
    var action: AddFriendAction?
    @IBOutlet weak var profileVerifiedLogo: UIImageView!

    weak var delegate : AddFriendCellDelegate?
    
    var user = User()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        profileImageView.image = R.image.profile_image_dummy()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  
    
    func setData(_ user: User,_  isAlreadyRequestSent : Bool = false) {
        self.user = user
        endSkeltonAnimation()
        
        profileImageView.setImage(url: user.profileImage, placeholder: R.image.profileImagePlaceHolder())
        nameLabel.text = user.name?.completeName ?? "--"
        detailLabel.text = user.college ?? "--"
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2.0
        profileVerifiedLogo.isHidden = user.isUserVerified
        //setTheConfirmButtonTitle(self.user)
        let text = isAlreadyRequestSent ? "Request Sent" : "Add Friend"
        self.addFriendButton.setTitle(text, for: .normal)
    }
    
    func setTheConfirmButtonTitle(_ user: User) {
        self.friendshipStatus = FriendShipStatusModel(friendID: user.userID, friendRequestStatus: user.friendrequeststatus, requestOrigin: .sent)
        let action = AddFriendAction.from(status: friendshipStatus)
        self.action = action
        self.addFriendButton.setTitle(action.title, for: .normal)
        
    }
    
  
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        
        let views: [UIView] = [profileImageView, nameLabel, detailLabel, addFriendButton, profileVerifiedLogo ]
        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
        let views: [UIView] = [profileImageView, nameLabel, detailLabel, profileVerifiedLogo]
        views.forEach { $0.stopSkelting() }
    }
    
  
    @IBAction func addFriendButtonTouched(_ sender: UIButton) {
        
        delegate?.addFriend(user: self.user) { success in
            DispatchQueue.main.async {
                self.addFriendButton.setTitle(success as! Bool ? "Request Sent" : "Add Friend", for: .normal)
                self.addFriendButton.tag = success as! Bool ? 1 : 0
                self.layoutSubviews()
                self.layoutIfNeeded()
            }
           
        }
    }
}
