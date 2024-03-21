//
// ServerFeaturesViewController.swift
//
// EdYou
// Copyright (C) 2018 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
import Combine

class ServerFeaturesViewController: UITableViewController {

    var client: XMPPClient!;

    private var features: [Feature] = [];

    private var cancellables: Set<AnyCancellable> = [];
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let allFeatures = loadFeatures();
        client.module(.disco).$serverDiscoResult.receive(on: DispatchQueue.main).map({ it -> [Feature] in
            return allFeatures.filter({ $0.matches(it.features) });
        }).sink(receiveValue: { [weak self] features in
            self?.features = features;
            self?.tableView.reloadData();
        }).store(in: &cancellables);
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count;
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StreamFeatureCell", for: indexPath);
        
        let feature = features[indexPath.row];
        cell.textLabel?.text = feature.xep + ": " + feature.name;
        cell.detailTextLabel?.text = feature.description;
        
        return cell;
    }
    
    fileprivate func loadFeatures() -> [Feature] {
        guard let path = Bundle.main.path(forResource: "server_features_list", ofType: "xml") else {
            return [];
        }
        
        guard let str = try? String(contentsOfFile: path) else {
            return [];
        }
        
        guard let parent = Element.from(string: str) else {
            return [];
        }
        
        return parent.mapChildren(transform: Feature.init(from:));
    }
    
    class Feature {
        let id: String?;
        let xep: String;
        let name: String;
        let description: String?;
        
        convenience init?(from el: Element) {
            guard let xep = el.findChild(name: "xep")?.value, let name = el.findChild(name: "name")?.value else {
                return nil;
            }
            self.init(id: el.getAttribute("id"), xep: xep, name: name, description: el.findChild(name: "description")?.value);
        }
        
        init(id: String?, xep: String, name: String, description: String?) {
            self.id = id;
            self.xep = xep;
            self.name = name;
            self.description = description;
        }
        
        func matches(_ features: [String]) -> Bool {
            guard let id = self.id else {
                return false;
            }
            if id.last == "*" {
                let prefix = id.prefix(upTo: id.index(before: (id.endIndex)));
                return features.contains(where: { (feature) -> Bool in
                    return feature.starts(with: prefix);
                })
            }
            return features.contains(id);
        }
    }
}
