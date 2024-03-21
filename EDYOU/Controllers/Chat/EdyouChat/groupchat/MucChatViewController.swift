//
// MucChatViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
//import MartinOMEMO
import Combine
import uxmpp

class MucChatViewController: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar {

    static let MENTION_OCCUPANT = Notification.Name("groupchatMentionOccupant");
    
    var titleView: MucTitleView! {
        get {
            return self.navigationItem.titleView as? MucTitleView;
        }
    }
    var room: XMPPRoom {
        return self.conversation as! XMPPRoom;
    }

    private var cancellables: Set<AnyCancellable> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MucChatViewController.roomInfoClicked));
        self.titleView?.isUserInteractionEnabled = true;
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer);
        let navItem = UIBarButtonItem(image: UIImage(named: "participants")!, style: .plain, target: self, action: #selector(moveToParticipentViews(_ :)))
        self.navigationItem.rightBarButtonItem = navItem
        initializeSharing();
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if !room.features.contains(.omemo){
            room.update(features:room.features + [ConversationFeature.omemo])
        }
        if room.options.encryption == nil || room.options.encryption == .none {
            room.updateOptions({opt in
                opt.encryption = .omemo
            })
        }
        room.fetchAllMember()
        room.context!.$state.map({ $0 == .connected() }).combineLatest(room.$state).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (connected, state) in
            self?.titleView?.refresh(connected: connected, state: state);
            self?.navigationItem.rightBarButtonItem?.isEnabled = state == .joined;
        }).store(in: &cancellables);
        
        room.displayNamePublisher.map({ $0 }).assign(to: \.name, on: self.titleView).store(in: &cancellables);
        room.avatarPublisher.map({ $0 }).assign(to: \.image, on: self.titleView.chatImageView).store(in: &cancellables);
    }

    override func viewDidDisappear(_ animated: Bool) {
        cancellables.removeAll();
        super.viewDidDisappear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func canExecuteContext(action: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) -> Bool {
        switch action {
        case .retract:
            return item.state.direction == .outgoing && room.context?.state == .connected() && room.state == .joined;
        case .moderate:
            return item.state.direction == .incoming && item.payload != .messageRetracted && room.context?.state == .connected() && room.state == .joined && room.role == .moderator && room.roomFeatures.contains(.messageModeration);
        default:
            return super.canExecuteContext(action: action, forItem: item, at: indexPath);
        }
    }
    @objc func moveToParticipentViews(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: "showOccupants", sender: sender)

    }
    override func executeContext(action: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) {
        switch action {
        case .retract:
            guard item.state.direction == .outgoing else {
                return;
            }
            
            room.retract(entry: item);
        case .moderate:
            room.moderate(entry: item, completionHandler: { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("Failure", comment: "alert title"), message: NSLocalizedString("Message moderation failed!", comment: "alert body"), preferredStyle: .alert);
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                        self.present(alert, animated: true, completion: nil);
                    }
                case .success(_):
                    break;
                }
            });
        default:
            super.executeContext(action: action, forItem: item, at: indexPath);
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOccupants" {
            if let occupantsController = segue.destination as? MucChatOccupantsTableViewController {
                occupantsController.room = room;
                occupantsController.mentionOccupant = { [weak self] name in
                }
            }
        }
        super.prepare(for: segue, sender: sender);
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        self.sendMessage();
    }

    override func sendMessage() {
        guard let text = messageText, !text.isEmpty else {
            return;
        }
        
        guard room.state == .joined else {
            let alert = UIAlertController.init(title: NSLocalizedString("Warning", comment: "alert title"), message: NSLocalizedString("You are not connected to room.\nPlease wait reconnection to room", comment: "alert body"), preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .default, handler: nil));
            self.present(alert, animated: true, completion: nil);
            return;
        }
        
        let canEncrypt = room.features.contains(.omemo);
        
        let encryption: ChatEncryption = room.options.encryption ?? (canEncrypt ? Settings.messageEncryption : .none);
        guard encryption == .none || canEncrypt else {
            if encryption == .omemo && !canEncrypt {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: "alert title"), message: NSLocalizedString("This room is not capable of sending encrypted messages. Please change encryption settings to be able to send messages", comment: "alert body"), preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                self.present(alert, animated: true, completion: nil);
            }
            return;
        }
        
        room.sendMessage(text: text, correctedMessageOriginId: correctedMessageOriginId);
        DispatchQueue.main.async {
            self.messageText = nil;
        }
    }
    
    override func sendAttachment(originalUrl: URL?, uploadedUrl: String, appendix: ChatAttachmentAppendix, completionHandler: (() -> Void)?) {
        let canEncrypt = room.features.contains(.omemo);
        
        let encryption: ChatEncryption = room.options.encryption ?? (canEncrypt ? Settings.messageEncryption : .none);
        guard encryption == .none || canEncrypt else {
            completionHandler?();
            return;
        }
        
        room.sendAttachment(url: uploadedUrl, appendix: appendix, originalUrl: originalUrl, completionHandler: completionHandler);
    }
    
    @objc func roomInfoClicked() {
        guard let settingsController = self.storyboard?.instantiateViewController(withIdentifier: "MucChatSettingsViewController") as? MucChatSettingsViewController else {
            return;
        }
        settingsController.room = self.room;
        
        let navigation = UINavigationController(rootViewController: settingsController);
        navigation.title = self.title;
        navigation.modalPresentationStyle = .formSheet;
        settingsController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: settingsController, action: #selector(MucChatSettingsViewController.dismissView));
        self.present(navigation, animated: true, completion: nil);
    }

}

class MucTitleView: BaseConversationTitleView {
    var name: String? {
        get {
            return nameView.text;
        }
        set {
            nameView.text = newValue;
        }
    }
    
    func refresh(connected: Bool, state: RoomState) {
        if connected {
            let statusIcon = NSTextAttachment();
            
            var show: Presence.Show?;
            var desc = NSLocalizedString("Offline", comment: "muc room status");
            switch state {
            case .joined:
                show = Presence.Show.online;
                desc = NSLocalizedString("Online", comment: "muc room status");
            case .requested:
                show = Presence.Show.away;
                desc = NSLocalizedString("Joining…", comment: "muc room status");
            default:
                break;
            }
            
            statusIcon.image = AvatarStatusView.getStatusImage(show);
            let height = statusView.font.pointSize;
            statusIcon.bounds = CGRect(x: 0, y: -2, width: height, height: height);
            
            let statusText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: statusIcon));
            statusText.append(NSAttributedString(string: desc));
            statusView.attributedText = statusText;
        } else {
            statusView.text = "\u{26A0} \(NSLocalizedString("Not connected", comment: "muc room status label"))!";
        }
    }
}
