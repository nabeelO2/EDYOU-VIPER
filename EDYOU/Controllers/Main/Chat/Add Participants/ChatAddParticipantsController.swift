//
//  ChatAddParticipantsController.swift
//  EDYOU
//
//  Created by  Mac on 05/12/2021.
//

import UIKit
import TransitionButton

class ChatAddParticipantsController: BaseController {
    
    @IBOutlet weak var btnCreate: TransitionButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewContainerCollectionView: UIView!
    @IBOutlet weak var viewTopIndicator: UIView!
    
    var friendsAdapter: SelectFriendAdapter!
    var selectedFriendsAdapter: SelectFriendCollectionViewAdapter!
    var groupPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        friendsAdapter = SelectFriendAdapter(tableView: tableView, didChangeSelection: { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
            let selectedFriends = self.friendsAdapter.friends.filter { $0.isSelected }
            self.selectedFriendsAdapter.friends = selectedFriends
            self.viewContainerCollectionView.isHidden = selectedFriends.count == 0
            self.collectionView.reloadData()
            self.btnCreate.isEnabled = selectedFriends.count > 0
            self.btnCreate.backgroundColor = self.btnCreate.isEnabled ? R.color.buttons_green() : R.color.border()
        })
        selectedFriendsAdapter = SelectFriendCollectionViewAdapter(collectionView: collectionView, didRemoveUser: { [weak self] user in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.friendsAdapter.deselectUser(user)
            self.viewContainerCollectionView.isHidden = self.selectedFriendsAdapter.friends.count == 0
        })
        getFriends()
    }
}


// MARK: - Actions
extension ChatAddParticipantsController {
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        let controller = CreateChatGroupController()
        controller.users = selectedFriendsAdapter.friends
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}


extension ChatAddParticipantsController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.expectedText(changeCharactersIn: range, replacementString: string).trimmed
        if text.count > 0 {
            friendsAdapter.searchedFriends = self.friendsAdapter.friends.filter { $0.contains(text: text) }
        } else {
            friendsAdapter.searchedFriends = self.friendsAdapter.friends
        }
        tableView.reloadData()
        
        return true
    }
}

// MARK: - Web APIs
extension ChatAddParticipantsController {
    func getFriends() {
        APIManager.social.getFriends { friends, error in
            
            self.friendsAdapter.isLoading = false
            if error == nil {
                if let f = friends?.friends  {
                    self.friendsAdapter.friends = f
                    self.friendsAdapter.searchedFriends = f
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            
        }
    }
    
    /*
    func createGroup() {
        
        let users = selectedFriendsAdapter.friends.map { $0.userID }
        
        if users.count > 0 {
            
            
            let parameters: [String: Any] = [
                "room_name": txtTitle.text ?? "",
                "members": users
            ]
            
            
            var media = [Media]()
            if let img = groupPhoto, let m = Media(withImage: img, key: "group_icon") {
                media.append(m)
            }
            
            viewProgressBar.isHidden = groupPhoto == nil
            btnCreate.startAnimation()
            self.view.isUserInteractionEnabled = false
            
            APIManager.social.createChatGroup(parameters: parameters, media: media) { [weak self] progress in
                self?.progressBar.progress = Double(progress)
            } completion: { [weak self] response, error in
                
                guard let self = self else { return }
                self.btnCreate.stopAnimation()
                self.view.isUserInteractionEnabled = true
                self.viewProgressBar.isHidden = true
                
                if error == nil {
                    NotificationCenter.default.post(name: NSNotification.Name(kNotificationDidCreateChatGroup), object: nil, userInfo: ["message": ""])
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showErrorWith(message: error!.message)
                }
            
            }
            
        } else {
            self.showErrorWith(message: "Select members")
        }
        
        
    } */
}
