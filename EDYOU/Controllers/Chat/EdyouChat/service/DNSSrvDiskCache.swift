//
// DnsSrvDiskCache.swift
//
// EdYou
// Copyright (C) 2018 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import Combine

open class DNSSrvDiskCache: DNSSrvResolverWithCache.DiskCache {
    
    private var cancellable: AnyCancellable?;
    
    public override init(cacheDirectoryName: String) {
        super.init(cacheDirectoryName: cacheDirectoryName);
        self.cancellable = AccountManager.accountEventsPublisher.sink(receiveValue: { event in
            switch event {
            case .disabled(let account), .removed(let account):
                self.store(for: account.name.domain, result: nil);
            case .enabled(_):
                break;
            }
        });
    }
    
    @objc fileprivate func accountChanged(_ notification: Notification) {
        guard let account = notification.object as? AccountManager.Account else {
            return;
        }
        guard !(AccountManager.getAccount(for: account.name)?.active ?? false) else {
            return;
        }
        
        self.store(for: account.name.domain, result: nil);
    }
}
