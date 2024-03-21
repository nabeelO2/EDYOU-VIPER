//
//  NewChatController.swift
//  EDYOU
//
//  Created by  Mac on 05/12/2021.
//

import UIKit
import Martin

class NewChatController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var adapter: NewChatAdapter!
    var didSelectUser: ((_ user: User) -> Void)?
    @IBOutlet weak var txtSearch: UITextField!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = NewChatAdapter(tableView: tableView, didSelectUser: { [weak self] user in
            self?.didSelectUser?(user)
          
            self?.dismiss(animated: true, completion: nil)
        })
        getFriends()
    }
    
    init(didSelectUser: @escaping (_ user: User) -> Void) {
        super.init(nibName: NewChatController.name, bundle: nil)
        
        self.didSelectUser = didSelectUser
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func didTapCreateButton(_ sender: UIButton) {
        let controller = ChatAddParticipantsController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension NewChatController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.expectedText(changeCharactersIn: range, replacementString: string).trimmed
        if text.count > 0 {
        
            adapter.users = self.users.filter { $0.contains(text: text) }
        } else {
            adapter.users = self.users
        }
        tableView.reloadData()
        
        return true
    }
}

// MARK: - Web APIs
extension NewChatController {
    func getFriends() {
        APIManager.social.getFriendsOnly { friends, error in

            self.adapter.isLoading = false
            if error == nil {
                self.users = friends
                self.adapter.users = friends
                Cache.shared.frinedDict =  friends.reduce(into: Cache.shared.frinedDict) { result, user in
                    result["\(user.userID ?? "")@ejabberd.edyou.io"] = [user.name?.completeName ?? user.formattedUserName,user.profileImage ?? ""]
                }
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.tableView.reloadData()

        }
    }
    
}
