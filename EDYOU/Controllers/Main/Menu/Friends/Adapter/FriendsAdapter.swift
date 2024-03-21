//
//  FriendsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 10/09/2021.
//

import UIKit
import EmptyDataSet_Swift
import SwiftUI
import Martin

class FriendsAdapter: NSObject {
    
    weak var tableView: UITableView!
    weak var textField : UITextField!
    var parent: FriendsController? {
        return tableView.viewContainingController() as? FriendsController
    }
    var isLoading = true
    var searchedFriends = [User]()
    var friends = [User]()
    var requestSents: [User] = []
    init(tableView: UITableView,textField: UITextField) {
        super.init()
        
        self.tableView = tableView
        self.textField = textField
        
        self.textField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
        configure()
        
    }
    @objc func searchTextFieldDidChange(textField: UITextField) {
        if textField.text != "" {
            parent?.btnClear.isHidden = false
        } else {
            parent?.btnClear.isHidden = true
        }
        self.search(textField.text ?? "")
        }
    func configure() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.register(AddFriendTableViewCell.nib, forCellReuseIdentifier: AddFriendTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = friends.filter { $0.name?.completeName.lowercased().contains(t) == true }
            self.searchedFriends = f
        } else {
            self.searchedFriends = friends
        }
        tableView.reloadData()
        
    }
    func sortRequests(filters: [FilterOptions]) {
        let requiredFilter = filters.filter { filterOption in
            if filterOption.valueChanged {
                return true
            } else {
                return false
            }
        }
        if !requiredFilter.isEmpty {
            if requiredFilter[0].title == "Recived Request" {
                self.friends = parent?.received ?? []
                self.searchedFriends = friends
                self.tableView.reloadData()
            } else {
                self.friends = parent?.sent ?? []
                self.searchedFriends = friends
                self.tableView.reloadData()
            }
        } else {
            self.friends = (parent?.received ?? []) + (parent?.sent ?? [])
            self.searchedFriends = friends
            self.tableView.reloadData()
        }
    }
}

extension FriendsAdapter {
    @objc func didTapConfirmButton(_ sender: UIButton) {
        guard let user = searchedFriends.object(at: sender.tag) else { return }
        sender.alpha = 0.5
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let requestStatus: FriendRequestStatus = sender.title(for: .normal) == "Cancel" ? .cancel : .approved
        
        updateRequestStatus(user: user, status: requestStatus) { status in
            sender.alpha = 1
            
            if status == true {
                self.searchedFriends.remove(at: sender.tag)
                
                if requestStatus == .approved {
                    self.parent?.friends.append(user)
                    self.parent?.friends = self.parent?.friends.sorted(by: { ($0.name?.completeName ?? "") < ($1.name?.completeName ?? "") }) ?? []
                }
                
                self.tableView.reloadData()
                
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
    }
    @objc func didTapRemoveButton(_ sender: UIButton) {
        guard let user = searchedFriends.object(at: sender.tag) else { return }
        sender.alpha = 0.5
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        updateRequestStatus(user: user, status: .rejected) { status in
            sender.alpha = 1
            
            if status == true {
                self.searchedFriends.remove(at: sender.tag)
                
                self.tableView.reloadData()
                
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    @objc func didTapCallButton(_ sender: UIButton) {
        
    }
    @objc func didTapMessageButton(_ sender: UIButton) {
        
    }
}

extension FriendsAdapter: UITableViewDataSource, UITableViewDelegate,UserCellActionsDelegate {
    
    func unblockUser(user: User) {
        
    }
    
    func callToUser(user: User) {
        if let chat = DBChatStore.getRoomInfoFrom(jid: BareJID("\(user.userID ?? "")@ejabberd.edyou.io"),isRoom:false) {
            self.initiateCallWithRoomId(room:chat)
        } else if let contaxt = XmppService.instance.connectedClients.first {
            switch DBChatStore.instance.createChat(for:contaxt, with: BareJID("\(user.userID ?? "")@ejabberd.edyou.io"), name: user.name?.completeName ?? "") {
                case .created(let chat),.found(let chat):
                    self.initiateCallWithRoomId(room:chat)
                case .none:
                    self.parent?.showErrorWith(message: "unable to intiate Call try again after some time")
                    break
            }
        } else {
            self.parent?.showErrorWith(message: "Unable to connect to server")
        }
    }

    func initiateCallWithRoomId(room: Conversation) {
        AudioVideoCallViewController.checkAudioVideoPermissions(parent: parent!) {
            if $0 {
                generateHapticFeedback()
                APIManager.social.CallChatRoom(roomId: [room.jid.localPart ?? ""], callType: .audio,roomJID: room.jid.stringValue) { chatCall, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parent?.showErrorWith(message: error.message)
                            return
                        }
                        CallManager.shared.startCall(room: room ,callType: .audio, token: chatCall?.accessToken ?? "")
                    }
                }
            }
        }
    }
    
    func sendMessageToUser(user: User) {
      let userJID =  BareJID("\(user.userID ?? "")@ejabberd.edyou.io")
        DispatchQueue.main.async {
            if let clint = XmppService.instance.connectedClients.first {
                let res =  DBChatStore.instance.createChat(for: clint.context, with: userJID, name: user.name?.completeName ?? "")
                switch res {
                    case .created(_),.found(_):
                        print("created")
                        DBChatStore.instance.refreshConversationsList()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            if let conversation = DBChatStore.instance.conversation(for: clint.userBareJid, with: userJID) {
                                let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                                controller.conversation = conversation
                                self.parent?.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    case .none:
                        self.parent?.showErrorWith(message: "Error while fetching Chat User")
                        return
                }
            } else {
                self.parent?.showErrorWith(message: "Unable to connect to server")
            }
        }
    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : searchedFriends.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let t = parent?.selectedTab
        
        
        
        
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
            cell.beginSkeltonAnimation()
            return cell
        }
        else if t == .suggestions{
            
            let friendCell = tableView.dequeueReusableCell(withIdentifier: AddFriendTableViewCell.identifier, for: indexPath) as! AddFriendTableViewCell
            
            let isRequestSent = requestSents.first(where: {$0.userID == searchedFriends[indexPath.row].userID})
            friendCell.setData(searchedFriends[indexPath.row], isRequestSent != nil)
            friendCell.endSkeltonAnimation()
            friendCell.delegate = self
            friendCell.selectionStyle = .none
                
            return friendCell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
            
            cell.btnConfirm.isHidden = true
            cell.viewCross.isHidden = true
            cell.viewCall.isHidden = true
            cell.viewCheckMark.isHidden = true
            cell.viewMessage.isHidden = true
            cell.delegate = self
            
            cell.setData(searchedFriends[indexPath.row])
            
            if t == .requests {
                cell.stkButtons.spacing = 6
                if searchedFriends[indexPath.row].requestOrigin == "sent"{
                    cell.btnConfirm.isHidden = false
                    cell.btnConfirm.backgroundColor = UIColor(hexString: "#000000")
                    cell.btnCross.backgroundColor = UIColor(hexString: "#000000")
                    cell.btnConfirm.setTitle("Cancel Request", for: .normal)
                } else {
                cell.btnConfirm.isHidden = false
                cell.viewCross.isHidden = false
                cell.btnConfirm.backgroundColor = UIColor(hexString: "#000000")
                cell.btnConfirm.setTitle("Confirm", for: .normal)
                cell.btnCross.backgroundColor = UIColor(hexString: "#000000")

                }

            } else if t == .friends {
                cell.stkButtons.spacing = 14
                cell.viewCall.isHidden = false
                cell.viewMessage.isHidden = false
            }
            
            cell.btnConfirm.tag = indexPath.row
            cell.btnCross.tag = indexPath.row
            cell.btnMessage.tag = indexPath.row
            cell.btnCall.tag = indexPath.row
            
            cell.btnConfirm.addTarget(self, action: #selector(didTapConfirmButton(_:)), for: .touchUpInside)
            cell.btnCross.addTarget(self, action: #selector(didTapRemoveButton(_:)), for: .touchUpInside)
            cell.btnMessage.addTarget(self, action: #selector(didTapMessageButton(_:)), for: .touchUpInside)
            cell.btnCall.addTarget(self, action: #selector(didTapCallButton(_:)), for: .touchUpInside)
            
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = searchedFriends.object(at: indexPath.row) {
            
            let controller = ProfileController(user: user)
            let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
            controller.requestSent = { res in
                if res{//add
                    self.requestSents.append(user)
                }
                else{//remove
                    if let userIndex = self.requestSents.firstIndex(where: {$0.userID == user.userID}){
                        self.requestSents.remove(at: userIndex)
                    }
                }
                self.tableView.reloadData()
            }
            navC?.pushViewController(controller, animated: true)
            
        }
    }
    
}

extension FriendsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(imageLiteralResourceName: "menu_friends_icon")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var message = "No friends yet!"
        
        if parent?.selectedTab == .requests {
            message = "No friends request yet!"
        } else if parent?.selectedTab == .suggestions {
            message = "No friends suggestion yet!"
        }
        
        return NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var message = "You have no friend in list"
        
        if parent?.selectedTab == .requests {
            message = "You have no friend requests/sent invitations for now"
        } else if parent?.selectedTab == .suggestions {
            message = "You have no friends suggestions for now"
        }
        
        return NSAttributedString(string: message, attributes: [NSAttributedString.Key.font :  UIFont.systemFont(ofSize: 16)])
    }
}

extension FriendsAdapter {
    
    func updateRequestStatus(user: User, status: FriendRequestStatus, completion: @escaping (_ status: Bool) -> Void) {
        
        
        APIManager.social.updateFriendRequestStatus(user: user, status: status) { error in

            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                completion(false)
            } else {
                completion(true)
            }
            
            
        }
    }
    
}


extension FriendsAdapter : AddFriendCellDelegate{
     
    func addFriend(user: User, _ onSuccess: @escaping (Any) -> Void) {
        
        self.addFriendAPI(user: user) { success in
            self.requestSents.append(user)
            onSuccess(success)
        }
    }
    
    func addFriendAPI(user:User, _ onSuccess: @escaping (Any) -> Void)
    {
        APIManager.social.sendFriendRequest(user: user, message: "Hi add me in your friends list.") { [weak self] error in

            guard let self = self else { return }
            if error == nil {
               // self.parent?.getSuggestedPeople()
               onSuccess(true)
            } else {
              
                if error!.message != "Record already exist"
                {
                    onSuccess(false)
                    self.parent?.showErrorWith(message: error!.message)
                }
                else
                {
                  //  self.parent?.getSuggestedPeople()
                    onSuccess(true)
                }
            }
        }
        
    }

}
