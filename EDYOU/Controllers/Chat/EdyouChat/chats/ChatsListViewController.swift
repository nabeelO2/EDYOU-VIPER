//
// ChatListViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import UserNotifications
import Martin
import Combine
import SwiftMessages

class ChatsListViewController: UIViewController {
    
    @IBOutlet var addMucButton: UIButton!
    @IBOutlet var settingsButton: UIButton!;
    @IBOutlet var tableView: UITableView!;
    @IBOutlet var tabImageViews: [UIImageView]!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet var tabViews: [UIView]!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var cstViewIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var cstViewIndicatorWidth: NSLayoutConstraint!

    var dataSource: ChatsDataSource?;
    private var cancellables: Set<AnyCancellable> = [];
    
    var selectedTab: Tab = .all
    enum Tab: Int {
        case all=1, friends=2, groups=3
    }
    
    override func viewDidLoad() {
        dataSource = ChatsDataSource(controller: self);
        super.viewDidLoad();
        tableView.delegate = self
        tableView.dataSource = self;
        setColors();
        settingsButton.isHidden = true
        #if DEBUG
        settingsButton.isHidden = false
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        DBChatStore.instance.$unreadMessagesCount.throttle(for: 0.1, scheduler: DispatchQueue.main, latest: true).map({ $0 == 0 ? nil : "\($0)" }).sink(receiveValue: { [weak self] value in
            self?.navigationController?.tabBarItem.badgeValue = value;
        }).store(in: &cancellables);
        Settings.$recentsMessageLinesNo.removeDuplicates().receive(on: DispatchQueue.main).sink(receiveValue: { _ in
            self.tableView.reloadData();
        }).store(in: &cancellables);
        animate();
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        appearance.backgroundColor = UIColor(named: "chatslistSemiBackground");
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark);
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = appearance;
        navigationController?.navigationBar.barTintColor = UIColor(named: "chatslistBackground");
        navigationController?.navigationBar.tintColor = UIColor.white;
    }

    override func viewDidDisappear(_ animated: Bool) {
        //cancellables.removeAll();
        super.viewDidDisappear(animated);
    }

    deinit {
        cancellables.removeAll();
        NotificationCenter.default.removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapTabButton(_ sender: UIButton) {
        
        let currentTabView = tabViews.first(where: { $0.tag == sender.tag })
        let prevTabView = tabViews.first(where: { $0.tag == (sender.tag - 1) })
        tabLabels.forEach { $0.textColor = .lightGray }
        tabImageViews.forEach { $0.tintColor = .lightGray }
        let label = tabLabels.first { $0.tag == sender.tag }
        label?.textColor = .green
        let imageView = tabImageViews.first { $0.tag == sender.tag }
        imageView?.tintColor = .green
        
        if sender.tag == 0 {
            cstViewIndicatorLeading.constant = (tabImageViews.first?.frame.origin.x ?? 0)
            cstViewIndicatorWidth.constant =  (tabImageViews.first?.width ?? 0) + 10
        } else {
            cstViewIndicatorLeading.constant = (prevTabView?.frame.origin.x ?? 0) + (prevTabView?.width ?? 0) + 15.0
            cstViewIndicatorWidth.constant = (currentTabView?.width ?? 0)
        }
        selectedTab = Tab(rawValue: sender.tag) ?? .all
        dataSource?.currentTabSelected = selectedTab
        view.layoutIfNeeded(true)
        self.tableView.reloadData()
    }
    
    @IBAction func addMucButtonClicked(_ sender: UIButton) {
        let controller = NewChatController { [weak self] user in
           let userJID = BareJID("\(user.userID ?? "")@ejabberd.edyou.io")
            if let client =  XmppService.instance.connectedClients.first {
                let res =  DBChatStore.instance.createChat(for: client.context, with: userJID,name: user.name?.completeName ?? "")
                switch res {
                    case .created(_),.found(_):
                        print("created")
                        DBChatStore.instance.refreshConversationsList()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            if let conversation = DBChatStore.instance.conversation(for: client.userBareJid, with: userJID) {
                                let controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                                controller.conversation = conversation
                                self?.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    case .none:
                        self?.showErrorWith(message: "unable to intiate Chat try again after some time")
                        return
                }
            } else {
                self?.showErrorWith(message: "Account not Connected To server Please logout and login again")
            }
        }
        self.present(controller.embedInNavigationController, presentationStyle: .fullScreen)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection);
    }
    
    fileprivate func closeBaseChatView(for account: BareJID, jid: BareJID) {
        DispatchQueue.main.async {
            if let navController = self.splitViewController?.viewControllers.first(where: { c -> Bool in
                return c is UINavigationController;
            }) as? UINavigationController, let controller = navController.visibleViewController as? BaseChatViewController {
                if controller.conversation.account == account && controller.conversation.jid == jid {
                    self.showDetailViewController(self.storyboard!.instantiateViewController(withIdentifier: "emptyDetailViewController"), sender: self);
                }
            }
        }
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

    struct ConversationItem: Hashable {
        
        static func == (lhs: ConversationItem, rhs: ConversationItem) -> Bool {
            return lhs.chat.id == rhs.chat.id;
        }
        
        var name: String {
            return chat.displayName;
        }
        let chat: Conversation;
        
        let timestamp: Date;
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(chat.id);
        }
    }
    
    class ChatsDataSource {
        
        weak var controller: ChatsListViewController?;

        fileprivate var dispatcher = DispatchQueue(label: "chats_data_source", qos: .background);
                
        var count: Int {
            self.items.count;
        }
        
        private var items: [ConversationItem] = [];
        private var allItems:[ConversationItem] = []
        private var cancellables: Set<AnyCancellable> = [];
        var currentTabSelected:Tab = .all {
            didSet {
                switch currentTabSelected {
                    case .all:
                        items = allItems
                    case .friends:
                        items = allItems.filter{$0.chat is Chat}
                    case .groups:
                        items = allItems.filter{$0.chat is XMPPRoom}
                }
            }
        }

        init(controller: ChatsListViewController) {
            self.controller = controller;
            DBChatStore.instance.$conversations.throttleFixed(for: 0.1, scheduler: self.dispatcher, latest: true).sink(receiveValue: { [weak self] items in
                self?.update(items: items);
            }).store(in: &cancellables);
        }
        
        func update(items: [Conversation]) {
            var newItems = items.map({ conversation in ConversationItem(chat: conversation, timestamp: conversation.timestamp) }).sorted(by: { (c1,c2) in c1.timestamp > c2.timestamp });
                var oldItems = self.items;
                self.allItems = newItems
            switch currentTabSelected {
                    case .all:

                    break
                    case .friends:
                        oldItems = self.items
                        newItems = newItems.filter{$0.chat is Chat}
                    case .groups:
                        oldItems = self.items
                        newItems = newItems.filter{$0.chat is XMPPRoom}
                }

            let diffs = newItems.difference(from: oldItems).inferringMoves();
            var removed: [Int] = [];
            var inserted: [Int] = [];
            var moved: [(Int,Int)] = [];
            for action in diffs {
                switch action {
                case .remove(let offset, _, let to):
                    if let idx = to {
                        moved.append((offset, idx));
                    } else {
                        removed.append(offset);
                    }
                case .insert(let offset, _, let from):
                    if from == nil {
                        inserted.append(offset);
                    }
                }
            }
            
            guard (!removed.isEmpty) || (!moved.isEmpty) || (!inserted.isEmpty) else {
                return;
            }

            let updateFn = {
                if items.isEmpty {
                    self.items = newItems;
                    self.controller?.tableView.reloadData();
                    return
                }
                self.items = newItems;
                self.controller?.tableView.beginUpdates();
                if !removed.isEmpty {
                    self.controller?.tableView.deleteRows(at: removed.map({ IndexPath(row: $0, section: 0) }), with: .fade);
                }
                for (from,to) in moved {
                    self.controller?.tableView.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0));
                }
                if !inserted.isEmpty {
                    self.controller?.tableView.insertRows(at: inserted.map({ IndexPath(row: $0, section: 0) }), with: .fade);
                }
                self.controller?.tableView.endUpdates();
            }
            DispatchQueue.main.sync {
                updateFn();
            }
        }
                
        func item(at indexPath: IndexPath) -> ConversationItem? {
            return self.items[indexPath.row];
        }
        
        func item(at index: Int) -> ConversationItem? {
            return self.items[index];
        }

    }
}

extension ChatsListViewController : UITableViewDelegate,  UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1;
   }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return dataSource?.count ?? 0;
   }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cellIdentifier = "ChatsListTableViewCellNew"
       let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ChatsListTableViewCell;
       
       if let item = dataSource?.item(at: indexPath) {
           cell.update(conversation: item.chat);
       }
       cell.avatarStatusView.updateCornerRadius();
       
       return cell;
   }
   
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       if let accountCell = cell as? ChatsListTableViewCell {
           accountCell.avatarStatusView.updateCornerRadius();
       }
   }
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       if (indexPath.section == 0) {
           return true;
       }
       return false;
   }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       guard let item = dataSource!.item(at: indexPath)?.chat else {
           return nil;
       }
       
       var actions: [UIContextualAction] = [];
       switch item {
       case let room as XMPPRoom:
           actions.append(UIContextualAction(style: .normal, title: NSLocalizedString("Leave", comment: "button label"), handler: { (action, view, completion) in
               room.context?.module(.pepBookmarks).setConferenceAutojoin(false, for: JID(room.jid))
               room.context?.module(.muc).leave(room: room);
               room.checkTigasePushNotificationRegistrationStatus { (result) in
                   switch result {
                   case .failure(_):
                       break;
                   case .success(let value):
                       guard value else {
                           return;
                       }
                       room.registerForTigasePushNotification(false, completionHandler: { (regResult) in
                           DispatchQueue.main.async {
                               let alert = UIAlertController(title: NSLocalizedString("Push notifications", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("You've left there room %@ and push notifications for this room were disabled!\nYou may need to reenable them on other devices.", comment: "alert body"), room.name ?? room.roomJid.stringValue), preferredStyle: .actionSheet);
                               alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .default, handler: nil));
                               alert.popoverPresentationController?.sourceView = self.view;
                               alert.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath);
                               self.present(alert, animated: true, completion: nil);
                           }
                       })
                   }
               }
               self.discardNotifications(for: room);
               completion(true);
           }))
           if room.affiliation == .owner {
               actions.append(UIContextualAction(style: .destructive, title: NSLocalizedString("Destroy", comment: "button label"), handler: { (action, view, completion) in
                   DispatchQueue.main.async {
                       let alert = UIAlertController(title: NSLocalizedString("Channel destuction", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("You are about to destroy channel %@. This will remove the channel on the server, remove remote history archive, and kick out all participants. Are you sure?", comment: "alert body"), room.roomJid.stringValue), preferredStyle: .actionSheet);
                       alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "button label"), style: .destructive, handler: { action in
                           room.context?.module(.pepBookmarks).remove(bookmark: Bookmarks.Conference(name: item.jid.localPart!, jid: JID(room.jid), autojoin: false));
                           room.context?.module(.muc).destroy(room: room);
                           self.discardNotifications(for: room);
                           completion(true);
                       }));
                       alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "button label"), style: .default, handler: { action in
                           completion(false)
                       }))
                       alert.popoverPresentationController?.sourceView = self.view;
                       alert.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath);
                       self.present(alert, animated: true, completion: nil);
                   }
               }))
           }
       case let chat as Chat:
           actions.append(UIContextualAction(style: .normal, title: NSLocalizedString("Close", comment: "button label"), handler: { (action, view, completion) in
               let result = DBChatStore.instance.close(chat: chat);
               if result {
                   self.discardNotifications(for: chat);
               }
               completion(result);
           }))
       case let channel as Channel:
           actions.append(UIContextualAction(style: .normal, title: NSLocalizedString("Close", comment: "button label"), handler: { (action, view, completion) in
               if let mixModule = channel.context?.module(.mix), let userJid = channel.context?.userBareJid {
                   let leaveFn: ()-> Void = {
                       mixModule.leave(channel: channel, completionHandler: { result in
                           switch result {
                           case .success(_):
                               self.discardNotifications(for: channel);
                               completion(true);
                           case .failure(_):
                               completion(false);
                               break;
                           }
                       });
                   }
                   
                   mixModule.retrieveConfig(for: channel.channelJid, completionHandler: { result in
                       switch result {
                       case .success(let data):
                           if let adminsField: JidMultiField = data.getField(named: "Owner"), adminsField.value.contains(JID(userJid)) && adminsField.value.count == 1 {
                               // you need to pass the permission or delete channel..
                               DispatchQueue.main.async {
                                   let alert = UIAlertController(title: NSLocalizedString("Leaving channel", comment: "leaving channel title"), message: NSLocalizedString("You are the last person with ownership of this channel. Please decide what to do with the channel.", comment: "leaving channel text"), preferredStyle: .actionSheet);
                                   alert.addAction(UIAlertAction(title: NSLocalizedString("Destroy", comment: "button label"), style: .destructive, handler: { _ in
                                       mixModule.destroy(channel: channel.channelJid, completionHandler: { result in
                                           switch result {
                                           case .success(_):
                                               break;
                                           case .failure(let error):
                                               DispatchQueue.main.async {
                                                   let alert = UIAlertController(title: NSLocalizedString("Channel destruction failed!", comment: "alert window title"), message: String.localizedStringWithFormat(NSLocalizedString("It was not possible to destroy channel %@. Server returned an error: %@", comment: "alert window message"), channel.name ?? channel.channelJid.stringValue, error.message ?? error.description), preferredStyle: .alert)
                                                   alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Button"), style: .default, handler: nil));
                                                   self.present(alert, animated: true, completion: nil);
                                               }
                                           }
                                       })
                                   }));
                                   let otherParticipants = channel.participants.filter({ $0.jid != nil && $0.jid != userJid });
                                   if !otherParticipants.isEmpty {
                                       alert.addAction(UIAlertAction(title: NSLocalizedString("Pass ownership", comment: "button label"), style: .default, handler: { _ in
                                           if let navController = UIStoryboard(name: "MIX", bundle: nil).instantiateViewController(withIdentifier: "ChannelSelectNewOwnerViewNavController") as? UINavigationController, let controller = navController.visibleViewController as? ChannelSelectNewOwnerViewController {
                                               controller.channel = channel;
                                               controller.participants = otherParticipants.sorted(by: { p1, p2 in
                                                   return p1.nickname ?? p1.jid?.stringValue ?? p1.id < p2.nickname ?? p2.jid?.stringValue ?? p2.id;
                                               });
                                               controller.completionHandler = { result in
                                                   guard let participant = result, let jid = participant.jid else {
                                                       completion(false);
                                                       return;
                                                   }
                                                   adminsField.value = adminsField.value.filter({ $0.bareJid != userJid }) + [JID(jid)];
                                                   mixModule.updateConfig(for: channel.channelJid, config: data, completionHandler: { _ in
                                                       leaveFn();
                                                   })
                                               }
                                               self.present(navController, animated: true, completion: nil);
                                           }
                                       }));
                                   }
                                   alert.addAction(UIAlertAction(title: NSLocalizedString("Leave", comment: "button label"), style: .default, handler: { _ in
                                       leaveFn();
                                   }))
                                   alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "button label"), style: .cancel, handler: { _ in
                                       completion(false);
                                   }))

                                   alert.popoverPresentationController?.sourceView = self.view;
                                   alert.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath);

                                   self.present(alert, animated: true, completion: nil);
                               }
                           } else {
                               leaveFn();
                           }
                       case .failure(let error):
                           leaveFn();
                       }
                   });
               } else {
                   completion(false);
               }
           }))
           if channel.permissions?.contains(.changeConfig) ?? false {
               actions.append(UIContextualAction(style: .destructive, title: NSLocalizedString("Destroy", comment: "button label"), handler: { (action, view, completion) in
                   DispatchQueue.main.async {
                       let alert = UIAlertController(title: NSLocalizedString("Channel destuction", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("You are about to destroy channel %@. This will remove the channel on the server, remove remote history archive, and kick out all participants. Are you sure?", comment: "alert body"), channel.channelJid.stringValue), preferredStyle: .actionSheet);
                       alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "button label"), style: .destructive, handler: { action in
                           channel.context?.module(.mix).destroy(channel: channel.channelJid, completionHandler: { result in
                               switch result {
                               case .success(_):
                                   self.discardNotifications(for: channel);
                                   completion(true);
                               case .failure(_):
                                   completion(false);
                                   break;
                               }
                           })
                       }));
                       alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "button label"), style: .default, handler: { action in
                           completion(false)
                       }))
                       alert.popoverPresentationController?.sourceView = self.view;
                       alert.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath);
                       self.present(alert, animated: true, completion: nil);
                   }
               }))
           }
       default:
           return nil;
       }
       
       let config = UISwipeActionsConfiguration(actions: actions);
       config.performsFirstActionWithFullSwipe = actions.count == 1;
       return config;
   }
   
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
       guard let item = dataSource!.item(at: indexPath)?.chat else {
           return nil;
       }
       switch item {
       case let chat as Chat:
           return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: contextMenuActionProvider(for: chat));
       default:
           return nil;
       }
   }
   
   private func contextMenuActionProvider(for chat: Chat) -> UIContextMenuActionProvider? {
       return { suggestedActions -> UIMenu? in
           var actions: [UIMenuElement] = [];
           
           if let context = chat.context, let blockingModule = chat.context?.module(.blockingCommand), blockingModule.isAvailable {
               if blockingModule.blockedJids?.contains(JID(chat.jid)) ?? false {
                   actions.append(UIAction(title: NSLocalizedString("Unblock", comment: "context menu action"), image: UIImage(systemName: "hand.raised"), handler: { _ in
                       blockingModule.unblock(jids: [JID(chat.jid)], completionHandler: { _ in })
                   }))
               } else if blockingModule.blockedJids?.contains(JID(chat.jid.domain)) ?? false {
                   actions.append(UIAction(title: NSLocalizedString("Unblock server", comment: "context menu action"), image: UIImage(systemName: "hand.raised"), handler: { _ in
                       let alert = UIAlertController(title: NSLocalizedString("Server is blocked", comment: "alert title - unblock communication with server"), message: String.localizedStringWithFormat(NSLocalizedString("All communication with users from %@ is blocked. Do you wish to unblock communication with this server?", comment: "alert message - unblock communication with server"), chat.jid.domain), preferredStyle: .alert);
                       alert.addAction(UIAlertAction(title: NSLocalizedString("Unblock", comment: "unblock server"), style: .default, handler: { _ in
                           blockingModule.unblock(jids: [JID(chat.jid.domain), JID(chat.jid)], completionHandler: { _ in })
                       }))
                       alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel operation"), style: .cancel, handler: { _ in }))
                       self.present(alert, animated: true);
                   }))
               } else {
                   var items = [UIMenuElement]();
                   if blockingModule.isReportingSupported {
                       items.append(UIAction(title: NSLocalizedString("Report spam", comment: "context menu action"), attributes: .destructive, handler: { _ in
                           blockingModule.block(jid: JID(chat.jid), report: .init(cause: .spam), completionHandler: { _ in });
                       }));
                       
                       items.append(UIAction(title: NSLocalizedString("Report abuse", comment: "context menu action"), attributes: .destructive, handler: { _ in
                           blockingModule.block(jid: JID(chat.jid), report: .init(cause: .abuse), completionHandler: { _ in });
                       }));
                   } else {
                       items.append(UIAction(title: NSLocalizedString("Block contact", comment: "context menu item"), attributes: .destructive, handler: { _ in
                           blockingModule.block(jid: JID(chat.jid), completionHandler: { result in
                               switch result {
                               case .success(_):
                                   _ = DBChatStore.instance.close(chat: chat);
                               case .failure(_):
                                   break;
                               }
                           })
                       }))
                   }
                   items.append(UIAction(title: NSLocalizedString("Block server", comment: "context menu item"), attributes: .destructive, handler: { _ in
                       blockingModule.block(jid: JID(chat.jid.domain), completionHandler: { result in
                           switch result {
                           case .success(_):
                               let blockedChats = DBChatStore.instance.chats(for: context).filter({ $0.jid.domain == chat.jid.domain });
                               for blockedChat in blockedChats {
                                   _ = DBChatStore.instance.close(chat: blockedChat);
                               }
                           case .failure(_):
                               break;
                           }
                       })
                   }))
                   items.append(UIAction(title: NSLocalizedString("Cancel", comment: "context menu action"), handler: { _ in }));
                   actions.append(UIMenu(title: NSLocalizedString("Report & block…", comment: "context action label"), image: UIImage(systemName: "hand.raised"), children: items));
               }
           }
           
           guard !actions.isEmpty else {
               return nil;
           }
           
           return UIMenu(title: "", children: actions);
       }
   }
   
   func discardNotifications(for item: Conversation) {
       let accountStr = item.account.stringValue.lowercased();
       let jidStr = item.jid.stringValue.lowercased();
       UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
           var toRemove = [String]();
           for notification in notifications {
               if (notification.request.content.userInfo["account"] as? String)?.lowercased() == accountStr && (notification.request.content.userInfo["sender"] as? String)?.lowercased() == jidStr {
                   toRemove.append(notification.request.identifier);
               }
           }
           UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: toRemove);
       }
   }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath as IndexPath, animated: true);
       guard let item = dataSource!.item(at: indexPath)?.chat else {
           return;
       }
       var identifier: String!;
       var controller: UIViewController? = nil;
        switch item {
            case is XMPPRoom:
                identifier = "MucChatViewController";
                controller = UIStoryboard(name: "Groupchat", bundle: nil).instantiateViewController(withIdentifier: identifier);
            case is Channel:
                identifier = "ChannelViewController";
                controller = UIStoryboard(name: "MIX", bundle: nil).instantiateViewController(withIdentifier: identifier);
            case is Chat:
                identifier = "ChatViewController";
                controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: identifier);
                break
            default:
                identifier = "ChatViewController";
                controller = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: identifier);
        }
           
       if let baseChatViewController = controller as? BaseChatViewController {
           baseChatViewController.conversation = item;
       }
        controller?.hidesBottomBarWhenPushed = true;

       if controller != nil {
           self.navigationController?.pushViewController(controller!, animated: true);
       }
   }

}
