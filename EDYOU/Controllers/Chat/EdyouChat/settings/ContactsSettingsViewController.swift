//
// ContactsSettingsViewController.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class ContactsSettingsViewController: UITableViewController {
    
    let tree: [[SettingsEnum]] = [
        [SettingsEnum.rosterType, SettingsEnum.rosterDisplayHiddenGroup],
        [SettingsEnum.autoSubscribeOnAcceptedSubscriptionRequest, .blockedContacts],
        ];
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tree.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree[section].count;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Display", comment: "section label");
        case 1:
            return NSLocalizedString("General", comment: "section label");
        default:
            return nil;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = tree[indexPath.section][indexPath.row];
        switch setting {
        case .rosterType:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RosterTypeTableViewCell", for: indexPath ) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$rosterType.map({ $0 == .grouped ? true : false }).eraseToAnyPublisher());
                cell.sink(map: { $0 ? .grouped : .flat }, to: \.rosterType, on: Settings);
            })
            return cell;
        case .rosterDisplayHiddenGroup:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RosterHiddenGroupTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$rosterDisplayHiddenGroup);
                cell.sink(to: \.rosterDisplayHiddenGroup, on: Settings);
            })
            return cell;
        case .autoSubscribeOnAcceptedSubscriptionRequest:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoSubscribeOnAcceptedSubscriptionRequestTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$autoSubscribeOnAcceptedSubscriptionRequest);
                cell.sink(to: \.autoSubscribeOnAcceptedSubscriptionRequest, on: Settings);
            });
            return cell;
        case .blockedContacts:
            return tableView.dequeueReusableCell(withIdentifier: "BlockedContactsTableViewCell", for: indexPath);
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    internal enum SettingsEnum: Int {
        case rosterType = 0
        case rosterDisplayHiddenGroup = 1
        case autoSubscribeOnAcceptedSubscriptionRequest = 2
        case blockedContacts = 3
    }
}

