//
// ChannelSelectNewOwnerViewController.swift
//
// EdYou
// Copyright (C) 2022 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class ChannelSelectNewOwnerViewController: UITableViewController {
    
    @IBOutlet var confirmBtn: UIBarButtonItem!;
    
    var participants: [MixParticipant] = [];
    var channel: Channel! = nil;
    
    var selected: MixParticipant? {
        didSet {
            confirmBtn.isEnabled = selected != nil;
        }
    }
    
    var completionHandler: ((MixParticipant?)->Void)?;
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true);
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        completionHandler?(selected);
        self.navigationController?.dismiss(animated: true);
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelParticipantTableViewCell", for: indexPath) as! ChannelParticipantTableViewCell;
        
        cell.set(participant: participants[indexPath.row], in: channel);
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = participants[indexPath.row];
    }
    
}
