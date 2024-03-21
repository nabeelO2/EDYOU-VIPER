//
// BaseChatViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import UserNotifications
import Martin
import Combine

class BaseChatViewController: UIViewController, UITextViewDelegate, ChatViewInputBarDelegate {

    @IBOutlet var containerView: UIView!;
    
    var conversationLogController: ConversationLogController? {
        didSet {
            self.conversationLogController?.conversation = self.conversation;
        }
    }
    
    @IBInspectable var animateScrollToBottom: Bool = true;
    
    var sendMessageButton: UIButton?;
    
    var conversation: Conversation! {
        didSet {
            conversationLogController?.conversation = conversation;
        }
    }
        
    private(set) var correctedMessageOriginId: String?;
    
    var progressBar: UIProgressView?;

    var askMediaQuality: Bool = false;
    
    var messageText: String? {
        get {
            return chatViewInputBar.text;
        }
        set {
            chatViewInputBar.text = newValue;
            if newValue == nil {
                self.correctedMessageOriginId = nil;
            }
        }
    }
        
    let chatViewInputBar = ChatViewInputBar();
    
    private var cancellables: Set<AnyCancellable> = [];
    
    func conversationTableViewDelegate() -> UITableViewDelegate? {
        return nil;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewInputBar.placeholder = String.localizedStringWithFormat(NSLocalizedString("Write a message", comment: "conversation view input field placeholder"), conversation.account.stringValue);

        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem;
        navigationItem.leftItemsSupplementBackButton = true;

        self.view.addSubview(chatViewInputBar);

        if let bottomTableViewConstraint = self.view.constraints.first(where: { $0.firstAnchor == containerView.bottomAnchor || $0.secondAnchor == containerView.bottomAnchor }) {
            bottomTableViewConstraint.isActive = false;
            self.view.removeConstraint(bottomTableViewConstraint);
        }
        
        NSLayoutConstraint.activate([
            chatViewInputBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            chatViewInputBar.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            chatViewInputBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatViewInputBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ]);

        chatViewInputBar.setNeedsLayout();
                
        chatViewInputBar.delegate = self;
        
        let sendMessageButton = UIButton(type: .custom);
        sendMessageButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4);
        sendMessageButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal);
        sendMessageButton.addTarget(self, action: #selector(sendMessageClicked(_:)), for: .touchUpInside);
        sendMessageButton.contentMode = .scaleToFill;
        sendMessageButton.tintColor = UIColor.systemTintColor

        self.sendMessageButton = sendMessageButton;
//        chatViewInputBar.addBottomButton(sendMessageButton);
        chatViewInputBar.addSendButton(sendMessageButton)
        
        let locationButton = UIButton(type: .custom);
        locationButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4);
        locationButton.setImage(UIImage(systemName: "location"), for: .normal);
        locationButton.addTarget(self, action: #selector(sendMessageClicked(_:)), for: .touchUpInside);
        locationButton.contentMode = .scaleToFill;
        locationButton.tintColor = UIColor.systemTintColor
        locationButton.addTarget(self, action: #selector(shareLocation(_:)), for: .touchUpInside);
//        chatViewInputBar.addBottomButton(locationButton);
        
        setColors();
        DBChatStore.instance.conversationsEventsPublisher.sink(receiveValue: { [weak self] event in
            switch event {
            case .destroyed(let conversation):
                DispatchQueue.main.async {
                    self?.closed(conversation: conversation);
                }
            case .created(_):
                break;
            }
        }).store(in: &cancellables);
        
        containerView.backgroundColor = .green
    }
    
    @objc func shareLocation(_ sender: Any) {
        let controller = ShareLocationController();
        controller.conversation = self.conversation;
        let navController = UINavigationController(rootViewController: controller);
        navController.modalPresentationStyle = .pageSheet;
        self.present(navController, animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConversationLogController {
            self.conversationLogController = destination;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if self.messageText?.isEmpty ?? true {
            DBChatStore.instance.messageDraft(for: conversation.account, with: conversation.jid, completionHandler: { text in
                DispatchQueue.main.async {
                    self.messageText = text;
                }
            })
        }

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
        chatViewInputBar.becomeFirstResponder();
        animate();
        
    }
    
    private func closed(conversation: Conversation) {
        guard self.conversation.id == conversation.id else {
            return;
        }
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true);
        }
    }
        
    private func animate() {
        guard let coordinator = self.transitionCoordinator else {
            return;
        }
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.setColors();
        }, completion: nil);
    }
    
    private func setColors() {
        let appearance = UINavigationBarAppearance();
        appearance.configureWithDefaultBackground();
        appearance.backgroundEffect = UIBlurEffect.init(style: .systemMaterial);
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = appearance;
        navigationController?.navigationBar.barTintColor = UIColor.systemBackground;
        navigationController?.navigationBar.tintColor = UIColor.systemTintColor;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil);
        super.viewWillDisappear(animated);
        DBChatStore.instance.storeMessage(draft: messageText, for: conversation.account, with: conversation.jid);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let endRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                guard endRect.height != 0 && endRect.size.width != 0 else {
                    return;
                }
                let window: UIView? = self.view.window;
                let keyboard = self.view.convert(endRect, from: window);
                let height = self.view.frame.size.height;
                let hasExternal = (keyboard.origin.y + keyboard.size.height) > height;
                
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval;
                let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt;
                UIView.animate(withDuration: duration, delay: 0.0, options: [UIView.AnimationOptions(rawValue: curve), UIView.AnimationOptions.beginFromCurrentState], animations: {
                    if !hasExternal {
                        self.keyboardHeight = endRect.origin.y == 0 ? endRect.size.width : endRect.size.height;
                    } else {
                        self.keyboardHeight = height - keyboard.origin.y;
                    }
                    }, completion: nil);
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt;
        UIView.animate(withDuration: notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval, delay: 0.0, options: [UIView.AnimationOptions(rawValue: curve), UIView.AnimationOptions.beginFromCurrentState], animations: {
            self.keyboardHeight = 0;
            }, completion: nil);
    }
    
    var keyboardHeight: CGFloat = 0 {
        didSet {
            self.view.constraints.first(where: { $0.firstAnchor == self.view.bottomAnchor || $0.secondAnchor == self.view.bottomAnchor })?.constant = keyboardHeight * -1;
        }
    }
    
    @IBAction func tableViewClicked(_ sender: AnyObject) {
        _ = self.chatViewInputBar.resignFirstResponder();
    }
        
    func startMessageCorrection(message: String, originId: String) {
        self.messageText = message;
        self.correctedMessageOriginId = originId;
    }
    
    func sendMessage() {
        assert(false, "This method should be overridden");
    }
    
    func sendAttachment(originalUrl: URL?, uploadedUrl: String, appendix: ChatAttachmentAppendix, completionHandler: (() -> Void)?) {
        assert(false, "This method should be overridden");
    }
    
    func messageTextCleared() {
        self.correctedMessageOriginId = nil;
    }
    
    @objc func sendMessageClicked(_ sender: Any) {
        self.sendMessage();
    }
    
}
