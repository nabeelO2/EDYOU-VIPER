//
// ChannelViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin
import Combine

class ChannelViewController: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar {

    var titleView: ChannelTitleView! {
        get {
            return self.navigationItem.titleView as? ChannelTitleView
        }
    }
    
    var channel: Channel {
        return conversation as! Channel;
    }
    
    private var cancellables: Set<AnyCancellable> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(channelInfoClicked));
        self.titleView?.isUserInteractionEnabled = true;
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer);
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let navItem = UIBarButtonItem(image: UIImage(named: "participants")!, style: .plain, target: self, action: #selector(moveToParticipentViews(_ :)))
        navItem.tintColor = R.color.buttons_green() ?? .green
        self.navigationItem.rightBarButtonItem = navItem 
        initializeSharing();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        channel.context!.$state.map({ $0 == .connected() }).combineLatest(channel.optionsPublisher).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (connected, options) in
            self?.titleView?.refresh(connected: connected, options: options);
            self?.navigationItem.rightBarButtonItem?.isEnabled = options.state == .joined;
        }).store(in: &cancellables);
        channel.displayNamePublisher.map({ $0 }).assign(to: \.name, on: self.titleView).store(in: &cancellables);
        channel.avatarPublisher.map({ $0 }).assign(to: \.image, on: self.titleView.chatImageView).store(in: &cancellables);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        cancellables.removeAll();
    }


 @objc func moveToParticipentViews(_ sender: UIBarButtonItem) {
    let vc = UIStoryboard(name: "MIX", bundle: nil).instantiateViewController(withIdentifier: "ChannelParticipantsController") as! ChannelParticipantsController
     vc.channel = channel
     self.navigationController?.pushViewController(vc, animated: true)
    }
    override func canExecuteContext(action: BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) -> Bool {
        switch action {
        case .retract:
            return item.state.direction == .outgoing && channel.context?.state == .connected() && channel.state == .joined;
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
            
            channel.retract(entry: item);
        default:
            super.executeContext(action: action, forItem: item, at: indexPath);
        }
    }
    
    @IBAction func sendClicked(_ sender: UIButton) {
        self.sendMessage();
    }

    @objc func channelInfoClicked() {
        self.performSegue(withIdentifier: "ChannelSettingsShow", sender: self);
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender);
        if let destination = (segue.destination as? UINavigationController)?.topViewController as? ChannelSettingsViewController {
            destination.channel = self.channel;
        }
        if let destination = segue.destination as? ChannelParticipantsController {
            destination.channel = self.channel;
        }
    }
    
    override func sendMessage() {
        guard let text = messageText, !text.isEmpty else {
            return;
        }
                
        guard channel.state == .joined else {
            let alert: UIAlertController?  = UIAlertController.init(title: NSLocalizedString("Warning", comment: "alert title"), message: NSLocalizedString("You are not joined to the channel.", comment: "alert body"), preferredStyle: .alert);
            alert?.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .default, handler: nil));
            self.present(alert!, animated: true, completion: nil);
            return;
        }
        
        channel.sendMessage(text: text, correctedMessageOriginId: self.correctedMessageOriginId);
        DispatchQueue.main.async {
            self.messageText = nil;
        }
    }
    
    override func sendAttachment(originalUrl: URL?, uploadedUrl: String, appendix: ChatAttachmentAppendix, completionHandler: (() -> Void)?) {
        channel.sendAttachment(url: uploadedUrl, appendix: appendix, originalUrl: originalUrl, completionHandler: completionHandler);
    }
    
}

class ChannelTitleView: BaseConversationTitleView {
    var name: String? {
        get {
            return nameView.text;
        }
        set {
            nameView.text = newValue;
        }
    }
    
    func refresh(connected: Bool, options: ChannelOptions) {
        if connected {
            let statusIcon = NSTextAttachment();
                
            var show: Presence.Show?;
            var desc = NSLocalizedString("Not connected", comment: "channel status label");
            switch options.state {
            case .joined:
                show = Presence.Show.online;
                desc = NSLocalizedString("Joined", comment: "channel status label");
            case .left:
                show = nil;
                desc = NSLocalizedString("Not joined", comment: "channel status label");
            }
                
            statusIcon.image = AvatarStatusView.getStatusImage(show);
            let height = statusView.font.pointSize;
            statusIcon.bounds = CGRect(x: 0, y: -2, width: height, height: height);
                
            let statusText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: statusIcon));
            statusText.append(NSAttributedString(string: desc));
            statusView.attributedText = statusText;
        } else {
            statusView.text = "\u{26A0} \(NSLocalizedString("Not connected", comment: "channel status label"))!";
        }
    }
}
