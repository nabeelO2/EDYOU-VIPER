//
// NewFeaturesDetector.swift
//
// EdYou
// Copyright (C) 2018 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
import Combine

enum ServerFeature: String {
    case mam
    case push
    
    public static func from(info: DiscoveryModule.DiscoveryInfoResult) -> [ServerFeature] {
        return from(features: info.features);
    }
    
    public static func from(features: [String]) -> [ServerFeature] {
        var serverFeatures: [ServerFeature] = [];
        if features.contains(MessageArchiveManagementModule.MAM_XMLNS) || features.contains(MessageArchiveManagementModule.MAM2_XMLNS) {
            serverFeatures.append(.mam);
        }
        if features.contains(PushNotificationsModule.PUSH_NOTIFICATIONS_XMLNS) {
            serverFeatures.append(.push);
        }
        return serverFeatures;
    }
}

class NewFeaturesDetector: XmppServiceExtension {
    
    public static let instance = NewFeaturesDetector();
    
    private init() {}
    
    private struct QueueItem {
        let account: BareJID;
        let newFeatures: [ServerFeature];
        let features: [ServerFeature];
    }
    
    private let queue = DispatchQueue(label: "NewFeaturesDetector");
    private var actionsQueue: [QueueItem] = [];
    private var inProgress: Bool = false;
        
    func register(for client: XMPPClient, cancellables: inout Set<AnyCancellable>) {
        let account = client.userBareJid;
        client.module(.disco).$accountDiscoResult.receive(on: queue).filter({ !$0.features.isEmpty }).map({ ServerFeature.from(info: $0) }).sink(receiveValue: { [weak self] newFeatures in
            self?.newFeatures(newFeatures, for: account);
        }).store(in: &cancellables);
        client.module(.disco).$accountDiscoResult.receive(on: queue).filter({ $0.features.isEmpty && $0.identities.isEmpty }).sink(receiveValue: { [weak self] _ in
            self?.removeFeatures(for: account);
        }).store(in: &cancellables);
    }
    
    private func newFeatures(_ newFeatures: [ServerFeature], for account: BareJID) {
        let oldFeatures = AccountSettings.knownServerFeatures(for: account);
        let change = newFeatures.filter({ !oldFeatures.contains($0) });
        
        guard !change.isEmpty else {
            return;
        }

        self.removeFeatures(for: account);
        actionsQueue.append(.init(account: account, newFeatures: change, features: newFeatures));
        showNext();
    }
    
    private func removeFeatures(for account: BareJID) {
        actionsQueue.removeAll(where: { $0.account == account});
    }
    
    private var navController: UINavigationController?;
    
    func showNext(fromController: Bool = false) {
        DispatchQueue.main.async {
            guard UIApplication.shared.applicationState == .active else {
                self.navController?.dismiss(animated: true, completion: nil);
                self.navController = nil;
                return;
            }

            guard let item: QueueItem = self.queue.sync(execute: {
                guard !self.inProgress || fromController else {
                    return nil;
                }

                let it = self.actionsQueue.first;
                if it != nil {
                    self.actionsQueue.remove(at: 0);
                    self.inProgress = true;
                }
                return it;
            }) else {
                self.navController?.dismiss(animated: true, completion: nil);
                self.navController = nil;
                return;
            }

            guard let client = XmppService.instance.getClient(for: item.account) else {
                self.queue.sync {
                    self.inProgress = false;
                }
                self.showNext();
                return;
            }

            let next: ()->Void = {
                let group = DispatchGroup();
                let since = Date().addingTimeInterval(-1 * (365 * 3600 * 24));
                DBChatHistorySyncStore.instance.addSyncPeriod(.init(account: client.userBareJid, from: since, after: nil, to: nil));
                MessageEventHandler.syncMessagePeriods(for: client);
                group.enter();
                var errors: [XMPPError] = [];
                client.module(.mam).retrieveSettings(completionHandler: { result in
                    switch result {
                        case .success(let settings):
                            var tmp = settings;
                            tmp.defaultValue = .always ;
                            client.module(.mam).updateSettings(settings: tmp, completionHandler: { result in
                                switch result {
                                    case .success(_):
                                        break;
                                    case .failure(let error):
                                        errors.append(error);
                                }
                                group.leave();
                            })
                        case .failure(let error):
                            errors.append(error);
                            group.leave();
                    }
                })
                group.notify(queue: DispatchQueue.main, execute: {
                    AccountSettings.knownServerFeatures(for: item.account, value: item.features);
                })
            }

            if item.newFeatures.contains(.push) && Settings.enablePush == nil {
                Settings.enablePush = true;
                if item.newFeatures.count == 1 {
                    self.showNext(fromController: true)
                } else {
                    next()
                }
            } else {
                next();
            }
        }
    }
    
}
