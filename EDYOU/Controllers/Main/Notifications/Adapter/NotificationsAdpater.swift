//
//  NotificationsAdpater.swift
//  EDYOU
//
//  Created by PureLogics on 05/01/2022.
//

import UIKit
//import EmptyDataSet_Swift

class NotificationsAdpater: NSObject {
    
    weak var tableView: UITableView!
    var parent: NotificationsController? {
        return tableView.viewContainingController() as? NotificationsController
    }
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    var isLoading = true
    var isMultipleSelectionEnabled = false
    
    private var notifications = [NotificationData]()
    var selectedIds = [String]()
    
    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        configure()
    }
    
    func configure() {
        tableView.register(NotificationGeneralCell.nib, forCellReuseIdentifier: NotificationGeneralCell.identifier)
        tableView.register(NotificationFriendRequestCell.nib, forCellReuseIdentifier: NotificationFriendRequestCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 70.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
    }
    
    func setNotificationData(notification: [NotificationData], category: NotificationCategory) {
//        notification.forEach { n in
//            print("action : "+(n.actionName?.lowercased())!)
//        }
        switch category {
        case .all:
            self.notifications = notification
            print(self.notifications.count)
            
        case .friendRequests:
            self.notifications = notification.filter({$0.actionName == NotificationType.friend.rawValue || $0.actionName == NotificationType.profile.rawValue})
           
        case .comment:
            self.notifications = notification.filter({$0.actionName == NotificationType.comment.rawValue})
            
        case .react:
            self.notifications = notification.filter({$0.actionName == NotificationType.reaction.rawValue})
           
        case .group:
            self.notifications = notification.filter({$0.actionName == NotificationType.group.rawValue || $0.actionName == NotificationType.group_Invite.rawValue})
           
        case .event:
            self.notifications = notification.filter({$0.actionName == NotificationType.event.rawValue})
           
        }
        
        self.tableView.reloadData()
    }
}

extension NotificationsAdpater: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.restore()
        if notifications.count == 0 {
            tableView.addEmptyView("No Notifications found", "Expand your search to try again", R.image.empty_notification())
        }
        tableView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : notifications.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationGeneralCell.identifier, for: indexPath) as! NotificationGeneralCell
        if isLoading {
            cell.beginSkeltonAnimation()
            cell.contentView.backgroundColor = UIColor.white
        } else {
            cell.setData(notifications[indexPath.row])
            cell.contentView.backgroundColor = notifications[indexPath.row].read == false ? "F4FFF4".color : UIColor.white
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.clear // Change this to your desired color
        cell.selectedBackgroundView = selectedBackgroundView
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isMultipleSelectionEnabled{
            if let n = notifications.object(at: indexPath.row), let action = NotificationType(rawValue: n.actionName ?? ""), let id = n.actionId {
                didSelectNotification(action: action, notification: n)
                APIManager.social.readNotifications(id: n.notificationId ?? "") { (error) in
                    if error != nil {
                        self.parent?.showErrorWith(message: error!.message)
                    }
                }
            }
        }
        else{
            if let n = notifications.object(at: indexPath.row), let id = n.notificationId{
                selectedIds.append(id)
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isMultipleSelectionEnabled{
            if let n = notifications.object(at: indexPath.row), let notificationId = n.notificationId{
                selectedIds.removeAll { id in
                    id.lowercased() == notificationId.lowercased()
                }
            }
        }
    }
    func didSelectNotification(action: NotificationType?, notification : NotificationData) {
        let id = notification.actionId ?? ""
        if let action = action {
            switch action {
            case .chat:
            //TODO: Handle Chat
                break
            case .post,.comment,.reaction:
                let post = Post(userID: "", postID: id)
                
                if action == .reaction && notification.actionIdName?.lowercased() == "comment_id"{
                    print(id)
                    let controller = PostDetailsController(post: post, prefilledComment: nil,commentId: id)
                    navigationController?.pushViewController(controller, animated: true)
                }
                else if action == .comment && notification.actionIdName?.lowercased() == "comment_id"{
                    print(id)
                    let controller = PostDetailsController(post: post, prefilledComment: nil,commentId: id)
                    navigationController?.pushViewController(controller, animated: true)
                }
                else{
                    let controller = PostDetailsController(post: post, prefilledComment: nil)
                    navigationController?.pushViewController(controller, animated: true)
                }
               
                break
                
            case .group, .group_Invite:
                let group = Group(groupID: id)
                let controller = GroupDetailsController(group: group)
                if action == .group_Invite {
                    controller.shouldCallInvite = false
                }
                navigationController?.pushViewController(controller, animated: true)
                break
            case .profile,.friend:
                let user = User(userID: notification.senderId ?? "")
                let controller = ProfileController(user: user)
                navigationController?.pushViewController(controller, animated: true)
                break
            case .event:
                let event = Event(event: EventBasic(eventID: id))
                let controller = EventDetailsController(event: event)
                navigationController?.pushViewController(controller, animated: true)
                break
            case .message:
                break
            case .story:
                //open story
                if let mainTabbar = navigationController?.viewControllers[0] as? MainTabBarController{
                    if let home = mainTabbar.viewControllers?.first as? HomeController{
                        let stories = home.adapter.storyADP.getStories()
                        
                        
                        let controller = ShowStoriesController()
                        let navigationController = UINavigationController(rootViewController: controller)
//                        controller.selectedIndex = 0
                        controller.stories = stories
                        navigationController.modalPresentationStyle = .fullScreen
                        navigationController.navigationBar.isHidden = true
                        
                        
                        parent?.navigationController?.present(navigationController, animated: true, completion: nil)
                        
                        
                    }
                    
                }
                
                
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        print(#function)
    }
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        print(#function)
//        tableView.selected
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, complete in
            guard let self = self, indexPath.row < self.notifications.count else { return }


            let n = self.notifications[indexPath.row]
            self.delete(notification: n, indexPath: indexPath)

            tableView.beginUpdates()
            self.notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            complete(true)
        }
        deleteAction.image = UIImage(named: "trash")
        
        let readAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, complete in
            guard let self = self, indexPath.row < self.notifications.count else { return }


            let n = self.notifications[indexPath.row]
            self.read(notification: n, indexPath: indexPath)

//            tableView.beginUpdates()
//            self.notifications.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()

            complete(true)
        }
        readAction.image = UIImage(named: "read")

        return UISwipeActionsConfiguration(actions: [readAction, deleteAction])
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
    
    
}

//extension NotificationsAdpater: EmptyDataSetSource, EmptyDataSetDelegate {
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "No Notifications found", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black])
//    }
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        NSAttributedString(string: "Expand your search to try again", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .semibold), NSAttributedString.Key.foregroundColor: R.color.sub_title()!])
//    }
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return R.image.empty_notification()!
//    }
//}

extension NotificationsAdpater {
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
    
    func delete(notification: NotificationData, indexPath: IndexPath) {
        APIManager.social.deleteNotifications(id: notification.notificationId ?? "") { (error) in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                self.tableView.beginUpdates()
                self.notifications.insert(notification, at: indexPath.row)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
        
    }
 
    func readAllNotifications(){
        let parameters = ["notification_ids" : selectedIds] as! [String : Any]
        
        APIManager.social.readSelectedNotifications(parameters: parameters) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                self.tableView.reloadData()
            }
            else{
                self.selectedIds.forEach { id in
                    if let index = self.notifications.firstIndex(where: { obj in
                        obj.notificationId?.lowercased() == id.lowercased()
                    }){
                        self.notifications[index].read = true
                    }
                }
                self.parent?.deselectTableview()
                self.tableView.reloadData()
            }

        }
    }
    func deleteAllNotification() {
        
        APIManager.social.deleteAllNotifications(ids: selectedIds) { (error) in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
                self.tableView.reloadData()
            }
            else{
                self.selectedIds.forEach { id in
                    self.notifications.removeAll { obj in
                        obj.notificationId?.lowercased() == id.lowercased()
                    }
                }
                
//                self.tableView.beginUpdates()
                self.parent?.deselectTableview()
                self.tableView.reloadData()
//                self.tableView.endUpdates()
            }
        }
        
    }
    
    func read(notification: NotificationData, indexPath: IndexPath) {
        APIManager.social.readNotifications(id: notification.notificationId ?? "") { (error) in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
//                self.tableView.beginUpdates()
//                self.notifications.insert(notification, at: indexPath.row)
//                self.tableView.insertRows(at: [indexPath], with: .automatic)
//                self.tableView.endUpdates()
            }
            else{
                self.notifications[indexPath.row].read = true
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
    }
    
    
}

