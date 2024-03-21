//
// NotificationCategory.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//

//

import Foundation

public enum XMPPNotificationCategory: String {
    case UNKNOWN
    case ERROR
    case MESSAGE
    case SUBSCRIPTION_REQUEST
    case MUC_ROOM_INVITATION
    case CALL
    case UNSENT_MESSAGES

    public static func from(identifier: String?) -> XMPPNotificationCategory {
        guard let str = identifier else {
            return .UNKNOWN;
        }
        return XMPPNotificationCategory(rawValue: str) ?? .UNKNOWN;
    }
}
