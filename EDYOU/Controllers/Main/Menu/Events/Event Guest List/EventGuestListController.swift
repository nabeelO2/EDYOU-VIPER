//
//  EventGuestListController.swift
//  EDYOU
//
//  Created by Aksa on 11/09/2022.
//

import UIKit

class EventGuestListController: BaseController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearTextButton: UIButton!
    @IBOutlet weak var vInvite: UIView!
    var event: Event
    var options: [PeopleProfileTypes]
    var selectedFriends : [User]!
    
    lazy var adapater = EventGuestAdapater(tableView: self.tableView, collectionView: self.collectionView, event: self.event, options: self.options)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    init(event: Event, options: [PeopleProfileTypes]) {
        self.event = event
        self.options = options
        super.init(nibName: EventGuestListController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.event = Event(event: EventBasic.init())
        self.options = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
        loadData()
    }
    
    
    
    func configure() {
        searchText.delegate = self
    }
    
    func loadData() {
        self.adapater.reloadData()
        if !self.event.isIAmAdmin {
            self.vInvite.isHidden = !self.event.anyoneCanInvite.asBoolOrFalse()
        }
    }
    
    func search(text: String) {
        clearTextButton.isHidden = text.count == 0
        self.adapater.search(text: text)
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        let u = event.peoplesProfile?.allUsers ?? []
        let controller = SelectFriendsController() { friends in
            self.selectedFriends = friends
            self.invite()
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchText.becomeFirstResponder()
        searchView.isHidden = false
        searchView.alpha = 1
    }
    
    @IBAction func clearSearchText(_ sender: UIButton) {
        searchText.text = ""
        clearTextButton.isHidden = true
        search(text: "")
    }
    
    @IBAction func searchTextDidChanged(_ sender: UITextField) {
        search(text: searchText.text ?? "")
    }
    
    @IBAction func cancelSearchDidTapped(_ sender: UIButton) {
        view.endEditing(true)
        searchView.isHidden = true
        searchView.alpha = 0
        self.search(text: "")
    }
}

// MARK: TextField Delegate
extension EventGuestListController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        search(text: textField.text ?? "")
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        clearTextButton.isHidden = expectedText.count == 0
        search(text: expectedText)
        return true
    }
}

// MARK: - API calls
extension EventGuestListController  {
    func invite() {
        self.startLoading(title: "")
        let users = selectedFriends.map { $0.userID! }
        if users.count == 0 {
            self.stopLoading()
            self.showErrorWith(message: "No friend selected")
        }
        APIManager.social.inviteFriends(eventId: event.eventID ?? "", friendsIds: users) { (error) in
            self.stopLoading()
            
            if error == nil {
                self.showSuccessMessage(message: "Invited successfully")
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}
