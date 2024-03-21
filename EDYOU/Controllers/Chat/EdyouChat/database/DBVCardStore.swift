//
// DBVCardStore.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin
import TigaseSQLite3

extension Query {

    static let vcardInsert = Query("INSERT INTO vcards_cache (jid, data, timestamp) VALUES (:jid,:data,:timestamp)");
    static let vcardUpdate = Query("UPDATE vcards_cache SET data = :data, timestamp = :timestamp WHERE jid = :jid");
    static let vcardFindByJid = Query("SELECT data FROM vcards_cache WHERE jid = :jid");
    
}

class DBVCardStore {
    
    public static let VCARD_UPDATED = Notification.Name("vcardUpdated");
    public static let instance = DBVCardStore();
    
    private let dispatcher = QueueDispatcher(label: "vcard_store");
        
    private init() {
        
    }
    
    open func vcard(for jid: BareJID, completionHandler: @escaping (VCard?)->Void) {
        dispatcher.async {
            let data: String? = try! Database.main.reader({ database in
                try database.select(query: .vcardFindByJid, params: ["jid": jid]).mapFirst({ cursor -> String? in
                    return cursor.string(for: "data");
                })
            });
            
            guard let value = data, let elem = Element.from(string: value) else {
                completionHandler(nil);
                return;
            }
            completionHandler(VCard(vcard4: elem) ?? VCard(vcardTemp: elem));
        }
    }
    
    open func updateVCard(for jid: BareJID, on account: BareJID, vcard: VCard) {
        dispatcher.async {
            try! Database.main.writer({ database in
                let params: [String: Any?] = ["jid": jid, "data": vcard.toVCard4(), "timestamp": Date()];
                try database.update(query: .vcardUpdate, params: params);
                if database.changes == 0 {
                    try database.insert(query: .vcardInsert, params: params);
                }
            })
            NotificationCenter.default.post(name: DBVCardStore.VCARD_UPDATED, object: VCardItem(vcard: vcard, for: jid, on: account));
        }
    }
    
    class VCardItem {
        
        let vcard: VCard;
        let account: BareJID;
        let jid: BareJID;
        
        init(vcard: VCard, for jid: BareJID, on account: BareJID) {
            self.vcard = vcard;
            self.jid = jid;
            self.account = account;
        }
    }
    
}
