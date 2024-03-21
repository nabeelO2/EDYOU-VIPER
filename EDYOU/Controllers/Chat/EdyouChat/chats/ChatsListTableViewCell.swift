//
// ChatsListTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import Martin
import Combine

class ChatsListTableViewCell: UITableViewCell {

    private static let throttlingQueue = DispatchQueue(label: "ChatCellViewThrottlingQueue");
    
    private static let relativeForamtter: RelativeDateTimeFormatter = {
            let formatter = RelativeDateTimeFormatter();
            formatter.dateTimeStyle = .named;
            formatter.unitsStyle = .short;
            return formatter;
        }();
    
    fileprivate static let todaysFormatter = ({()-> DateFormatter in
        var f = DateFormatter();
        f.dateStyle = .none;
        f.timeStyle = .short;
        return f;
    })();
    fileprivate static let defaultFormatter = ({()-> DateFormatter in
        var f = DateFormatter();
        f.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd.MM", options: 0, locale: NSLocale.current);
        //        f.timeStyle = .NoStyle;
        return f;
    })();
    fileprivate static let fullFormatter = ({()-> DateFormatter in
        var f = DateFormatter();
        f.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd.MM.yyyy", options: 0, locale: NSLocale.current);
        //        f.timeStyle = .NoStyle;
        return f;
    })();
    
    private static func formatTimestamp(_ ts: Date, _ now: Date) -> String {
        let flags: Set<Calendar.Component> = [.minute, .hour, .day, .year];
        var components = Calendar.current.dateComponents(flags, from: now, to: ts);
        if (components.day! >= -1) {
            components.second = 0;
            return relativeForamtter.localizedString(from: components);
        }
        if (components.year! != 0) {
            return ChatsListTableViewCell.fullFormatter.string(from: ts);
        } else {
            return ChatsListTableViewCell.defaultFormatter.string(from: ts);
        }
    }
    
    // MARK: Properties
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarStatusView: AvatarStatusView! {
        didSet {
            avatarStatusView?.backgroundColor = UIColor(named: "chatslistBackground");
        }
    }
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var badge: BadgeButton!;
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor;
        }
        set {
            super.backgroundColor = UIColor(named: "chatslistBackground");
            avatarStatusView?.backgroundColor = UIColor(named: "chatslistBackground");
        }
    }
    
    private var cancellables: Set<AnyCancellable> = [];
    private var conversation: Conversation? {
        didSet {
            cancellables.removeAll();

            if let user = Cache.shared.getOtherUser(jid: conversation?.jid.stringValue ?? ""){
                nameLabel.text = user.0
                avatarStatusView.avatarImageView.setImage(url: user.1, placeholder: nil, intials: user.0?.intials)
            }  else {
                conversation?.displayNamePublisher.map({ $0 }).assign(to: \.text, on: nameLabel).store(in: &cancellables);
                avatarStatusView.displayableId =  conversation
            }
            avatarStatusView.displayableId = conversation;
            conversation?.unreadPublisher.throttleFixed(for: 0.1, scheduler: ChatsListTableViewCell.throttlingQueue, latest: true).removeDuplicates().receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] value in
                self?.set(unread: value);
            }).store(in: &cancellables);

            conversation?.timestampPublisher.throttleFixed(for: 0.1, scheduler: ChatsListTableViewCell.throttlingQueue, latest: true).combineLatest(CurrentTimePublisher.publisher).map({ (value, now) in ChatsListTableViewCell.formatTimestamp(value, now) }).receive(on: DispatchQueue.main).assign(to: \.text, on: timestampLabel).store(in: &cancellables);
            if let account = conversation?.account {
                conversation?.lastActivityPublisher.throttleFixed(for: 0.1, scheduler: ChatsListTableViewCell.throttlingQueue, latest: true).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] value in
                    self?.set(lastActivity: value, account: account);
                }).store(in: &cancellables);
            }
        }
    }

    func update(conversation: Conversation) {
        lastMessageLabel.numberOfLines = 3;
        lastMessageLabel.invalidateIntrinsicContentSize();
        lastMessageLabel.setNeedsLayout();
        self.conversation = conversation;
    }

    private func set(unread: Int) {
        self.badge.title = unread > 0 ? "\(unread)" : nil;
    }
    
    private func set(lastActivity: LastConversationActivity?, account: BareJID) {
        if let lastActivity = lastActivity {
            switch lastActivity {
            case .message(let lastMessage, let direction, let sender):
                if lastMessage.starts(with: "/me ") {
                    let nick = sender ?? (direction == .incoming ? (nameLabel.text ?? "") : (AccountManager.getAccount(for: account)?.nickname ?? NSLocalizedString("Me", comment: "me label for conversation log")));
                    let baseFontDescriptor = UIFont.preferredFont(forTextStyle: .subheadline).fontDescriptor;
                    let fontDescriptor = UIFont.myMediumSystemFont(ofSize: 14.0).fontDescriptor;

                    let font = UIFont(descriptor: fontDescriptor ?? baseFontDescriptor, size: 0);
                    
                    let msg = NSMutableAttributedString(string: "\(nick) ", attributes: [.font: font]);
                    msg.append(NSAttributedString(string: "\(lastMessage.dropFirst(4))", attributes: [.font: font]));
                    
                    lastMessageLabel.attributedText = msg;
                } else {
                    let font = UIFont.myMediumSystemFont(ofSize: 14.0)
                    let msg = NSMutableAttributedString(string: lastMessage);

                    Markdown.applyStyling(attributedString: msg, defTextStyle: .subheadline, showEmoticons: true);
                    if sender != nil {
                        let prefixFontDescription = font.fontDescriptor.withSymbolicTraits(.traitBold);
                        let prefix = NSMutableAttributedString(string: "\(sender!): ", attributes: [.font: prefixFontDescription != nil ? UIFont(descriptor: prefixFontDescription!, size: 0) : font]);
                        prefix.append(msg);
                        lastMessageLabel.attributedText = prefix;
                    } else {
                        lastMessageLabel.attributedText = msg;
                    }
                }
            case .invitation(_, _, let sender):
                let font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline).withSymbolicTraits([.traitItalic, .traitBold, .traitCondensed])!, size: 0);
                let msg = NSAttributedString(string: "📨 \(NSLocalizedString("Invitation", comment: "invitation label for chats list"))", attributes: [.font:  font, .foregroundColor: lastMessageLabel.textColor!.withAlphaComponent(0.8)]);

                if let prefix = sender != nil ? NSMutableAttributedString(string: "\(sender!): ") : nil {
                    prefix.append(msg);
                    lastMessageLabel.attributedText = prefix;
                } else {
                    lastMessageLabel.attributedText = msg;
                }
            case .attachment(_, _, let sender):
                let font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline).withSymbolicTraits([.traitItalic, .traitBold, .traitCondensed])!, size: 0);
                let msg = NSAttributedString(string: "📎 \(NSLocalizedString("Attachment", comment: "attachemt label for conversations list"))", attributes: [.font:  font, .foregroundColor: lastMessageLabel.textColor!.withAlphaComponent(0.8)]);

                if let prefix = sender != nil ? NSMutableAttributedString(string: "\(sender!): ") : nil {
                    prefix.append(msg);
                    lastMessageLabel.attributedText = prefix;
                } else {
                    lastMessageLabel.attributedText = msg;
                }
            case .location(_, _, let sender):
                let font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline).withSymbolicTraits([.traitItalic, .traitBold, .traitCondensed])!, size: 0);
                let msg = NSAttributedString(string: "📍 \(NSLocalizedString("Location", comment: "attachemt label for conversations list"))", attributes: [.font:  font, .foregroundColor: lastMessageLabel.textColor!.withAlphaComponent(0.8)]);

                if let prefix = sender != nil ? NSMutableAttributedString(string: "\(sender!): ") : nil {
                    prefix.append(msg);
                    lastMessageLabel.attributedText = prefix;
                } else {
                    lastMessageLabel.attributedText = msg;
                }
            }
        } else {
            lastMessageLabel.text = nil;
        }
    }
    
}
