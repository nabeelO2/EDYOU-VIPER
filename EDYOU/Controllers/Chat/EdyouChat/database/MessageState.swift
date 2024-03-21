//
// MessageState.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation

public enum MessageState: Int {

    // x % 2 == 0 - incoming
    // x % 2 == 1 - outgoing
    case incoming = 0
    case outgoing = 1

    case incoming_unread = 2
    case outgoing_unsent = 3

    case incoming_error = 4
    case outgoing_error = 5

    case incoming_error_unread = 6
    case outgoing_error_unread = 7

    case outgoing_delivered = 9
    case outgoing_read = 11

    var direction: MessageDirection {
        switch self {
        case .incoming, .incoming_unread, .incoming_error, .incoming_error_unread:
            return .incoming;
        case .outgoing, .outgoing_unsent, .outgoing_delivered, .outgoing_read, .outgoing_error_unread, .outgoing_error:
            return .outgoing;
        }
    }

    var isError: Bool {
        switch self {
        case .incoming_error, .incoming_error_unread, .outgoing_error, .outgoing_error_unread:
            return true;
        default:
            return false;
        }
    }

    var isUnread: Bool {
        switch self {
        case .incoming_unread, .incoming_error_unread, .outgoing_error_unread:
            return true;
        default:
            return false;
        }
    }

}

public enum MessageDirection: Int {
    case incoming = 0
    case outgoing = 1
}
