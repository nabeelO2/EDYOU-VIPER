//
//  
//  SettingsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//
//

import UIKit

class SettingsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var parent: SettingsController? {
        return tableView.viewContainingController() as? SettingsController
    }
    
    var settingsItems: [SettingItem] = [.notification, .location, .password, .post ]
    var privacyItems: [SettingItem] = [.block, .privacyPolicy]
    var otherItems: [SettingItem] = [.deleteAccount]
    
    var data = [
        MenuItem(title: "Notifications", image: R.image.settings_notification_icon()),
        MenuItem(title: "Location", image: R.image.settings_location_icon()),
        MenuItem(title: "Password", image: R.image.settings_password_icon()),
        MenuItem(title: "Invite Friends", image: R.image.settings_share_icon()),
        MenuItem(title: "Post", image: R.image.settings_post_icon()),
        MenuItem(title: "Block", image: R.image.settings_block_icon()),
        MenuItem(title: "Privacy Policy", image: R.image.settings_privacy_icon()),
        MenuItem(title: "Delete Account", image: R.image.delete_chat_icon())]
        //MenuItem(title: "Help", image: R.image.settings_help_icon())] //will  be  added  later
    
    struct MenuItem {
        var title: String
        var image: UIImage?
    }
    
    struct MenuSection {
        var title = ""
        var items = [SettingItem]()
    }
    
    var settingData = [MenuSection]()

    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        settingData = [MenuSection(title: "", items: settingsItems), MenuSection(title: "", items: privacyItems), MenuSection(title: "", items: otherItems)]
        tableView.register(UINib(nibName: MenuHeaderView.name, bundle: nil), forHeaderFooterViewReuseIdentifier: MenuHeaderView.name)
        tableView.register(MenuCell.nib, forCellReuseIdentifier: MenuCell.identifier)
        tableView.register(SettingsLogoCell.nib, forCellReuseIdentifier: SettingsLogoCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func showDeleteAccount() {
        self.parent?.showConfirmationAlert(title: "Delete Account", description: "Are you sure, you want to delete your account? this will permanently erase your account.", buttonTitle: "Delete", style: .destructive, alertStyle: .alert, onConfirm: {
            self.deleteUserAccount()
        }, onCancel: {
            print("Cancelled")
        })
    }
    
    private func deleteUserAccount() {
        self.parent?.startLoading(title: "")
        APIManager.social.deleteUserAccount(url: Routes.deleteUser.url()!, completion: { error in
            self.parent?.stopLoading()
            if  error == nil  {
                Keychain.shared.clear()
                Cache.shared.clear()
                Application.shared.switchToLogin()
            } else {
                self.parent?.showErrorWith(message: error!.message)
            }
        })
            
            
       
    }
    
}


// MARK: - Utility Methods
extension SettingsAdapter {

    func moveToNotificationSettingsVC() {
        let navC = parent?.navigationController
        let controller = NotificationsSettingsController()
        navC?.pushViewController(controller, animated: true)
    }
    
    func moveToPasswordSettingsVC() {
        let navC = parent?.navigationController
        let controller = ChangePasswordController()
        navC?.pushViewController(controller, animated: true)
    }
    
    func moveToInviteFriendVC() {
        let navC = parent?.navigationController
        let controller = InviteFriendsController()
        controller.isLoggedIn = true
        navC?.pushViewController(controller, animated: true)
    }
    
    func moveToPostVC() {
        let navC = parent?.navigationController
        let controller = PostSettingsController()
        navC?.pushViewController(controller, animated: true)
    }
    
    func moveToBlockFriendVC() {
        let navC = parent?.navigationController
        let controller = BlockListController()
        navC?.pushViewController(controller, animated: true)
    }
    
    func moveToPrivacyPolicyVC() {
        let navC = parent?.navigationController
        let controller = PrivacyPolicyController { _ in
            
        }
        navC?.pushViewController(controller, animated: true)
    }
}


// MARK: - TableView DataSource and Delegates
extension SettingsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < settingData.count {
            return settingData[section].items.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < settingData.count {
            return 60
        }
        return 95
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < settingData.count {
            if settingData[section].title.count > 0 {
                return 50
            }
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < settingData.count {
            if settingData[section].title.count > 0 {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MenuHeaderView.name) as! MenuHeaderView
                view.lblTitle.text = settingData[section].title
                return view
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < settingData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.identifier, for: indexPath) as! MenuCell
            cell.contentView.backgroundColor = UIColor.white
            cell.lblTitle.text = settingData[indexPath.section].items[indexPath.row].title
            cell.imgLogo.image = settingData[indexPath.section].items[indexPath.row].image
            if(indexPath.section != 1) {
                cell.switch.isHidden =  indexPath.row != 1
            }
            cell.imgRightArrow.isHidden = indexPath.row == 1
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLogoCell.identifier, for: indexPath) as! SettingsLogoCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > settingData.count - 1 {
            return
        }
        
        let item = settingData[indexPath.section].items[indexPath.row]
        
        switch item {
        case .notification:    return moveToNotificationSettingsVC()
        case .location:
            let cell = tableView.cellForRow(at: indexPath) as? MenuCell
            cell?.switch.setOn(cell?.switch.isOn == true ? false : true, animated: true)
        case .password:       return moveToPasswordSettingsVC()
        case .invitefriend:    return moveToInviteFriendVC()
        case .post:       return moveToPostVC()
        case .block:     return moveToBlockFriendVC()
        case .privacyPolicy:      return moveToPrivacyPolicyVC()
        case .deleteAccount:     return showDeleteAccount()
       
        }
    }
    

}
