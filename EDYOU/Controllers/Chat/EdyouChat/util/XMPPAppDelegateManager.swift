    //
    //  XMPPAppDelegateManager.swift
    //  Edyou IM
    //
    //  Created by Suleman Ali on 09/01/2024.
    //  Copyright © 2024 Tigase, Inc. All rights reserved.
    //

import Foundation
import UIKit
import Combine
import TigaseLogging
import BackgroundTasks
import Martin
import Shared
import Intents

final class XMPPAppDelegateManager {
    static public let shared = XMPPAppDelegateManager()
    fileprivate let notificationCenterDelegate = NotificationCenterDelegate();

    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main");
    fileprivate let backgroundRefreshTaskIdentifier = "com.edyou.edyou.mobile.refresh";
    fileprivate var cancellables: Set<AnyCancellable> = [];
    fileprivate var backgroundTaskId = UIBackgroundTaskIdentifier.invalid;
    fileprivate var backgroundFetchInProgress = false;
    private var manager:LoginProcessManager?
    public var window:UIWindow?

    class var isCallAvailable:Bool {
        if #available(iOS 16, *) {
            let identifier = (Locale.current.region ?? .pakistan).identifier
            return !identifier.contains("CN") && !identifier.contains("CHN")
        } else {

           let identifier = Locale.current.identifier
            return !identifier.contains("CN") && !identifier.contains("CHN")
        }

    }

    private init() {}

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundRefreshTaskIdentifier, using: nil) { (task) in
            self.handleAppRefresh(task: task as! BGAppRefreshTask);
        }
        Cache.shared.frinedDict =  UserDefaults.standard.dictionary(forKey: "frinedDict") as? [String:[String]]  ?? [:]

        AccountSettings.initialize();
        _ = NotificationManager.instance;
        XmppService.instance.initialize();
        UNUserNotificationCenter.current().delegate = self.notificationCenterDelegate;

        let categories = [
            UNNotificationCategory(identifier: "MESSAGE", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("New message", comment: "notification of incoming message on locked screen"), options: [.customDismissAction])
        ];
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories));



        NotificationCenter.default.addObserver(self, selector: #selector(serverCertificateError), name: XmppService.SERVER_CERTIFICATE_ERROR, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(pushNotificationRegistrationFailed), name: Notification.Name("pushNotificationsRegistrationFailed"), object: nil);

        AccountManager.accountEventsPublisher.sink(receiveValue: { [weak self] action in
            switch action {
                case .enabled(let account, let bool):
                    if let client =  XmppService.instance.connectedClients.first {
                        client.module(.presence).subscribe(to: JID(account.name.stringValue))
                        client.module(.presence).subscribed(by: JID(account.name.stringValue))
                    }

                case .disabled(let account),.removed(let account):
                    return
            }
        }).store(in: &cancellables);


    }
    func updateApplicationState(_ state: XmppService.ApplicationState) {
        XmppService.instance.updateApplicationState(state);
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        updateApplicationState(.inactive)
        initiateBackgroundTask();
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundRefreshTaskIdentifier);
        XmppService.instance.updateApplicationState(.active);
        applicationKeepOnlineOnAwayFinished(application);
        NotificationManager.instance.updateApplicationIconBadgeNumber(completionHandler: nil);
    }

    private func initiateBackgroundTask() {
        guard XmppService.instance.applicationState != .active else {
            return;
        }
        let application = UIApplication.shared;
        backgroundTaskId = application.beginBackgroundTask {
            self.logger.debug("keep online on away background task \(self.backgroundTaskId) expired");
            self.applicationKeepOnlineOnAwayFinished(application);
        }
        if backgroundTaskId == .invalid {
            logger.debug("failed to start keep online background task");
            XmppService.instance.updateApplicationState(.suspended);
        } else {
            let taskId = backgroundTaskId;
            logger.debug("keep online task \(taskId) started");
        }
    }

    private func applicationKeepOnlineOnAwayFinished(_ application: UIApplication) {
        let message = "applicationKeepOnlineOnAwayFinished"
        NSLog("%@", message)

        let taskId = backgroundTaskId;
        guard taskId != .invalid else {
            return;
        }
        backgroundTaskId = .invalid;
        logger.debug("keep online task \(taskId) expired");
        XmppService.instance.updateApplicationState(.suspended);
        XmppService.instance.backgroundTaskFinished();
        logger.debug("keep online calling end background task \(taskId)");
        scheduleAppRefresh();
        logger.debug("keep online task \(taskId) ended");
        application.endBackgroundTask(taskId);
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundRefreshTaskIdentifier);
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3500);

        do {
            try BGTaskScheduler.shared.submit(request);
        } catch {
            logger.error("Could not schedule app refresh: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        guard DispatchQueue.main.sync(execute: {
            if self.backgroundFetchInProgress {
                return false;
            }
            backgroundFetchInProgress = true;
            return true;
        }) else {
            task.setTaskCompleted(success: true);
            return;
        }
        self.scheduleAppRefresh();
        let fetchStart = Date();
        logger.debug("starting fetching");
        XmppService.instance.preformFetch(completionHandler: {(result) in
            let fetchEnd = Date();
            let time = fetchEnd.timeIntervalSince(fetchStart);
            self.logger.debug("fetched data in \(time) seconds with result = \(result)");
            self.backgroundFetchInProgress = false;
            task.setTaskCompleted(success: result != .failed);
        });

        task.expirationHandler = {
            self.logger.debug("task expiration reached, start");
            DispatchQueue.main.sync {
                self.backgroundFetchInProgress = false;
            }
            XmppService.instance.performFetchExpired();
            self.logger.debug("task expiration reached, end");
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        logger.debug("application terminated!")
    }

    func isChatVisible(account acc: String?, with j: String?) -> Bool {
        guard let account = acc, let jid = j else {
            return false;
        }

        guard let baseChatController = getChatController(visible: true) else {
            return false;
        }

        return (baseChatController.conversation.account == BareJID(account)) && (baseChatController.conversation.jid == BareJID(jid));
    }

    func getChatController(visible: Bool) -> BaseChatViewController? {
        var topController = UIApplication.shared.windows.first(where:{ $0.isKeyWindow })?.rootViewController;
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController;
        }
        guard let splitViewController = topController as? UISplitViewController else {
            return nil;
        }

        guard let navigationController = navigationController(fromSplitViewController: splitViewController) else {
            return nil;
        }

        if visible {
            return navigationController.viewControllers.last as? BaseChatViewController;
        } else {
            for controller in navigationController.viewControllers.reversed() {
                if let baseChatViewController = controller as? BaseChatViewController {
                    return baseChatViewController;
                }
            }
            return nil;
        }
    }

    private func navigationController(fromSplitViewController splitViewController: UISplitViewController) -> UINavigationController? {
        if splitViewController.isCollapsed {
            return splitViewController.viewControllers.first(where: { $0 is UITabBarController }).map({ $0 as! UITabBarController })?.selectedViewController as? UINavigationController;
        } else {
            return splitViewController.viewControllers.first(where: { !($0 is UITabBarController) }) as? UINavigationController;
        }
    }

    @objc func serverCertificateError(_ notification: NSNotification) {
        guard let certInfo = notification.userInfo else {
            return;
        }

        let account = BareJID(certInfo["account"] as! String);

        let content = UNMutableNotificationContent();
        content.body = String.localizedStringWithFormat(NSLocalizedString("Connection to server %@ failed", comment: "error notification message"), account.domain);
        content.userInfo = certInfo;
        content.categoryIdentifier = "ERROR";
        content.threadIdentifier = "account=" + account.stringValue;
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil));
    }

    func notifyUnsentMessages(count: Int) {
        let content = UNMutableNotificationContent();
        content.body = String.localizedStringWithFormat(NSLocalizedString("It was not possible to send %d messages. Open the app to retry", comment: "unsent messages notification"), count);
        content.categoryIdentifier = "UNSENT_MESSAGES";
        content.threadIdentifier = "unsent-messages";
        content.sound = .default;
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil));
    }

    @objc func pushNotificationRegistrationFailed(_ notification: NSNotification) {
        let account = notification.userInfo?["account"] as? BareJID;
        let errorCondition = (notification.userInfo?["errorCondition"] as? ErrorCondition) ?? ErrorCondition.internal_server_error;
        let content = UNMutableNotificationContent();
        switch errorCondition {
            case .remote_server_timeout:
                content.body = NSLocalizedString("It was not possible to contact push notification component.\nTry again later.", comment: "push notifications registration failure message")
            case .remote_server_not_found:
                content.body = NSLocalizedString("It was not possible to contact push notification component.", comment: "push notifications registration failure message")
            case .service_unavailable:
                content.body = NSLocalizedString("Push notifications not available", comment: "push notifications registration failure message")
            default:
                content.body = String.localizedStringWithFormat(NSLocalizedString("It was not possible to contact push notification component: %@", comment: "push notifications registration failure message"), errorCondition.rawValue);
        }
        content.threadIdentifier = "account=" + account!.stringValue;
        content.categoryIdentifier = "ERROR";
        content.userInfo = ["account": account!.stringValue];
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil));

    }

    func application(_ application: UIApplication, continue activity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard let intent = activity.interaction?.intent as? INSendMessageIntent else {
            return false;
        }

        guard let account = BareJID(intent.sender?.personHandle?.value), AccountManager.getAccount(for: account)?.active ?? false else {
            return false;
        }

        guard let recipient = BareJID(intent.recipients?.first?.personHandle?.value) else {
            return false;
        }

        guard let xmppClient = XmppService.instance.getClient(for: account) else {
            return false;
        }

        var chatToOpen: Chat?;
        switch DBChatStore.instance.createChat(for: xmppClient, with: recipient,name: intent.recipients?.first?.displayName ?? "unknown") {
            case .created(let chat):
                chatToOpen = chat;
            case .found(let chat):
                chatToOpen = chat;
            case .none:
                return false;
        }

        guard let chatController = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController  else {
            return false;
        }
        chatController.hidesBottomBarWhenPushed = true;
        chatController.conversation = chatToOpen;
        if let nv = UIApplication.topViewController()?.navigationController {
            nv.pushViewController(chatController, animated: true)
        } else {
            UIApplication.topViewController()?.showDetailViewController(chatController, sender: self);
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false;
        }
        guard let xmppUri = XmppUri(url: url) else {
            return false;
        }
        logger.debug("got xmpp url with jid: \(xmppUri.jid), action: \(xmppUri.action as Any), params: \(xmppUri.dict as Any)");

        if let action = xmppUri.action {
            self.open(xmppUri: xmppUri, action: action);
            return true;
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: NSLocalizedString("Open URL", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("What do you want to do with %@?", comment: "alert body"), url.description), preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: NSLocalizedString("Open chat", comment: "action label"), style: .default, handler: { (action) in
                    self.open(xmppUri: xmppUri, action: .message);
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Join room", comment: "action label"), style: .default, handler: { (action) in
                    self.open(xmppUri: xmppUri, action: .join);
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add contact", comment: "action label"), style: .default, handler: { (action) in
                    self.open(xmppUri: xmppUri, action: .roster);
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Nothing", comment: "action label"), style: .cancel, handler: nil));
                self.window?.rootViewController?.present(alert, animated: true, completion: nil);
            }
            return false;
        }
    }

    func open(xmppUri: XmppUri, action: XmppUri.Action, then: (()->Void)? = nil) {
        switch action {
            case .join:
                let navController = UIStoryboard(name: "MIX", bundle: nil).instantiateViewController(withIdentifier: "ChannelJoinNavigationViewController") as! UINavigationController;
                let joinController = navController.visibleViewController as! ChannelSelectToJoinViewController;
                joinController.joinConversation = (xmppUri.jid.bareJid, xmppUri.dict?["password"]);


                joinController.hidesBottomBarWhenPushed = true;
                navController.modalPresentationStyle = .formSheet;
                window?.rootViewController?.dismiss(animated: true, completion: {
                    self.window?.rootViewController?.present(navController, animated: true, completion: nil);
                })
            case .message:
                let alert = UIAlertController(title: NSLocalizedString("Start chatting", comment: "alert title"), message: NSLocalizedString("Select account to open chat from", comment: "alert body"), preferredStyle: .alert);
                let openChatFn: (BareJID)->Void = { (account) in
                    guard let xmppClient = XmppService.instance.getClient(for: account) else {
                        return;
                    }

                    var chatToOpen: Chat?;
                    switch DBChatStore.instance.createChat(for: xmppClient, with: xmppUri.jid.bareJid) {
                        case .created(let chat):
                            chatToOpen = chat;
                        case .found(let chat):
                            chatToOpen = chat;
                        case .none:
                            return;
                    }

                    guard let destination = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "ChatViewNavigationController") as? UINavigationController else {
                        return;
                    }

                    let chatController = destination.children[0] as! ChatViewController;
                    chatController.hidesBottomBarWhenPushed = true;
                    chatController.conversation = chatToOpen;
                    self.window?.rootViewController?.showDetailViewController(destination, sender: self);
                }

                if let account = XmppService.instance.connectedClients.first {
                    openChatFn(account.userBareJid);
                }
            case .roster:
                if let dict = xmppUri.dict, let ibr = dict["ibr"], ibr == "y" {
                    guard !AccountManager.getAccounts().isEmpty else {
                        self.open(xmppUri: XmppUri(jid: JID(xmppUri.jid.domain), action: .register, dict: dict), action: .register, then: {
                            DispatchQueue.main.async {
                                self.open(xmppUri: xmppUri, action: action);
                            }
                        });
                        return;
                    }
                }
                guard let navigationController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "RosterItemEditNavigationController") as? UINavigationController else {
                    return;
                }
                let itemEditController = navigationController.visibleViewController as? RosterItemEditViewController;
                itemEditController?.hidesBottomBarWhenPushed = true;
                navigationController.modalPresentationStyle = .formSheet;
                self.window?.rootViewController?.present(navigationController, animated: true, completion: {
                    itemEditController?.account = nil;
                    itemEditController?.jid = xmppUri.jid;
                    itemEditController?.jidTextField.text = xmppUri.jid.stringValue;
                    itemEditController?.nameTextField.text = xmppUri.dict?["name"];
                    itemEditController?.preauth = xmppUri.dict?["preauth"];
                });
            case .register:
                
                break
        }
    }

    func notificationTokenUpdated(_ tokenString:String?,error:Error?) {
        if let tokenString = tokenString {
            logger.debug("registered for remote notifications, got device token: \(tokenString, privacy: .public)");
            PushEventHandler.instance.deviceId = tokenString;
            Settings.enablePush = true;
        } else {
            PushEventHandler.instance.deviceId = nil;
            Settings.enablePush = false;
            logger.error("failed to register for remote notifications: \(error, privacy: .public)");
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            let toDiscard = notifications.filter({(notification) in
                switch XMPPNotificationCategory.from(identifier: notification.request.content.categoryIdentifier) {
                    case .UNSENT_MESSAGES:
                        return true;
                    case .MESSAGE:
                        return notification.request.content.userInfo["sender"] as? String == nil;
                    default:
                        return false;
                }
            }).map({ (notiication) -> String in
                return notiication.request.identifier;
            });
            guard !toDiscard.isEmpty else {
                return;
            }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: toDiscard)
            NotificationManager.instance.updateApplicationIconBadgeNumber(completionHandler: nil);
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.debug("Push notification received with fetch request: \(userInfo)");
        
        if let account = JID(userInfo[AnyHashable("account")] as? String) {
            let sender = JID(userInfo[AnyHashable("sender")] as? String);
            let body = userInfo[AnyHashable("body")] as? String;

            if let unreadMessages = userInfo[AnyHashable("unread-messages")] as? Int, unreadMessages == 0 && sender == nil && body == nil {
                let state = XmppService.instance.getClient(for: account.bareJid)?.state;
                logger.debug("unread messages retrieved, client state = \(state, privacy: .public)");
                if state != .connected() {
                    dismissNewMessageNotifications(for: account) {
                        completionHandler(.newData);
                    }
                    return;
                }
            } else if body != nil {
                    // FIXME: not sure about this `date`!!
                NotificationManager.instance.notifyNewMessage(account: account.bareJid, sender: sender?.bareJid, nickname: userInfo[AnyHashable("nickname")] as? String, body: body!, date: Date());
            } else {
                if let encryped = userInfo["encrypted"] as? String, let ivStr = userInfo["iv"] as? String, let key = NotificationEncryptionKeys.key(for: account.bareJid), let data = Data(base64Encoded: encryped), let iv = Data(base64Encoded: ivStr) {
                    logger.debug("got encrypted push with known key");
                    let cipher = Cipher.AES_GCM();
                    var decoded = Data();
                    if cipher.decrypt(iv: iv, key: key, encoded: data, auth: nil, output: &decoded) {
                        logger.debug("got decrypted data: \(String(data: decoded, encoding: .utf8) as Any)");
                        if let payload = try? JSONDecoder().decode(Payload.self, from: decoded) {
                            logger.debug("decoded payload successfully!");
                                // we require `media` to be present (even empty) in incoming push for jingle session initiation,
                                // so we can assume that if `media` is `nil` then this is a push for call termination
                            if let sid = payload.sid, payload.media == nil {
                                return;
                            }
                        }

                    }
                }
            }
        }

        completionHandler(.newData);
    }

    private func dismissNewMessageNotifications(for account: JID, completionHandler: (()-> Void)?) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            let toRemove = notifications.filter({ (notification) in
                switch XMPPNotificationCategory.from(identifier: notification.request.content.categoryIdentifier) {
                    case .MESSAGE:
                        return (notification.request.content.userInfo["account"] as? String) == account.stringValue;
                    default:
                        return false;
                }
            }).map({ (notification) in notification.request.identifier });
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: toRemove);
            NotificationManager.instance.updateApplicationIconBadgeNumber(completionHandler: completionHandler);
        }
    }

    func logoutFromXMPP() {
        AccountManager.getAccounts().forEach{
            try? AccountManager.deleteAccount(for: $0);
        }
    }

    func loginToExistingAccount(id: String, pass: String) {
        manager = LoginProcessManager(id: id, pass: pass, port: nil, host: nil, completion: {isSuccess,error in
        })
        manager?.loginValidateAccount()
    }

    func updatePassword(_ id: String) {
        if !id.isEmpty,let pass = Keychain.shared.accessToken {
            let jid = BareJID("\(id)@ejabberd.edyou.io")
            if let oldPass = AccountManager.getAccountPassword(for: jid), oldPass !=  pass {
                if var account = AccountManager.getAccount(for:jid ) {
                    account.password = pass
                   try? AccountManager.save(account: account, reconnect: true)
                }
            }
        }
    }

    func startCall(jid: BareJID, from account: BareJID, media: CallType) {

        

    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let replyAction = UNTextInputNotificationAction(identifier: "ReplyAction", title: "Reply", options: [])
            let openAppAction = UNNotificationAction(identifier: "OpenAppAction", title: "Open app", options: [.foreground])
            let quickReplyCategory = UNNotificationCategory(identifier: "QuickReply", actions: [replyAction, openAppAction], intentIdentifiers: [], options: [])


            let xmppCategory =
            UNNotificationCategory(identifier: "MESSAGE", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("New message", comment: "notification of incoming message on locked screen"), options: [.customDismissAction])

            UNUserNotificationCenter.current().setNotificationCategories([quickReplyCategory, xmppCategory])

            self.getNotificationSettings()
        }
    }
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    var createdGroups:[JID:XMPPRoomOptions] = [:]
}
