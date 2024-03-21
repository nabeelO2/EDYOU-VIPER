//
// VCardManager.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

class VCardManager {
    
    public static let instance = VCardManager();
    
    open func retrieveVCard(for jid: BareJID, on account: BareJID, completionHandler: @escaping (Result<VCard,XMPPError>)->Void) {
        self.retrieveVCard(for: JID(jid), on: account, completionHandler: completionHandler);
    }
    
    open func retrieveVCard(for jid: JID, on account: BareJID, completionHandler: @escaping (Result<VCard,XMPPError>)->Void) {
        guard let client = XmppService.instance.getClient(for: account) else {
            completionHandler(.failure(.undefined_condition));
            return;
        }
        
        let queryJid = jid.bareJid == account ? nil : jid;
        
        self.retrieveVCard(module: client.module(.vcard4), for: queryJid, on: account) { (result) in
            switch result {
            case .success(let vcard):
                completionHandler(.success(vcard));
            case .failure(_):
                self.retrieveVCard(module: client.module(.vcardTemp), for: queryJid, on: account, completionHandler: completionHandler);
            }
        }
    }
    
    open func refreshVCard(for jid: BareJID, on account: BareJID, completionHandler: ((Result<VCard,XMPPError>)->Void)?) {
        retrieveVCard(for: jid, on: account, completionHandler: { result in
            switch result {
            case .success(let vcard):
                DBVCardStore.instance.updateVCard(for: jid, on: account, vcard: vcard);
            default:
                break;
            }
            completionHandler?(result);
        })
    }
    
    fileprivate func retrieveVCard(module: VCardModuleProtocol, for jid: JID?, on account: BareJID, completionHandler: @escaping (Result<VCard,XMPPError>)->Void) {
        module.retrieveVCard(from: jid, completionHandler: completionHandler);
    }
    
    open func fetchPhoto(photo: VCard.Photo, completionHandler: @escaping (Result<Data,Error>)->Void) {
        if let binval = photo.binval {
            guard let data = Data(base64Encoded: binval, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                completionHandler(.failure(XMPPError.not_acceptable("Unable to decode base64 data")));
                return;
            }
            completionHandler(.success(data));
        } else if let uri = photo.uri {
            if uri.hasPrefix("data:image") && uri.contains(";base64,") {
                guard let idx = uri.firstIndex(of: ","), let data = Data(base64Encoded: String(uri.suffix(from: uri.index(after: idx))), options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                    completionHandler(.failure(XMPPError.not_acceptable("Unable to decode image URI")));
                    return;
                }
                completionHandler(.success(data));
            } else if let url = URL(string: uri) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
                    if let error = err {
                        completionHandler(.failure(error));
                    } else {
                        completionHandler(.success(data!));
                    }
                };
                task.resume();
            }
        } else {
            completionHandler(.failure(XMPPError.item_not_found));
        }
    }
}
