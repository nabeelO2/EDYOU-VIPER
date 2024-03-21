//
// ChatViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import Shared
import Martin
//import MartinOMEMO
import Combine
import uxmpp
import SwiftMessages

class ChatViewController : BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar {

    var chat: Chat {
        return conversation as! Chat;
    }
    
    var titleView: ChatTitleView! {
        get {
            return (self.navigationItem.titleView as! ChatTitleView);
        }
    }
    
    private var cancellables: Set<AnyCancellable> = [];
    
    override func conversationTableViewDelegate() -> UITableViewDelegate? {
        return self;
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.showBuddyInfo));
        self.titleView.isUserInteractionEnabled = true;
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer);
        print(conversation.jid.stringValue)
        initializeSharing();
    }
    
    @objc func showBuddyInfo(_ button: Any) {
        if let user = conversation?.jid.localPart {
            let controller = ProfileController(user: User(userID:user))
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let name = self.titleView.name
            let nameComponents = (name?.split(separator:" ") ?? []).compactMap{String($0)}
            let user = User( name:Name(firstName: nameComponents.first, lastName: nameComponents.last, middleName: nil, nickName: name),userID: conversation?.jid.stringValue)
                let controller = ProfileController(user: user)
                self.navigationController?.pushViewController(controller, animated: true)

        }
//        let contactView = storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
//        contactView.account = conversation.account;
//        contactView.jid = conversation.jid;
//        contactView.chat = self.chat;
//        contactView.navigationController?.title = self.navigationItem.title;
//        self.navigationController?.pushViewController(contactView, animated: true)//(navigation, animated: true, completion: nil);

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if XMPPAppDelegateManager.isCallAvailable {
            var buttons: [UIBarButtonItem] = [];
            buttons.append(self.smallBarButtinItem(image: UIImage(named: "videoCallIcon")!, action: #selector(self.videoCall)));
            buttons.append(self.smallBarButtinItem(image: UIImage(named: "audioCallIcon")!, action: #selector(self.audioCall)));
            self.navigationItem.rightBarButtonItems = buttons;
        }

        conversation.context?.$state.map({ $0 == .connected() }).receive(on: DispatchQueue.main).assign(to: \.connected, on: self.titleView).store(in: &cancellables);
        
        let jid = JID(chat.jid);
        conversation.statusPublisher.combineLatest(conversation.descriptionPublisher, chat.optionsPublisher, conversation.context!.module(.blockingCommand).$blockedJids).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (show, description, options, blockedJids) in
            let isBlocked = (blockedJids?.contains(jid) ?? false || blockedJids?.contains(JID(jid.domain)) ?? false);
            self?.titleView.setStatus(show, description: description, encryption: options.encryption, isBlocked: isBlocked);
        }).store(in: &cancellables)

        if let user = Cache.shared.getOtherUser(jid: conversation?.jid.stringValue ?? "") {
            self.titleView.name = user.0
            self.titleView.chatImageView.setImage(url: user.1 ?? "", placeholder: R.image.profileImagePlaceHolder(),intials: user.0?.intials);
        } else {
            conversation.displayNamePublisher.map({ $0 }).assign(to: \.name, on: self.titleView).store(in: &cancellables);
            if let img =  AvatarManager.instance.avatar(for: chat.jid, on: chat.jid) {
                self.titleView.chatImageView.image =  img;
            } else  {
                let namePublisher = chat.displayNamePublisher
                let avatarPublisher = chat.avatarPublisher
                namePublisher.combineLatest(avatarPublisher).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] name, image in
                    self?.titleView.chatImageView.set(name: name, avatar: image);
                }).store(in: &cancellables);
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cancellables.removeAll();
        super.viewDidDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let item = dataSource.getItem(at: indexPath.row) else {
            return;
        }

        let alert = UIAlertController(title: NSLocalizedString("Details", comment: "alert title"), message: item.state.errorMessage ?? NSLocalizedString("Unknown error occurred", comment: "alert body"), preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: NSLocalizedString("Resend", comment: "button label"), style: .default, handler: {(action) in
            switch item.payload {
            case .message(let message, _):
                self.chat.sendMessage(text: message, correctedMessageOriginId: nil);
                DBChatHistoryStore.instance.remove(item: item);
            case .attachment(let url, let appendix):
                let oldLocalFile = DownloadStore.instance.url(for: "\(item.id)");
                self.chat.sendAttachment(url: url, appendix: appendix, originalUrl: oldLocalFile, completionHandler: {
                    DBChatHistoryStore.instance.remove(item: item);
                });
            default:
                break;
            }
        }));
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "button label"), style: .cancel, handler: nil));
        self.present(alert, animated: true, completion: nil);
    }
     
    override func canExecuteContext(action: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) -> Bool {
        switch action {
        case .retract:
                return item.state.direction == .outgoing && XmppService.instance.connectedClients.first?.isConnected ?? false;
        case .report:
                return item.state.direction == .incoming && XmppService.instance.connectedClients.first?.module(.blockingCommand).isReportingSupported ?? false;
        default:
            return super.canExecuteContext(action: action, forItem: item, at: indexPath);
        }
    }
    
    override func executeContext(action: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) {
        switch action {
        case .retract:
            guard item.state.direction == .outgoing else {
                return;
            }
            
            chat.retract(entry: item)
        default:
            super.executeContext(action: action, forItem: item, at: indexPath);
        }
    }
    
    fileprivate func smallBarButtinItem(image: UIImage, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .custom);
        btn.setImage(image, for: .normal);
        btn.addTarget(self, action: action, for: .touchUpInside);
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        return UIBarButtonItem(customView: btn);
    }
    
    @objc func audioCall() {
        callAPI(callType: .audio )
    }
    
    @objc func videoCall() {
        callAPI(callType: .video )
    }
    
    func callAPI(callType: CallType ) {
        AudioVideoCallViewController.checkAudioVideoPermissions(parent: self) {
            if $0 {
                generateHapticFeedback()
                guard let room = self.conversation  else { return }
                APIManager.social.CallChatRoom(roomId: [room.jid.localPart ?? ""],callType: callType, roomJID: room.jid.stringValue) { chatCall, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.showErrorWith(message: error.message)
                            return
                        }
                        CallManager.shared.startCall(room: room ,callType: callType, token: chatCall?.accessToken ?? "")
                    }
                }
            }
        }
    }

    @IBAction func sendClicked(_ sender: UIButton) {
        sendMessage();
    }
    
    override func sendMessage() {
        guard let text = messageText, !text.isEmpty else {
            return;
        }
        
        chat.sendMessage(text: text, correctedMessageOriginId: self.correctedMessageOriginId)
        DispatchQueue.main.async {
            self.messageText = nil;
        }
    }
    
    
    override func sendAttachment(originalUrl: URL?, uploadedUrl: String, appendix: ChatAttachmentAppendix, completionHandler: (() -> Void)?) {
        chat.sendAttachment(url: uploadedUrl, appendix: appendix, originalUrl: originalUrl, completionHandler: completionHandler);
    }

    func showErrorWith(message: String){
        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 3)

        let error = MessageView.viewFromNib(layout: .cardView)

        let iconImage = IconStyle.default.image(theme: .error)
        error.configureTheme(backgroundColor: R.color.buttons_blue() ?? .blue, foregroundColor:  UIColor.white, iconImage: iconImage)

        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }
}

class BaseConversationTitleView: UIView {
    
    @IBOutlet var nameView: UILabel!;
    @IBOutlet var statusView: UILabel!;
    @IBOutlet var chatImageView: AvatarView!{
        didSet {
            chatImageView.backgroundColor =  UIColor(named:"chatslistBackground")
        }
    } ;

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}

class ChatTitleView: BaseConversationTitleView {

    var encryption: ChatEncryption? = nil;
    
    var name: String? {
        get {
            return nameView.text;
        }
        set {
            nameView.text = newValue;
        }
    }
    
    var connected: Bool = false {
        didSet {
            guard oldValue != connected else {
                return;
            }
            refresh();
        }
    }
//    var status: Presence? {
//        didSet {
//            self.refresh();
//        }
//    }

    private var statusShow: Presence.Show? = nil;
    private var statusDescription: String? = nil;
    private var isBlocked: Bool = false;
    
    func setStatus(_ show: Presence.Show?, description: String?, encryption: ChatEncryption?, isBlocked: Bool) {
        statusShow = show;
        statusDescription = description;
        self.encryption = encryption;
        self.isBlocked = isBlocked;
        refresh();
    }

    fileprivate func refresh() {
        DispatchQueue.main.async {
            let encryption = self.encryption ?? Settings.messageEncryption;
            if self.connected {
                let statusIcon = NSTextAttachment();
                statusIcon.image = self.isBlocked ? UIImage(systemName: "hand.raised")?.withTintColor(UIColor.systemRed) : AvatarStatusView.getStatusImage(self.statusShow);
                let height = self.statusView.font.pointSize;
                statusIcon.bounds = CGRect(x: 0, y: -2, width: height, height: height);
                if self.isBlocked {
                    let statusText = NSMutableAttributedString(attachment: statusIcon);
                    statusText.append(NSAttributedString(string: NSLocalizedString("Blocked", comment: "user status - contact blocked")));
                    self.statusView.attributedText = statusText;
                } else {
                    var desc = self.statusDescription;
                    if desc == nil {
                        let show = self.statusShow;
                        if show == nil {
                            desc = NSLocalizedString("Offline", comment: "user status");
                        } else {
                            switch(show!) {
                            case .online:
                                desc = NSLocalizedString("Online", comment: "user status");
                            case .chat:
                                desc = NSLocalizedString("Free for chat", comment: "user status");
                            case .away:
                                desc = NSLocalizedString("Be right back", comment: "user status");
                            case .xa:
                                desc = NSLocalizedString("Away", comment: "user status");
                            case .dnd:
                                desc = NSLocalizedString("Do not disturb", comment: "user status");
                            }
                        }
                    }

                    let encryptionEnable = NSTextAttachment();
                    encryptionEnable.image = UIImage(named: "encryptionEnable")
                    encryptionEnable.bounds = CGRect(x: 0, y: -2, width: height, height: height);
                    let statusText = NSMutableAttributedString(string:  "");
                    statusText.append(NSAttributedString(attachment: encryptionEnable));
                    statusText.append(NSAttributedString(attachment: statusIcon));
                    statusText.append(NSAttributedString(string: desc!));
                    self.statusView.attributedText = statusText;
                }
            } else {
                switch encryption {
                case .omemo:
                    self.statusView.text = "\u{1F512} \u{26A0} \(NSLocalizedString("Not connected", comment: "channel status label"))!";
                case .none:
                    self.statusView.text = "\u{26A0} \(NSLocalizedString("Not connected", comment: "channel status label"))!";
                }
            }            
        }
    }
}
