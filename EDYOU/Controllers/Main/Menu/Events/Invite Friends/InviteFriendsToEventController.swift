//
//  InviteFriendsToEventController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit

class InviteFriendsToEventController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewContainerCollectionView: UIView!
    
    @IBOutlet weak var cstStackViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    var dismissOnBack = true
    var eventId = ""
    var friendsAdapter: InviteFriendsToEventAdapter!
    var selectedFriendsAdapter: InviteFriendsToEventCollectionViewAdapter!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsAdapter = InviteFriendsToEventAdapter(tableView: tableView, didChangeSelection: { [weak self] in
            guard let self = self else { return }
            
            let selectedFriends = self.friendsAdapter.friends.filter { $0.isSelected }
            self.selectedFriendsAdapter.friends = selectedFriends
            self.viewContainerCollectionView.isHidden = selectedFriends.count == 0
            self.collectionView.reloadData()
        })
        selectedFriendsAdapter = InviteFriendsToEventCollectionViewAdapter(collectionView: collectionView, didRemoveUser: { [weak self] user in
            guard let self = self else { return }
            
            self.friendsAdapter.deselectUser(user)
            self.viewContainerCollectionView.isHidden = self.selectedFriendsAdapter.friends.count == 0
        })
        
        friendsAdapter.isLoading = true
        getFriends()
        friendsAdapter.configure()
        friendsAdapter.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstStackViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstStackViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }
    
    init(eventId: String, dismissOnBack: Bool = true) {
        super.init(nibName: InviteFriendsToEventController.name, bundle: nil)
        
        self.dismissOnBack = dismissOnBack
        self.eventId = eventId
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


// MARK: - Actions
extension InviteFriendsToEventController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.popBackAndReload()
    }
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        if selectedFriendsAdapter.friends.count > 0 {
            self.invite()
        } else {
            self.popBackAndReload()
        }
    }
}
// MARK: - TextField Delegate
extension InviteFriendsToEventController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        friendsAdapter.search(text: expectedText)
        
        return true
    }
}

// MARK: - Web APIs
extension InviteFriendsToEventController {
    func getFriends() {
        APIManager.social.getFriendsOnly { friends, error in
            self.friendsAdapter.isLoading = false
            if error == nil {
                self.friendsAdapter.friends = friends
                self.friendsAdapter.searchedFriends = friends
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
        }
    }
    
    func invite() {
        let users = selectedFriendsAdapter.friends.map { $0.userID! }
        if users.count == 0 {
            self.showErrorWith(message: "No friend selected")
        }
        
        APIManager.social.inviteFriends(eventId: eventId, friendsIds: users) { (error) in
            if error == nil {
                self.showSuccessMessage(message: "Invited successfully")
                self.popBackAndReload()
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
        
        
    }
    
    private func popBackAndReload() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EventsController.EventRefreshNotification), object: nil, userInfo: nil)
        self.popBack(3)
    }
}

