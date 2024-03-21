//
//  NotificationSettings.swift
//  EDYOU
//
//  Created by Ali Pasha on 07/12/2022.
//

import Foundation

struct NotificationsSettings : Codable {
    let status_code : Int?
    let success : Bool?
    let detail : String?
    let data : NotificationsSettingData?

    enum CodingKeys: String, CodingKey {

        case status_code = "status_code"
        case success = "success"
        case detail = "detail"
        case data = "data"
    }

//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        status_code = try values.decodeIfPresent(Int.self, forKey: .status_code)
//        success = try values.decodeIfPresent(Bool.self, forKey: .success)
//        detail = try values.decodeIfPresent(String.self, forKey: .detail)
//        data = try values.decodeIfPresent([NotificationsSettingData].self, forKey: .data)
//    }
}

struct NotificationsSettingData : Codable
{
    let notificationID : String?
    let userID : String?
    let createdAt : String?
    let updatedAt : String?
    let chatPush : Bool?
    let chatSms : Bool?
    let chatEmail : Bool?
    let commentPush : Bool?
    let commentSms : Bool?
    let commentEmail : Bool?
    let tagsPush : Bool?
    let tagsSms : Bool?
    let tagsEmail : Bool?
    let remindersPush : Bool?
    let remindersSms : Bool?
    let remindersEmail : Bool?
    let friendUpdatePush : Bool?
    let friendUpdateSms : Bool?
    let friendUpdateEmail : Bool?
    let friendRequestPush : Bool?
    let friendRequestSms : Bool?
    let friendRequestEmail : Bool?
    let groupsPush : Bool?
    let groupsSms : Bool?
    let groupsEmail : Bool?
    let videoPush : Bool?
    let videoSms : Bool?
    let videoEmail : Bool?
    let eventPush : Bool?
    let eventSms : Bool?
    let eventEmail : Bool?
    let marketPlacePush : Bool?
    let marketPlaceSms : Bool?
    let marketPlaceEmail : Bool?
    let vibrateSetting : Bool?
    let phoneLedSetting : Bool?
    let soundSetting : Bool?
    let settingTone : String?
    let logoutSetting : Bool?
    
    enum CodingKeys: String, CodingKey {

        case notificationID = "notification_settings_id"
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case chatPush = "chat_push_enabled"
        case chatSms = "chat_sms_enabled"
        case chatEmail = "chat_email_enabled"
        case commentPush = "comments_push_enabled"
        case commentSms = "comments_sms_enabled"
        case commentEmail = "comments_email_enabled"
        case tagsPush = "tags_push_enabled"
        case tagsSms = "tags_sms_enabled"
        case tagsEmail = "tags_email_enabled"
        case remindersPush = "reminders_push_enabled"
        case remindersSms = "reminders_sms_enabled"
        case remindersEmail = "reminders_email_enabled"
        case friendUpdatePush = "update_from_friends_push_enabled"
        case friendUpdateSms = "update_from_friends_sms_enabled"
        case friendUpdateEmail = "update_from_friends_email_enabled"
        case friendRequestPush = "friend_request_push_enabled"
        case friendRequestSms = "friend_request_sms_enabled"
        case friendRequestEmail = "friend_request_email_enabled"
        case groupsPush = "groups_push_enabled"
        case groupsSms = "groups_sms_enabled"
        case groupsEmail = "groups_email_enabled"
        case videoPush = "video_push_enabled"
        case videoSms = "video_sms_enabled"
        case videoEmail = "video_email_enabled"
        case eventPush = "event_push_enabled"
        case eventSms = "event_sms_enabled"
        case eventEmail = "event_email_enabled"
        case marketPlacePush = "marketplace_push_enabled"
        case marketPlaceSms = "marketplace_sms_enabled"
        case marketPlaceEmail = "marketplace_email_enabled"
        case vibrateSetting = "push_receive_method_vibrate"
        case phoneLedSetting = "push_receive_method_phone_led"
        case soundSetting = "push_receive_method_sounds"
        case settingTone = "push_receive_method_tone"
        case logoutSetting = "push_receive_method_logged_out"
    }

    
}
