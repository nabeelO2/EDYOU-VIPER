//
//  SelectFriendsController.swift
//  EDYOU
//
//  Created by  Mac on 20/09/2021.
//

import UIKit

class SelectFriendsController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewContainerCollectionView: UIView!
    @IBOutlet weak var viewTopIndicator: UIView!
    
    @IBOutlet weak var cstStackViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    var excluding: [User] = []
    var selectedFriends : [User] = []
    var completion: ((_ users: [User]) -> Void)?
    var friendsAdapter: SelectFriendAdapter!
    var selectedFriendsAdapter: SelectFriendCollectionViewAdapter!
    
    private var groupId: String? = nil
    private var type: GroupFriendsType = .notJoined
    private var strTitle: String = ""
    

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = strTitle
        friendsAdapter = SelectFriendAdapter(tableView: tableView, didChangeSelection: { [weak self] in
            guard let self = self else { return }
            
            let selectedFriends = self.friendsAdapter.friends.filter { $0.isSelected }
            self.selectedFriendsAdapter.friends = selectedFriends
            self.viewContainerCollectionView.isHidden = selectedFriends.count == 0
            self.collectionView.reloadData()
        })
        selectedFriendsAdapter = SelectFriendCollectionViewAdapter(collectionView: collectionView, didRemoveUser: { [weak self] user in
            guard let self = self else { return }
            
            self.friendsAdapter.deselectUser(user)
            self.viewContainerCollectionView.isHidden = self.selectedFriendsAdapter.friends.count == 0
        })
        
      
        
        if let g = groupId {
            getFriends(groupId: g)

        } else {
            friendsAdapter.friends = Cache.shared.friends?.friends ?? []
            friendsAdapter.searchedFriends = friendsAdapter.friends
            friendsAdapter.isLoading = friendsAdapter.friends.count == 0
            viewTopIndicator.isHidden = self.modalPresentationStyle != .pageSheet
            getFriends()
        }
        
        loadPreSelectedFriends()
  
        
    }
    
    fileprivate func loadPreSelectedFriends()
    {
        if selectedFriends.count > 0
        {
            self.selectedFriendsAdapter.friends = selectedFriends
            for (index,friend) in self.friendsAdapter.friends.enumerated()
            {
                if self.selectedFriendsAdapter.friends.filter{ $0.userID == friend.userID}.count > 0
                {
                    self.friendsAdapter.friends[index].isSelected = true
                }
                
            }
            self.viewContainerCollectionView.isHidden = selectedFriends.count == 0
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
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
    init(title: String = "Invite Friends", excluding: [User] = [], completion: @escaping (_ users: [User]) -> Void) {
        super.init(nibName: SelectFriendsController.name, bundle: nil)
        
        self.strTitle = title
        self.excluding = excluding
        self.completion = completion
    }
    init(title: String = "Invite Friends", groupId: String, type: GroupFriendsType, completion: @escaping (_ users: [User]) -> Void) {
        super.init(nibName: SelectFriendsController.name, bundle: nil)
        
        self.strTitle = title
        self.groupId = groupId
        self.type = type
        self.completion = completion
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


// MARK: - Actions
extension SelectFriendsController {
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapNextButton(_ sender: UIButton) {
        completion?(self.selectedFriendsAdapter.friends)
        self.dismiss(animated: true, completion: nil)
    }
    
}
// MARK: - TextField Delegate
extension SelectFriendsController: UITextFieldDelegate {
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
extension SelectFriendsController {
    func getFriends() {
        APIManager.social.getFriends { friends, error in
            
            self.friendsAdapter.isLoading = false
            if error == nil {
                if let f = friends?.friends  {
                    if self.excluding.count == 0 {
                        self.friendsAdapter.friends = f
                        self.friendsAdapter.searchedFriends = f
                        self.loadPreSelectedFriends()
                    } else {
                        
                        var usrs = [User]()
                        for u in f {
                            let isExcluded = self.excluding.contains { $0.userID == u.userID }
                            if !isExcluded {
                                usrs.append(u)
                            }
                        }
                        self.friendsAdapter.friends = usrs
                        self.friendsAdapter.searchedFriends = usrs
                        
                    }
                    
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            
        }
    }
    func getFriends(groupId: String) {
        
        APIManager.social.getGroupFriends(groupId: groupId) { groupFriends, error in
            
            self.friendsAdapter.isLoading = false
            if error == nil {
                
                if let f = groupFriends?.notJoined  {
                    if self.excluding.count == 0 {
                        self.friendsAdapter.friends = f
                        self.friendsAdapter.searchedFriends = f
                        self.loadPreSelectedFriends()
                    } else {
                        
                        var usrs = [User]()
                        for u in f {
                            let isExcluded = self.excluding.contains { $0.userID == u.userID }
                            if isExcluded != true {
                                usrs.append(u)
                            }
                        }
                        
                        
                        self.friendsAdapter.friends = usrs
                        self.friendsAdapter.searchedFriends = usrs
                        
                    }
                    
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()
            
            
            
        }
        
    }
}

