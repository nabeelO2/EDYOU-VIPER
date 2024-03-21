//
// RosterProvider.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Shared
import Martin
import Combine

protocol RosterProvider {
    
    func numberOfSections() -> Int;
    
    func numberOfRows(in section: Int) -> Int;
    
    func item(at indexPath: IndexPath) -> RosterProviderItem;
    
    func queryItems(contains: String?);
    
    func sectionHeader(at: Int) -> String?;
    
    func release();
}

public enum RosterSortingOrder: String {
    case alphabetical
    case availability
}

public enum RosterType: String {
    case flat
    case grouped
}

public class RosterProviderAbstract<Item: RosterProviderItem> {
        
    private let dispatcher = QueueDispatcher(label: "RosterProviderDispatcher");
    
    internal weak var controller: AbstractRosterViewController?;
            
    @Published
    internal var allItems: [Item] = [];
    
    @Published
    internal var queryString: String? = nil;
    
    private var cancellables: Set<AnyCancellable> = [];
    
    init(controller: AbstractRosterViewController) {
        self.controller = controller;
        DBRosterStore.instance.$items.combineLatest(Settings.$rosterAvailableOnly, PresenceStore.instance.$bestPresences, Settings.$rosterDisplayHiddenGroup).throttle(for: 0.1, scheduler: dispatcher.queue, latest: true).sink(receiveValue: { [weak self] items, available, presences, displayHidden in
            self?.updateItems(items: Array(items), presences: presences, available: available, displayHidden: displayHidden);
        }).store(in: &cancellables);
        self.$allItems.drop(while: { $0.isEmpty }).combineLatest(self.$queryString).map({ items, query in
            if let query = query, !query.isEmpty {
                return items.filter({ $0.displayName.lowercased().contains(query) || $0.jid.stringValue.lowercased().contains(query) });
            } else {
                return items;
            }
        }).combineLatest(Settings.$rosterItemsOrder).receive(on: self.dispatcher.queue).sink(receiveValue: { [weak self] (items, order) in
            self?.updateItems(items: items, order: order)
        }).store(in: &cancellables);
    }
    
    func release() {
        controller = nil;
        cancellables.removeAll();
    }
    
    func updateItems(items: [RosterItem], presences: [PresenceStore.Key: Presence], available: Bool, displayHidden: Bool) {
        var newItems = items.compactMap({ item -> Item? in
            guard let account = item.context?.userBareJid else {
                return nil;
            }
            guard !item.annotations.contains(where: { $0.type == "mix" }) else {
                return nil;
            }
            if !displayHidden {
                if item.groups.contains("Hidden") {
                    return nil;
                }
            }
            return self.newItem(rosterItem: item, account: account, presence: presences[.init(account: account, jid: item.jid.bareJid)]);
        });
        if available {
            newItems = newItems.filter({ $0.presence != nil });
        }
                            
        self.allItems = newItems;
    }
    
    func newItem(rosterItem item: RosterItem, account: BareJID, presence: Presence?) -> Item? {
        return nil;
    }
    
    func updateItems(items: [Item], order: RosterSortingOrder) {
        
    }
     
    func sort(items: [Item], order: RosterSortingOrder) -> [Item] {
        switch order {
        case .alphabetical:
            return items.sorted(by: { (i1, i2) in i1.displayName.lowercased() < i2.displayName.lowercased() });
        case .availability:
            return items.sorted { (i1, i2) -> Bool in
                let s1 = i1.presence?.show?.weight ?? 0;
                let s2 = i2.presence?.show?.weight ?? 0;
                if s1 == s2 {
                    return i1.displayName < i2.displayName;
                }
                return s1 > s2;
            };
        }

    }
    

//    func findItemFor(account: BareJID, jid: JID) -> Item? {
//        if let idx = findItemIdxFor(account: account, jid: jid) {
//            return allItems[idx];
//        }
//        return nil;
//    }
//
//    func findItemIdxFor(account: BareJID, jid: JID) -> Int? {
//        let jidWithoutResource = JID(jid.bareJid);
//        return allItems.firstIndex { (item) -> Bool in
//            return item.account == account && (item.jid.resource != nil ? item.jid == jid : item.jid == jidWithoutResource)
//        }
//    }
        
    func queryItems(contains: String?) {
        self.queryString = contains?.lowercased();
    }
    
}

public protocol RosterProviderItem: AnyObject {
    
    var account: BareJID { get }
    var jid: BareJID { get }
    var presence: Presence? { get }
    var displayName: String { get }

}


