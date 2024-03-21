//
// AccountTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import Martin
import Combine

class AccountTableViewCell: UITableViewCell {

    @IBOutlet var avatarStatusView: AvatarStatusView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!;

    private var cancellables: Set<AnyCancellable> = [];
    private var avatarObj: Avatar? {
        didSet {
            avatarObj?.avatarPublisher.receive(on: DispatchQueue.main).assign(to: \.avatar, on: avatarStatusView.avatarImageView).store(in: &cancellables);
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor;
        }
        set {
            super.backgroundColor = newValue;
            avatarStatusView?.backgroundColor = newValue;
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func set(account accountJid: BareJID) {
        cancellables.removeAll();
        avatarObj = AvatarManager.instance.avatarPublisher(for: .init(account: accountJid, jid: accountJid, mucNickname: nil));
        nameLabel.text = accountJid.stringValue;
        if let acc = AccountManager.getAccount(for: accountJid) {
            descriptionLabel.text = acc.nickname;
            if acc.active {
                avatarStatusView.statusImageView.isHidden = false;
                acc.state.map({ value -> Presence.Show? in
                    switch value {
                    case .connected(_):
                        return .online
                    case .connecting, .disconnecting:
                        return .xa
                    default:
                        return nil;
                    }
                }).receive(on: DispatchQueue.main).assign(to: \.status, on: avatarStatusView).store(in: &cancellables);
            } else {
                avatarStatusView.statusImageView.isHidden = true;
            }
        } else {
            avatarStatusView.statusImageView.isHidden = false;
            descriptionLabel.text = nil;
        }
    }
}
