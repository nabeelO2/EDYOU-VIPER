//
//  NotificationSubSettingsController.swift
//  EDYOU
//
//  Created by Ali Pasha on 07/12/2022.
//

import UIKit

class NotificationSubSettingsController: BaseController {
    var notificationSettings: NotificationSettings
    var notificationSettingData : NotificationsSettingData?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationSettings()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Initilier
    init(settings: NotificationSettings, data: NotificationsSettingData?) {
        self.notificationSettings = settings
        self.notificationSettingData = data
        super.init(nibName: NotificationSubSettingsController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI()
    {
        notificationSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        pushSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        emailSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
       
        headerLabel.text = notificationSettings.title.capitalized
        
        switch notificationSettings
        {
        case .chat:
            pushSwitch.isOn = notificationSettingData?.chatPush ?? false
            emailSwitch.isOn = notificationSettingData?.chatEmail ?? false
            
        case .comments:
            pushSwitch.isOn = notificationSettingData?.commentPush ?? false
            emailSwitch.isOn = notificationSettingData?.commentEmail ?? false
        case .tags:
            pushSwitch.isOn = notificationSettingData?.tagsPush ?? false
            emailSwitch.isOn = notificationSettingData?.tagsEmail ?? false
        case .friendUpdates:
            pushSwitch.isOn = notificationSettingData?.friendUpdatePush ?? false
            emailSwitch.isOn = notificationSettingData?.friendUpdateEmail ?? false
        case .friendRequests:
            pushSwitch.isOn = notificationSettingData?.friendRequestPush ?? false
            emailSwitch.isOn = notificationSettingData?.friendRequestEmail ?? false
        case .birthday:
            pushSwitch.isOn = notificationSettingData?.remindersPush ?? false
            emailSwitch.isOn = notificationSettingData?.remindersEmail ?? false
        case .group:
            pushSwitch.isOn = notificationSettingData?.groupsPush ?? false
            emailSwitch.isOn = notificationSettingData?.groupsEmail ?? false
        case .event:
            pushSwitch.isOn = notificationSettingData?.eventPush ?? false
            emailSwitch.isOn = notificationSettingData?.eventEmail ?? false
        case .marketplace:
            pushSwitch.isOn = notificationSettingData?.marketPlacePush ?? false
            emailSwitch.isOn = notificationSettingData?.marketPlaceEmail ?? false
        case .other:
            pushSwitch.isOn = notificationSettingData?.videoPush ?? false
            emailSwitch.isOn = notificationSettingData?.videoEmail ?? false
        }
    }
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateNotificationSettings(paramters: [String : Any])
    {
        APIManager.social.updateNotificationSettings(parameters: paramters, id:  "", completion: { [weak self] settings, error in
            guard let self = self else { return }
            if error == nil {
                self.getNotificationSettings()
                
            } else {
                self.showErrorWith(message: error!.message)
            }
        })
    }
    
    @IBAction func notifcationSwitchUpdated(_ sender: Any) {
        
    }
    
    // MARK: - API
    func getNotificationSettings()
    {
        //self.startLoading(title: "")
        APIManager.social.getNotificationSettings { [weak self] settings, error in
            guard let self = self else { return }
            if error == nil {
                self.notificationSettingData = settings
                self.setupUI()

            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    @IBAction func pushSwitchUpdated(_ sender: Any) {
            switch notificationSettings
            {
            case .chat:
                  updateNotificationSettings(paramters: ["chat_push_enabled": pushSwitch.isOn, "chat_email_enabled": emailSwitch.isOn])
            case .comments:
                  updateNotificationSettings(paramters: ["comments_push_enabled": pushSwitch.isOn, "comments_email_enabled": emailSwitch.isOn])
            case .tags:
                 updateNotificationSettings(paramters: ["tags_email_enabled": emailSwitch.isOn, "tags_push_enabled": pushSwitch.isOn])
            case .friendUpdates:
                 updateNotificationSettings(paramters: ["update_from_friends_email_enabled": emailSwitch.isOn,"update_from_friends_push_enabled": pushSwitch.isOn])
            case .friendRequests:
                updateNotificationSettings(paramters: ["friend_request_email_enabled": emailSwitch.isOn,"friend_request_push_enabled": pushSwitch.isOn])
            case .birthday:
                updateNotificationSettings(paramters: ["reminders_email_enabled": emailSwitch.isOn,"reminders_push_enabled": pushSwitch.isOn])
            case .group:
                updateNotificationSettings(paramters: ["groups_email_enabled": emailSwitch.isOn,"groups_push_enabled": pushSwitch.isOn])
            case .event:
                updateNotificationSettings(paramters: ["event_email_enabled": emailSwitch.isOn,"event_push_enabled": pushSwitch.isOn])
            case .marketplace:
                updateNotificationSettings(paramters: ["marketplace_email_enabled": pushSwitch.isOn,"marketplace_push_enabled": pushSwitch.isOn])
            case .other:
                updateNotificationSettings(paramters: ["video_email_enabled": pushSwitch.isOn, "video_push_enabled": pushSwitch.isOn])
            }
    }
    @IBAction func emailSwitchUpdated(_ sender: Any) {
        switch notificationSettings
        {
        case .chat:
              updateNotificationSettings(paramters: ["chat_email_enabled": emailSwitch.isOn, "chat_push_enabled": pushSwitch.isOn])
        case .comments:
              updateNotificationSettings(paramters: ["comments_push_enabled": pushSwitch.isOn, "comments_email_enabled": emailSwitch.isOn])
        case .tags:
             updateNotificationSettings(paramters: ["tags_email_enabled": emailSwitch.isOn, "tags_push_enabled": pushSwitch.isOn])
        case .friendUpdates:
             updateNotificationSettings(paramters: ["update_from_friends_email_enabled": emailSwitch.isOn,"update_from_friends_push_enabled": pushSwitch.isOn])
        case .friendRequests:
            updateNotificationSettings(paramters: ["friend_request_email_enabled": emailSwitch.isOn,"friend_request_push_enabled": pushSwitch.isOn])
        case .birthday:
            updateNotificationSettings(paramters: ["reminders_email_enabled": emailSwitch.isOn,"reminders_push_enabled": pushSwitch.isOn])
        case .group:
            updateNotificationSettings(paramters: ["groups_email_enabled": emailSwitch.isOn,"groups_push_enabled": pushSwitch.isOn])
        case .event:
            updateNotificationSettings(paramters: ["event_email_enabled": emailSwitch.isOn,"event_push_enabled": pushSwitch.isOn])
        case .marketplace:
            updateNotificationSettings(paramters: ["marketplace_email_enabled": pushSwitch.isOn,"marketplace_push_enabled": pushSwitch.isOn])
        case .other:
            updateNotificationSettings(paramters: ["video_email_enabled": pushSwitch.isOn, "video_push_enabled": pushSwitch.isOn])
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
