//
//  SocketManager.swift
//  EDYOU
//
//  Created by  Mac on 13/11/2021.
//



import Foundation
import UIKit
import RealmSwift
import Realm
import AVFoundation
import SwiftUI

var isSocketConnected = false

enum MessageType: String {
    case ping = "ping"
    case send = "send"
    case createRoom = "create_room"
    case deleteRoom = "room_remove"
    case typing = "typing"
    case read = "read"
    case delete = "delete"
    case bye = "bye"
    case addEmoji = "add_emoji"
    case removeEmoji = "remove_emoji"
    case receiveCall = "receive_call"
    case acknowledge = "ack"
    case callEnded = "CALL_ENDED"
    case callError = "CALL_ERROR"
    case callEstablished = "CALL_ESTABLISHED"
    case newCall = "NEW_CALL"
    case endCall = "END_CALL"
    case callStatus = "CALL_STATUS"
    case callRejected = "CALL_REJECTED"
    case audioCall = "audio"
    case videoCall = "video"
    case userDisconnected = "user_disconnected"
    case userConnected = "user_connected"
}


let kNotificationDidReceiveChatMessage = "kNotificationDidReceiveChatMessage"
let kNotificationDidReceiveCall = "kNotificationDidReceiveCall"
let kNotificationDidCreateChatGroup = "kNotificationDidCreateChatGroup"

