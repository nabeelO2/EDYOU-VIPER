//
// PresenceRosterEventHandler.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import Combine

class PresenceRosterEventHandler: XmppServiceExtension {
    
    public static let instance = PresenceRosterEventHandler();
    
    private init() {
    }
    
    func register(for client: XMPPClient, cancellables: inout Set<AnyCancellable>) {
        XmppService.instance.expectedStatus.sink(receiveValue: { [weak client] status in
            if let presenceModule = client?.module(.presence) {
                presenceModule.initialPresence = status.sendInitialPresence;
                if status.sendInitialPresence {
                    presenceModule.setPresence(show: status.show, status: status.message, priority: nil);
                }
            }
        }).store(in: &cancellables);
        client.module(.presence).subscriptionPublisher.sink(receiveValue: { [weak client] change in
            guard let client = client else {
                return;
            }
            switch change.action {
            case .subscribe:
                InvitationManager.instance.addPresenceSubscribe(for: client.userBareJid, from: change.jid);
            default:
                break;
            }
        }).store(in: &cancellables);
    }
        
}
