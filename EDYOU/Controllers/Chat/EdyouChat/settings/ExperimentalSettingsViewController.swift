//
// ExperimentalSettingsViewController.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class ExperimentalSettingsViewController: UITableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = SettingsEnum(rawValue: indexPath.row)!;
        switch setting {
        case .notificationsFromUnknown:
            let cell = tableView.dequeueReusableCell(withIdentifier: "XmppPipeliningTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$xmppPipelining);
                cell.sink(to: \.xmppPipelining, on: Settings);
            })
            return cell;
        case .enableBookmarksSync:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnableBookmarksSyncTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$enableBookmarksSync);
                cell.sink(to: \.enableBookmarksSync, on: Settings);
            })
            return cell;
        case .enableMarkdown:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnableMarkdownTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$enableMarkdownFormatting);
                cell.sink(to: \.enableMarkdownFormatting, on: Settings);
            })
            return cell;
        case .showEmoticons:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnableEmoticonsTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$showEmoticons);
                cell.sink(to: \.showEmoticons, on: Settings);
            })
            return cell;
        case .usePublicStunServers:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublicStunServersTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$usePublicStunServers);
                cell.sink(to: \.usePublicStunServers, on: Settings);
            })
            return cell;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    internal enum SettingsEnum: Int {
        case notificationsFromUnknown = 0
        case enableBookmarksSync = 1
        case enableMarkdown = 2
        case showEmoticons = 3
        case usePublicStunServers = 4
    }
}
