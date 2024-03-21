//
//  NotificationsController.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 03/01/2022.
//

import UIKit
class NotificationsController: BaseController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var deleteBGV : UIView!
    @IBOutlet weak var selectBtn : UIButton!
    
    var adapter: NotificationsAdpater!
    var notifications = [NotificationData]()
    
    private var selectedCategory: NotificationCategory = .all
    lazy var categoryAdapter = NotificationCategoryAdapater(collectionView: self.categoryCollection, delegate: self, data: NotificationCategory.allCases, selectedCategory: self.selectedCategory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = NotificationsAdpater(tableView: tableView)
        getNotifications()
        self.categoryAdapter.reloadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotifications()
    }
    
}


// MARK: Actions
extension NotificationsController {
    @IBAction func didTapBackButton(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSelecButton(_ sender: UIButton) {
        if notifications.count > 0{
            
        }
        let isEdit = !self.tableView.isEditing
        self.tableView.setEditing(isEdit, animated: true)
        let title = isEdit ? "Done" : "Select"
        deleteBGV.isHidden = !isEdit
        sender.setTitle(title, for: .normal)
        adapter.isMultipleSelectionEnabled = isEdit
    }
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        adapter.deleteAllNotification()
    }
    @IBAction func didTapReadButton(_ sender: UIButton) {
        adapter.readAllNotifications()
    }
    
     func deselectTableview(){
        self.tableView.setEditing(false, animated: false)
        deleteBGV.isHidden = true
        selectBtn.setTitle("Select", for: .normal)
        adapter.isMultipleSelectionEnabled = false
    }
}

// MARK: Web APIs
extension NotificationsController {
    func getNotifications(){
        APIManager.social.getNotifications { [weak self] notifications, error in
            guard let self = self else { return }
            if error == nil {
//                self.adapter.notifications = notifications
                self.notifications = notifications
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.adapter.isLoading = false
            self.adapter.setNotificationData(notification: notifications, category: self.selectedCategory)
        }
    }
}

extension NotificationsController: NotificationCategoryAdapterProtocol {
    func notificationCategoryChanged(category: PropertyDescriptionProtocol) {
        deselectTableview()
        self.selectedCategory = category as! NotificationCategory
        self.adapter.setNotificationData(notification: notifications, category: self.selectedCategory)
    }
}
