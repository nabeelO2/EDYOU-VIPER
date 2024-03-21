//
// ChatTableViewSystemCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class ChatTableViewSystemCell: UITableViewCell {
    
    @IBOutlet var messageView: UILabel!
    
}

class ChatTableViewMeCell: UITableViewCell {
    

    @IBOutlet var messageView: MessageTextView!
    
    func set(item: ConversationEntry, message msg: String) {
        let nickname = item.sender.nickname ?? "SOMEONE:";
        let preferredFont = UIFont.preferredFont(forTextStyle: .subheadline);
        let message = NSMutableAttributedString(string: "\(nickname) ", attributes: [.font: UIFont(descriptor: preferredFont.fontDescriptor.withSymbolicTraits([.traitBold,.traitItalic])!, size: 0), .foregroundColor: UIColor.secondaryLabel]);
        message.append(NSAttributedString(string: "\(msg.dropFirst(4))", attributes: [.font: UIFont(descriptor: preferredFont.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: 0), .foregroundColor: UIColor.secondaryLabel]));
        self.messageView.attributedText = message;
        
        self.accessibilityAttributedLabel = message;
        self.isAccessibilityElement = true
    }

}
