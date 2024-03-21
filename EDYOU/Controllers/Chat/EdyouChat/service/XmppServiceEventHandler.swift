//
// XmppServiceEventHandler.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
import Combine

protocol XmppServiceEventHandler: EventHandler {
    
    var events: [Event] { get }
    
}

protocol XmppServiceExtension {
    
    func register(for client: XMPPClient, cancellables: inout Set<AnyCancellable>);

}
