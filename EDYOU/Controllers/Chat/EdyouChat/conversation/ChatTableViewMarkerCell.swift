//
// ChatTableViewMarkerCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine

class ChatTableViewMarkerCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!;
    @IBOutlet var avatars: UIStackView!;
    private var cancellables: Set<AnyCancellable> = [];
    
    func set(item: ConversationEntry, type: ChatMarker.MarkerType, senders: [ConversationEntrySender]) {
        cancellables.removeAll();
        
        if item.conversation is Chat {
            self.label?.isHidden = true
            avatars.isHidden = true
            return
        }
        for view in self.avatars.arrangedSubviews {
            view.removeFromSuperview();
        }
        
        for idx in 0..<min(4, senders.count) {
            let view = AvatarView(frame: .init(x: 0, y: 0, width: 20, height:20));
            view.backgroundColor = .clear
            view.clipsToBounds = true;
            NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: 20), view.widthAnchor.constraint(equalToConstant: 20)]);
            view.scalesLargeContentImage = true;
            if let jid = senders[idx].jid, let user = Cache.shared.getOtherUser(jid: jid.stringValue) {
                view.setImage(url: user.1, placeholder: nil, intials: user.0);
            } else if let avatarPublisher = senders[idx].avatar(for: item.conversation)?.avatarPublisher {
                let name = senders[idx].nickname;
                avatarPublisher.receive(on: DispatchQueue.main).sink(receiveValue: { avatar in
                    view.set(name: name, avatar: avatar);
                }).store(in: &cancellables);
            } else {
                view.set(name: senders[idx].nickname, avatar: nil);
            }
            self.avatars.clipsToBounds = true
            self.avatars.addArrangedSubview(view);
            self.avatars.backgroundColor = .clear
        }
        self.avatars.arrangedSubviews.forEach({ $0.layoutSubviews() });
        
        let prefix = senders.count > 3 ? "+\(senders.count - 3) " : "";
        
        self.label?.text = "\(prefix)\(type.label)";

    }
    
    
}
