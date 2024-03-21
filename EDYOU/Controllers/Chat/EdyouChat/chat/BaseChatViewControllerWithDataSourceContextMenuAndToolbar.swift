//
// BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class BaseChatViewControllerWithDataSourceAndContextMenuAndToolbar: BaseChatViewControllerWithDataSource, UITableViewDelegate {

    fileprivate weak var timestampsSwitch: UIBarButtonItem? = nil;
    
    var contextActions: [ContextAction] = [.showMap, .copy, .reply, .share, .report, .correct, .retract, .moderate];
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIMenuController.shared.menuItems = UIMenuController.shared.menuItems?.filter({ it -> Bool in it.action != #selector(ChatTableViewCell.actionMore(_:))});

        super.viewDidDisappear(animated);
    }
    
    override func initialize(tableView: UITableView) {
        super.initialize(tableView: tableView);
        tableView.delegate = self;
    }
            
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = self.conversationLogController!.dataSource.getItem(at: indexPath.row) else {
            return nil;
        }
        switch item.payload {
            case .message(_,_),.attachment(_,_),.linkPreview(_),.invitation(_,_),.location(_):
                break
            case .deleted,.marker(_, _),.messageRetracted,.unreadMessages:
                return nil
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let cell = self.conversationLogController!.tableView(tableView, cellForRowAt: indexPath);
            cell.contentView.transform = .identity;
            let view = UIViewController();
            let size = self.conversationLogController!.tableView.rectForRow(at: indexPath).size;
            view.view = cell.contentView;
            view.preferredContentSize = size;
            
            return view;
        }) { suggestedActions -> UIMenu? in
            return self.prepareContextMenu(for: indexPath);
        };
    }

//    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
//        animator?.addCompletion {
////            guard let self,
////                  let indexPathToDelete = self.indexPathSelected else {
////                return
////            }
////           self.tableView.deleteRows(at: [indexPathToDelete], with: .automatic)
//            self.indexPathSelected = IndexPath()
//        }
//    }
    
    func prepareContextMenu(for indexPath: IndexPath) -> UIMenu? {
        guard let item = self.conversationLogController!.dataSource.getItem(at: indexPath.row) else {
            return nil;
        }
        let actions = self.contextActions.filter({ self.canExecuteContext(action: $0, forItem: item, at: indexPath) });
        let items: [UIMenuElement] = actions.map({ action -> UIMenuElement in
            if action.isDesctructive {
                return UIMenu(title: action.title, image: action.image, options: .destructive, children: [
                    UIAction(title: NSLocalizedString("No", comment: "context menu action"), handler: { _ in }),
                    UIAction(title: NSLocalizedString("Yes", comment: "context menu action"), attributes: .destructive, handler: { _ in
                        self.executeContext(action: action, forItem: item, at: indexPath);
                    })
                ]);
            } else {
                switch action {
                case .report:
                    return UIMenu(title: action.title, image: action.image, children: [
                        UIAction(title: NSLocalizedString("Report spam", comment: "context menu action"), attributes: .destructive, handler: { _ in
                            self.conversation.context?.module(.blockingCommand).block(jid: JID(self.conversation.jid),
                                                                                      report: .init(cause: .spam), completionHandler: { _ in });
                        }),
                        UIAction(title: NSLocalizedString("Report abuse", comment: "context menu action"), attributes: .destructive, handler: { _ in
                            self.conversation.context?.module(.blockingCommand).block(jid: JID(self.conversation.jid),
                                                                                      report: .init(cause: .abuse), completionHandler: { _ in });
                        }),
                        UIAction(title: NSLocalizedString("Block server", comment: "context menu action - block communication with server"), attributes: [.destructive], handler: { _ in
                            self.conversation.context?.module(.blockingCommand).block(jid: JID(self.conversation.jid.domain), completionHandler: { _ in });
                        }),
                        UIAction(title: NSLocalizedString("Cancel", comment: "context menu action"), handler: { _ in })
                    ])
                default:
                    return UIAction(title: action.title, image: action.image, handler: { _ in
                        self.executeContext(action: action, forItem: item, at: indexPath);
                    })
                }
            }
        })
        
        return UIMenu(title: "", children: items);
    }
    
    public func executeContext(action: ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) {
        switch action {
        case .showMap:
            self.conversationLogController?.showMap(item: item);
        case .copy:
            self.conversationLogController?.copyMessageInt(paths: [indexPath]);
        case .reply:
            // something to do..
            self.conversationLogController?.getTextOfSelectedRows(paths: [indexPath], withTimestamps: false, handler: { [weak self] texts in
                let text: String = texts.flatMap { $0.split(separator: "\n")}.map {
                    if $0.starts(with: ">") {
                        return ">\($0)";
                    } else {
                        return "> \($0)"
                    }
                }.joined(separator: "\n");
                
                if let current = self?.messageText, !current.isEmpty {
                    self?.messageText = "\(current)\n\(text)\n";
                } else {
                    self?.messageText = "\(text)\n";
                }
            })
        case .share:
            self.conversationLogController?.shareMessageInt(paths: [indexPath]);
        case .correct:
            if case .message(let message, _) = item.payload {
                DBChatHistoryStore.instance.originId(for: item.conversation, id: item.id, completionHandler: { [weak self] originId in
                    DispatchQueue.main.async {
                        self?.startMessageCorrection(message: message, originId: originId)
                    }
                });
            }
        case .retract, .moderate:
            // that is per-chat-type sepecific
            break;
        case .more:
            guard let cell = self.conversationLogController?.tableView.cellForRow(at: indexPath) else {
                return;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: Notification.Name("tableViewCellShowEditToolbar"), object: cell);
            }
        case .report:
            // taken care of in `prepareContextMenu(for:)`
            break;
        }
    }
    
    public func canExecuteContext(action: ContextAction, forItem item: ConversationEntry, at indexPath: IndexPath) -> Bool {
        switch action {
        case .showMap:
            guard case .location(_) = item.payload else {
                return false;
            }
            return true;
        case .copy:
            return true;
        case .reply:
            return true;
        case .report:
            return false;
        case .share:
            return true;
        case .correct:
            if item.state.direction == .outgoing, case .message(_,_) = item.payload, !dataSource.isAnyMatching({ it in
                if it.state.direction == .outgoing, case .message(_,_) = it.payload {
                    return true;
                } else {
                    return false;
                }
            }, in: 0..<indexPath.row) {
                return true;
            }
            return false;
        case .retract,.moderate:
            return false;
        case .more:
            return true;
        }
    }
    
    public enum ContextAction {
        case copy
        case reply
        case share
        case report
        case correct
        case retract
        case moderate
        case more
        case showMap
        
        var title: String {
            switch self {
            case .showMap:
                return NSLocalizedString("Show map", comment: "context action label");
            case .copy:
                return NSLocalizedString("Copy", comment: "context action label");
            case .reply:
                return NSLocalizedString("Reply", comment: "context action label");
            case .report:
                return NSLocalizedString("Report & block", comment: "context action label")
            case .share:
                return NSLocalizedString("Share", comment: "context action label");
            case .correct:
                return NSLocalizedString("Edit", comment: "context action label");
            case .retract:
                return NSLocalizedString("Delete", comment: "context action label");
            case .moderate:
                return NSLocalizedString("Moderate", comment: "context action label");
            case .more:
                return NSLocalizedString("More", comment: "context action label");
            }
        }
        
        var image: UIImage? {
            switch self {
            case .showMap:
                return UIImage(systemName: "map")
            case .copy:
                return UIImage(systemName: "doc.on.doc");
            case .reply:
                return UIImage(systemName: "arrowshape.turn.up.left");
            case .report:
                return UIImage(systemName: "hand.raised")
            case .share:
                return UIImage(systemName: "square.and.arrow.up");
            case .correct:
                return UIImage(systemName: "pencil.and.ellipsis.rectangle");
            case .retract:
                return UIImage(systemName: "trash");
            case .moderate:
                return UIImage(systemName: "trash.circle");
            case .more:
                return UIImage(systemName: "ellipsis");
            }
        }
        
        var isDesctructive: Bool {
            switch self {
            case .retract, .moderate:
                return true;
            default:
                return false;
            }
        }
    }
}
