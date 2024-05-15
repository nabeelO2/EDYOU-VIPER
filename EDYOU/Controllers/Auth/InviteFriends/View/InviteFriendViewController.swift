//
//  InviteFriendsViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit
import TransitionButton

class InviteFriendViewController: BaseController {
    
    @IBOutlet weak var inviteFriendsTableView: UITableView!
    @IBOutlet weak var nextButton: TransitionButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var presenter : InviteFriendsPresenterProtocol!
    var peoples = [User]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
    }
    
    func configure() {
        inviteFriendsTableView.register(AddFriendTableViewCell.nib, forCellReuseIdentifier: AddFriendTableViewCell.identifier)
        inviteFriendsTableView.dataSource = self
        inviteFriendsTableView.delegate = self
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        
        presenter.navigateToAddPhotoVC()
        
    }
    
    @IBAction func skipButtonTouched(_ sender: Any) {
        presenter.navigateToAddPhotoVC()
        
    }
    
}

extension InviteFriendViewController : InviteFriendsViewProtocol{
    func prepareUI() {
        nextButton.alpha = 0.5
        nextButton.isUserInteractionEnabled = false
        configure()
    }
    
    func showError(_ error: String) {
        self.showErrorWith(message: error)
    }
    func reloadTableView(_ peoples: [User]) {
        self.peoples = peoples
        self.inviteFriendsTableView.reloadData()
    }
    
    func updateUI()
    {
        nextButton.alpha = 1.0
        nextButton.isUserInteractionEnabled = true
        skipButton.isHidden = true
        
    }
}

//MARK: uitableview delegates
extension InviteFriendViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peoples.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AddFriendTableViewCell.identifier, for: indexPath) as! AddFriendTableViewCell
        cell.setData(peoples[indexPath.row])
        cell.delegate = self
        return cell
        
    }
}

//MARK: addFriendCell delegates
extension InviteFriendViewController : AddFriendCellDelegate
{
    func addFriend(user: User, _ onSuccess: @escaping (Any) -> Void) {
        presenter.addFriend(user, onSuccess)
    }
}
