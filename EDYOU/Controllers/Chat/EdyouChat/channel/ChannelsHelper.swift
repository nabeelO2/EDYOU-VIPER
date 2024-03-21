//
// ChannelsHelper.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

class ChannelsHelper {
    
    static func findChannels(for client: XMPPClient, at components: [Component], completionHandler: @escaping ([DiscoveryModule.Item])->Void) {
        var allItems: [DiscoveryModule.Item] = [];
        let group = DispatchGroup();
        for component in components {
            group.enter();
            client.module(.disco).getItems(for: component.jid, completionHandler: { result in
                 switch result {
                 case .success(let items):
                     DispatchQueue.main.async {
                        allItems.append(contentsOf: items.items);
                     }
                 case .failure(_):
                     break;
                 }
                 group.leave();
             });
        }
        group.notify(queue: DispatchQueue.main, execute: {
            completionHandler(allItems);
        })
    }
    
    static func findComponents(for client: XMPPClient, at domain: String, completionHandler: @escaping ([Component])->Void) {
        let domainJid = JID(domain);
        var components: [Component] = [];
        let group = DispatchGroup();
        group.enter();
        let discoModule = client.module(.disco);
        retrieveComponent(from: domainJid, name: nil, discoModule: discoModule, completionHandler: { result in
            switch result {
            case .success(let component):
                DispatchQueue.main.async {
                    components.append(component);
                }
                group.leave();
            case .failure(_):
                discoModule.getItems(for: domainJid, completionHandler: { result in
                    switch result {
                    case .success(let items):
                        // we need to do disco on all components to find out local mix/muc component..
                        // maybe this should be done once for all "views"?
                        for item in items.items {
                            group.enter();
                            self.retrieveComponent(from: item.jid, name: item.name, discoModule: discoModule, completionHandler: { result in
                                switch result {
                                case .success(let component):
                                    DispatchQueue.main.async {
                                        components.append(component);
                                    }
                                case .failure(_):
                                    break;
                                }
                                group.leave();
                            });
                        }
                    case .failure(_):
                        break;
                    }
                    group.leave();
                });
            }
        })
        
        group.notify(queue: DispatchQueue.main, execute: {
            completionHandler(components);
        })
    }
    
    static func queryChannel(for client: XMPPClient, at components: [Component], name: String, completionHandler: @escaping (Result<[DiscoveryModule.Item],XMPPError>)->Void) {
        var allItems: [DiscoveryModule.Item] = [];
        let group = DispatchGroup();
        let discoModule = client.module(.disco);
        for component in components {
            group.enter();
            let channelJid = JID(BareJID(localPart: name, domain: component.jid.domain));
            discoModule.getInfo(for: channelJid, node: nil, completionHandler: { result in
                 switch result {
                 case .success(let info):
                     DispatchQueue.main.async {
                        allItems.append(DiscoveryModule.Item(jid: channelJid, name: info.identities.first?.name));
                     }
                 case .failure(_):
                     break;
                 }
                 group.leave();
             });
        }
        group.notify(queue: DispatchQueue.main, execute: {
            completionHandler(.success(allItems));
        })
    }
    
    static func retrieveComponent(from jid: JID, name: String?, discoModule: DiscoveryModule, completionHandler: @escaping (Result<Component,XMPPError>)->Void) {
        discoModule.getInfo(for: jid, completionHandler: { result in
            switch result {
            case .success(let info):
                guard let component = Component(jid: jid, name: name, identities: info.identities, features: info.features) else {
                    completionHandler(.failure(.item_not_found));
                    return;
                }
                completionHandler(.success(component));
            case .failure(let errorCondition):
                completionHandler(.failure(errorCondition));
            }
        })

    }
    
    enum ComponentType {
        case muc
        case mix
        
        static func from(identities: [DiscoveryModule.Identity], features: [String]) -> ComponentType? {
            if identities.first(where: { $0.category == "conference" && $0.type == "mix" }) != nil && features.contains(MixModule.CORE_XMLNS) {
                return .mix;
            }
            if identities.first(where: { $0.category == "conference" }) != nil && features.contains("http://jabber.org/protocol/muc") {
                return .muc;
            }
            return nil;
        }
    }
    
    class Component {
        let jid: JID;
        let name: String?;
        let type: ComponentType;
        
        convenience init?(jid: JID, name: String?, identities: [DiscoveryModule.Identity], features: [String]) {
            guard let type = ComponentType.from(identities: identities, features: features) else {
                return nil;
            }
            self.init(jid: jid, name: name ?? identities.first(where: { $0.name != nil})?.name, type: type);
        }
        
        init(jid: JID, name: String?, type: ComponentType) {
            self.jid = jid;
            self.name = name;
            self.type = type;
        }
    }
}
