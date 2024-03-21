//
// ConversationEntryEncryption.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation

public enum ConversationEntryEncryption: Hashable {
    case none
    case decrypted(fingerprint: String?)
    case decryptionFailed(errorCode: Int)
    case notForThisDevice
    
    func message() -> String? {
        switch self {
        case .none, .decrypted(_):
            return nil;
        case .decryptionFailed(let errorCode):
            return String.localizedStringWithFormat(NSLocalizedString("Message decryption failed! Error code: %d", comment: "message encryption failure"), errorCode);
        case .notForThisDevice:
            return NSLocalizedString("Message was not encrypted for this device", comment: "message encryption failure");
        }
    }
    
    var fingerprint: String? {
        switch self {
        case .decrypted(let fingerprint):
            return fingerprint;
        default:
            return nil;
        }
    }
    
    var errorCode: Int? {
        switch self {
        case .decryptionFailed(let errorCode):
            return errorCode;
        default:
            return nil;
        }
    }

    var value: MessageEncryption {
        switch self {
        case .none:
            return .none;
        case .decrypted(_):
            return .decrypted;
        case .decryptionFailed:
            return .decryptionFailed;
        case .notForThisDevice:
            return .notForThisDevice;
        }
    }
    
    public static func == (lhs: ConversationEntryEncryption, rhs: ConversationEntryEncryption) -> Bool {
        return lhs.value == rhs.value;
    }
}
