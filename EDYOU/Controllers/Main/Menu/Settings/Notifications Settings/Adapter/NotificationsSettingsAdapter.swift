//
//  
//  NotificationsSettingsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//
//

import UIKit

enum NotificationSettings
{
    case chat,
    comments,
    tags,
    friendUpdates,
    friendRequests,
    birthday,
    group,
    event,
    marketplace,
    other
    

    var title: String {
        switch self {
        case .chat:
            return "Chat"
        case .comments:
            return "Comments"
        case .tags:
            return "Tags"
        case .friendUpdates:
            return "Updates from Friends"
        case .friendRequests:
            return "Friend Requests"
        case .birthday:
            return "Birthdays"
        case .group:
            return "Groups"
        case .event:
            return "Events"
        case .marketplace:
            return "Marketplace"
        case .other:
            return "Other Notifications"
        }
    }
    
    var ico: UIImage? {
        switch self {
        case .chat:
            return UIImage(named: "tab_chat_icon")
        case .comments:
            return UIImage(named: "setting_ico_comments")
        case .tags:
            return UIImage(named: "setting_ico_tag")
        case .friendUpdates:
            return UIImage(named: "setting_ico_friends")
        case .friendRequests:
            return UIImage(named: "setting_ico_requests")
        case .birthday:
            return UIImage(named: "setting_ico_birthdays")
        case .group:
            return UIImage(named: "setting_ico_groups")
        case .event:
            return UIImage(named: "setting_ico_events")
        case .marketplace:
            return UIImage(named: "setting_ico_market")
        case .other:
            return UIImage(named: "setting_ico_others")
        }
    }
    
//    func isEnabled(data: NotificationsSettingData) -> Bool {
//        switch self {
//        case .chat:
//            return data.chatPush ?? false || data.chatEmail ?? false
//        case .comments:
//            return data.commentPush ?? false || data.commentEmail ?? false
//        case .tags:
//            return data.tagsPush ?? false || data.tagsEmail ?? false
//        case .friendUpdates:
//            return data.friendUpdatePush ?? false || data.friendRequestEmail ?? false
//        case .friendRequests:
//            return data.friendRequestPush ?? false || data.friendRequestEmail ?? false
//        case .birthday:
//            return data.remindersPush ?? false || data.remindersEmail ?? false
//        case .group:
//            return data.groupsPush ?? false || data.groupsEmail ?? false
//        case .event:
//            return data.eventPush ?? false || data.eventEmail ?? false
//        case .marketplace:
//            return data.marketPlacePush ?? false || data.marketPlaceEmail ?? false
//        case .other:
//            return data.videoPush ?? false || data.videoEmail ?? false
//        }
//    }
    
    func isEnabled(data: NotificationsSettingData) -> Bool {
        switch self {
        case .chat:
            return data.chatPush ?? false
        case .comments:
            return data.commentPush ?? false
        case .tags:
            return data.tagsPush ?? false
        case .friendUpdates:
            return data.friendUpdatePush ?? false
        case .friendRequests:
            return data.friendRequestPush ?? false
        case .birthday:
            return data.remindersPush ?? false
        case .group:
            return data.groupsPush ?? false
        case .event:
            return data.eventPush ?? false
        case .marketplace:
            return data.marketPlacePush ?? false
        case .other:
            return data.videoPush ?? false
        }
    }
    
    
}
class NotificationsSettingsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var notificationSetting : NotificationsSettingData?
    var parent: NotificationsSettingsController? {
        return tableView.viewContainingController() as? NotificationsSettingsController
    }
    var settings : [NotificationSettings] = [.chat, .comments, .tags, .friendUpdates, .friendRequests, .birthday, .group, .event, .marketplace, .other]
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(NotificationSettingsDescriptionCell.nib, forCellReuseIdentifier: NotificationSettingsDescriptionCell.identifier)
        tableView.register(NotificationSettingsCell.nib, forCellReuseIdentifier: NotificationSettingsCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - Notification Cell Delegate
extension NotificationsSettingsAdapter : NotificationSettingsCellDelegate {
    func updateSettings(setting: NotificationSettings, isEnabled: Bool) {
       // var value = isEnabled ? true : false
        var dictionary: [String: Any] = ["chat_push_enabled": notificationSetting?.chatPush ?? true,
                                         "chat_sms_enabled": notificationSetting?.chatSms ?? true,
                                         "chat_email_enabled": notificationSetting?.chatEmail ?? true,
                                         "comments_push_enabled": notificationSetting?.commentPush ?? true,
                                         "comments_sms_enabled": notificationSetting?.commentSms ?? true,
                                         "comments_email_enabled": notificationSetting?.commentEmail ?? true,
                                         "tags_push_enabled": notificationSetting?.tagsPush ?? true,
                                         "tags_sms_enabled": notificationSetting?.tagsSms ?? true,
                                         "tags_email_enabled": notificationSetting?.tagsEmail ?? true,
                                         "reminders_push_enabled": notificationSetting?.remindersPush ?? true,
                                         "reminders_sms_enabled": notificationSetting?.remindersSms ?? true,
                                         "reminders_email_enabled": notificationSetting?.remindersSms ?? true,
                                         "update_from_friends_push_enabled": notificationSetting?.friendUpdatePush ?? true,
                                         "update_from_friends_sms_enabled": notificationSetting?.friendUpdateSms ?? true,
                                         "update_from_friends_email_enabled": notificationSetting?.friendUpdateEmail ??  true,
                                         "friend_request_push_enabled": notificationSetting?.friendRequestPush ?? true,
                                         "friend_request_sms_enabled": notificationSetting?.friendRequestSms ?? true,
                                         "friend_request_email_enabled": notificationSetting?.friendRequestEmail ?? true,
                                         "groups_push_enabled": notificationSetting?.groupsPush ?? true,
                                         "groups_sms_enabled": notificationSetting?.groupsSms ?? true,
                                         "groups_email_enabled": notificationSetting?.groupsEmail ?? true,
                                         "video_push_enabled": notificationSetting?.videoSms ?? true,
                                         "video_sms_enabled": notificationSetting?.videoSms ?? true,
                                         "video_email_enabled": notificationSetting?.videoEmail ?? true,
                                         "event_push_enabled": notificationSetting?.eventPush ?? true,
                                         "event_sms_enabled": notificationSetting?.eventSms ?? true,
                                         "event_email_enabled": notificationSetting?.eventEmail ?? true,
                                         "marketplace_push_enabled": notificationSetting?.marketPlacePush ?? true,
                                         "marketplace_sms_enabled": notificationSetting?.marketPlaceSms ?? true,
                                         "marketplace_email_enabled": notificationSetting?.marketPlaceEmail ?? true,
        "push_receive_method_vibrate": true,
        "push_receive_method_phone_led": true,
        "push_receive_method_sounds": true,
        "push_receive_method_tone": "",
        "push_receive_method_logged_out": true];
     switch setting
     {
        case .chat:
         dictionary["chat_push_enabled"] = isEnabled
         dictionary["chat_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .comments:
         dictionary["comments_push_enabled"] = isEnabled
         dictionary["comments_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .tags:
         dictionary["tags_push_enabled"] = isEnabled
         dictionary["tags_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .friendUpdates:
         dictionary["update_from_friends_push_enabled"] = isEnabled
         dictionary["update_from_friends_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .friendRequests:
         dictionary["friend_request_push_enabled"] = isEnabled
         dictionary["friend_request_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .birthday:
         dictionary["reminders_push_enabled"] = isEnabled
         dictionary["reminders_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .group:
         dictionary["groups_push_enabled"] = isEnabled
         dictionary["groups_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .event:
         dictionary["event_push_enabled"] = isEnabled
         dictionary["event_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .marketplace:
         dictionary["marketplace_push_enabled"] = isEnabled
         dictionary["marketplace_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        case .other:
         dictionary["video_push_enabled"] = isEnabled
         dictionary["video_email_enabled"] = isEnabled
         updateNotificationSettings(paramters: dictionary)
        }
        
    }
   
    func updateNotificationSettings(paramters: [String : Any])
    {
        
        self.parent?.startLoading(title: "")
        APIManager.social.updateNotificationSettings(parameters: paramters, id:  "", completion: { [weak self] settings, error in
            guard let self = self else { return }
            self.parent?.stopLoading()
            if error == nil {
                DispatchQueue.main.async {
                  // self.notificationSetting = settings
                   self.parent?.getNotificationSettings()
                    self.tableView.reloadData()
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.parent?.showErrorWith(message: error!.message)
                    self.tableView.reloadData()
                }
            }
        })
    }
}


// MARK: - TableView DataSource and Delegates
extension NotificationsSettingsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : settings.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 160 : 52
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsDescriptionCell.identifier, for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsCell.identifier, for: indexPath) as! NotificationSettingsCell
        let setting : NotificationSettings = settings[indexPath.row]
        cell.updateUI(title: setting.title, image: setting.ico, setting: setting)
        cell.delegate = self
        guard let data = self.notificationSetting else { return cell }
        cell.switchSetting.isOn = setting.isEnabled(data: data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            let setting : NotificationSettings = settings[indexPath.row]
            let controller = NotificationSubSettingsController(settings: setting, data: notificationSetting)
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
