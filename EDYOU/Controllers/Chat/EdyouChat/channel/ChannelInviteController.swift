//
// ChannelInviteController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class ChannelInviteController: AbstractRosterViewController {

    var channel: Channel!;
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    @IBAction func addClicked(_ sender: UIBarButtonItem) {
        guard let channel = self.channel, let mixModule = channel.context?.module(.mix) else {
            return;
        }
        guard let items = self.tableView.indexPathsForSelectedRows?.map({ self.roster?.item(at: $0) }).filter({ $0 != nil}).map({ $0! }), !items.isEmpty else {
            return;
        }
        
        let channelJid = channel.channelJid;
        let group = DispatchGroup();
        self.operationStarted(message: NSLocalizedString("Sending invitations…", comment: "channel invitations view operation"));
        for item in items {
            group.enter();
            mixModule.allowAccess(to: channel.channelJid, for: item.jid, completionHandler: { result in
                switch result {
                case .success(_):
                    let body = "Invitation to channel: \(channelJid.stringValue)";
                    let mixInvitation = MixInvitation(inviter: channel.account, invitee: item.jid, channel: channelJid, token: nil);
                    let message = mixModule.createInvitation(mixInvitation, message: body);
                    message.messageDelivery = .request;
                    let conversationKey: ConversationKey = DBChatStore.instance.conversation(for: channel.account, with: item.jid) ?? ConversationKeyItem(account: channel.account, jid: item.jid);
                    let options = ConversationEntry.Options(recipient: .none, encryption: .none, isMarkable: false);
                    DBChatHistoryStore.instance.appendItem(for: conversationKey, state: .outgoing(.sent), sender: .me(conversation: conversationKey), type: .invitation, timestamp: Date(), stanzaId: message.id, serverMsgId: nil, remoteMsgId: nil, data: body, appendix: ChatInvitationAppendix(mixInvitation: mixInvitation), options: options, linkPreviewAction: .none, completionHandler: nil);
                    mixModule.write(message);
                case .failure(_):
                    break;
                }
                group.leave();
            })
        }
        group.notify(queue: DispatchQueue.main, execute: { [weak self] in
            self?.operationEnded();
            self?.navigationController?.popViewController(animated: true);
        })
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath);
        cell?.accessoryType = .checkmark;
        self.selectionChanged();
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath);
        cell?.accessoryType = .none;
        self.selectionChanged();
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelInviteViewCell", for: indexPath);
        if let item = roster?.item(at: indexPath) {
            cell.textLabel?.text = item.displayName;
            cell.detailTextLabel?.text = item.jid.stringValue;
            (cell.imageView as? AvatarView)?.set(name: item.displayName, avatar: AvatarManager.instance.avatar(for: item.jid, on: item.account));
        }
        cell.accessoryType = (tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false) ? .checkmark : .none;
        return cell;
    }

    private func selectionChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = !(self.tableView.indexPathsForSelectedRows?.isEmpty ?? true);
    }
    
    func operationStarted(message: String) {
//        let refreshControl = UIRefreshControl();
//        self.tableView.refreshControl = refreshControl;
//        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: message);
//        self.tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - self.tableView.refreshControl!.frame.height), animated: true)
//        refreshControl.beginRefreshing();
    }
    
    func operationEnded() {
//        self.tableView.refreshControl?.endRefreshing();
//        self.tableView.refreshControl = nil;
    }
}
