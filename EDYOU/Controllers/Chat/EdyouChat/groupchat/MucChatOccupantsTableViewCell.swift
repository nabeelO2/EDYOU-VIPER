//
// MucChatOccupantsTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
import Combine

class MucChatOccupantsTableViewCell: UITableViewCell {


    static func labelViewFont() -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: .subheadline);
        let fontDescription = preferredFont.fontDescriptor.withSymbolicTraits(.traitBold)!;
        return UIFont(descriptor: fontDescription, size: preferredFont.pointSize);
    }
    
    @IBOutlet var avatarStatusView: AvatarStatusView!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor;
        }
        set {
            super.backgroundColor = newValue;
            avatarStatusView?.backgroundColor = newValue;
        }
    }
    
    public static func roleToEmoji(_ role: MucRole) -> String {
        switch role {
        case .none, .visitor:
            return "";
        case .participant:
            return "⭐";
        case .moderator:
            return "🌟";
        }
    }
    
    private var cancellables: Set<AnyCancellable> = [];
    
    private var occupant: MucOccupant? {
        didSet {
            cancellables.removeAll();

            if let occupant = occupant {
//                let nickname = occupant.nickname;
                nicknameLabel.text = occupant.nickname;
                
                occupant.$presence.map({ $0.show }).receive(on: DispatchQueue.main).assign(to: \.status, on: avatarStatusView).store(in: &cancellables);
//                occupant.$presence.map(XMucUserElement.extract(from: )).map({ $0?.role ?? .none }).map({ "\(nickname) \(MucChatOccupantsTableViewCell.roleToEmoji($0))" }).receive(on: DispatchQueue.main).assign(to: \.text, on: nicknameLabel).store(in: &cancellables);
                occupant.$presence.map({ $0.status }).receive(on: DispatchQueue.main).assign(to: \.text, on: statusLabel).store(in: &cancellables);
            }
        }
    }
    private var avatarObj: Avatar? {
        didSet {
            let name = self.nicknameLabel.text;
            avatarObj?.avatarPublisher.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] image in
                self?.avatarStatusView.avatarImageView.set(name: name, avatar: image);
            }).store(in: &cancellables);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func set(occupant: MucOccupant, in room: XMPPRoom) {
        self.occupant = occupant;
        self.avatarObj = occupant.avatar;
    }

}

extension MucOccupant {
        
    var avatar: Avatar? {
        if let room = self.room {
            return AvatarManager.instance.avatarPublisher(for: .init(account: room.account, jid: room.jid, mucNickname: nickname));
        } else {
            return nil;
        }
    }
    
}
