//
// DisplayableIdProtocol.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//
//

import Foundation
import Martin
import UIKit
import Combine

public protocol DisplayableIdProtocol {
    
    var displayName: String { get }
    var displayNamePublisher: Published<String>.Publisher { get }

    var status: Presence.Show? { get }
    var statusPublisher: Published<Presence.Show?>.Publisher { get }
    
    var avatarPublisher: AnyPublisher<UIImage?,Never> { get }
    
    var description: String? { get }
    var descriptionPublisher: Published<String?>.Publisher { get }
}

public protocol DisplayableIdWithKeyProtocol: DisplayableIdProtocol {
    
    var account: BareJID { get }
    var jid: BareJID { get }
    
}
