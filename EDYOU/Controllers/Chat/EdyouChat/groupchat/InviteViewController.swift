//
// InviteViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class InviteViewController: AbstractRosterViewController {

    var room: XMPPRoom!;
    
    var onNext: (([BareJID])->Void)? = nil;
    var selected: [BareJID] = [];
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if onNext != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Create", comment: "button label"), style: .plain, target: self, action: #selector(selectionFinished(_:)))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)));
        }
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc func selectionFinished(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil);
        
        if let onNext = self.onNext {
            self.onNext = nil;
            onNext(selected);
        }
    }
        
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = roster?.item(at: indexPath) else {
            return;
        }
        guard !tableView.allowsMultipleSelection else {
            if selected.contains(item.jid) {
                selected = selected.filter({ (jid) -> Bool in
                    return jid != item.jid;
                });
                tableView.deselectRow(at: indexPath, animated: true);
            } else {
                selected.append(item.jid);
            }
            return;
        }

        room.invite(JID(item.jid), reason: String.localizedStringWithFormat(NSLocalizedString("You are invied to join conversation at %@", comment: "error label"), room.name ?? ""));
        
        self.navigationController?.dismiss(animated: true, completion: nil);
    }
 
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item = roster?.item(at: indexPath) else {
            return;
        }
        selected = selected.filter({ (jid) -> Bool in
            return jid != item.jid;
        });
    }
}
