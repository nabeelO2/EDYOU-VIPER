//
// ConversationLogController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine
import CoreLocation
import MapKit

class ConversationLogController: UIViewController, ConversationDataSourceDelegate, UITableViewDataSource {
    
    public static let REFRESH_CELL = Notification.Name("ConversationCellRefresh");
    
    private let firstRowIndexPath = IndexPath(row: 0, section: 0);

    @IBOutlet var tableView: UITableView!;
    
    let dataSource = ConversationDataSource();

    var conversation: Conversation!;
        
    weak var conversationLogDelegate: ConversationLogDelegate?;

    var refreshControl: UIRefreshControl?;

    private let newestVisibleDateSubject = PassthroughSubject<Date,Never>();

    private var cancellables: Set<AnyCancellable> = [];
    
    var selectedMarkerRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
         dataSource.delegate = self;

        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 160.0;
        tableView.separatorStyle = .none;
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
        
        if let refreshControl = self.refreshControl {
            tableView.addSubview(refreshControl);
        }
        
        conversationLogDelegate?.initialize(tableView: self.tableView);
        
        tableView.dataSource = self;
        
        NotificationCenter.default.addObserver(self, selector: #selector(showEditToolbar), name: NSNotification.Name("tableViewCellShowEditToolbar"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCell(_:)), name: ConversationLogController.REFRESH_CELL, object: nil);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let conversation = self.conversation {
            XmppService.instance.$applicationState.filter({ $0 == .active }).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] _ in
                self?.markAsReadUpToNewestVisibleRow();
            }).store(in: &cancellables);
            newestVisibleDateSubject.onlyGreater().throttledSink(for: 0.5, scheduler: DispatchQueue.main, receiveValue: { date in
                DBChatHistoryStore.instance.markAsRead(for: conversation, before: date);
            });
            dataSource.loadItems(.unread(overhead: 50));
            NotificationManager.instance.dismissAllNotifications(on: conversation.account, with: conversation.jid);
        }
        
        super.viewWillAppear(animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        hideEditToolbar();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.markAsReadUpToNewestVisibleRow();
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource.getItem(at: indexPath.row) else {
            return tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCellIncoming", for: indexPath);
        }
        
//        print("sender : \(item.state.rawValue)")
        switch item.payload {
        case .unreadMessages:
            let cell: ChatTableViewSystemCell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewSystemCell", for: indexPath) as! ChatTableViewSystemCell;
            cell.messageView.text = NSLocalizedString("Unread messages", comment: "conversation log label");
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            return cell;
        case .messageRetracted:
            var id = isContinuation(at: indexPath.row, for: item) ? "ChatTableViewMessageContinuationCell" : "ChatTableViewMessageCell";
            
            let code = item.state.rawValue
            
            switch code {
            case 0,2,4,6:
//                    return .incoming(.displayed);
                print("sender :  .incoming(.displayed)")
                
                break
            case 1,3,5,7,9:
//                    return .outgoing(.sent);
                print("sender : .outgoing(.sent)")
                if id == "ChatTableViewMessageCell"{
                    id = "RChatTableViewMessageCell"
                }
                else{
                    id = "RChatTableViewMessageContinuationCell"
                }
                break
            default:
                assert(false, "Invalid conversation entry state code")
//                    return .outgoing(.sent)
            }
            
            
            let cell: ChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatTableViewCell;
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            cell.setRetracted(item: item);
            
            return cell;
        case .message(let message, let correctionTimestamp):
            if message.starts(with: "/me") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewMeCell", for: indexPath) as! ChatTableViewMeCell;
                cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
                cell.set(item: item, message: message);
                return cell;
            } else {
                
                var id = isContinuation(at: indexPath.row, for: item) ? "ChatTableViewMessageContinuationCell" : "ChatTableViewMessageCell";
                
                let code = item.state.rawValue
                
                switch code {
                case 0,2,4,6:
//                    return .incoming(.displayed);
                    print("sender :  .incoming(.displayed)")
                    
                    break
                case 1,3,5,7,9:
//                    return .outgoing(.sent);
                    print("sender : .outgoing(.sent)")
                    if id == "ChatTableViewMessageCell"{
                        id = "RChatTableViewMessageCell"
                    }
                    else{
                        id = "RChatTableViewMessageContinuationCell"
                    }
                    break
                default:
                    assert(false, "Invalid conversation entry state code")
//                    return .outgoing(.sent)
                }
                
               
                let cell: ChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatTableViewCell;
                cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
                cell.set(item: item, message: message, correctionTimestamp: correctionTimestamp);
                if let row = selectedMarkerRow, row < indexPath.row, code == 9{
                    cell.setStampImg(11)
                }else{
                    cell.setStampImg(code)
                }
               
                return cell;
            }
        case .location(let location):
            let id = "ChatTableViewLocationCell";
            let cell: LocationChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! LocationChatTableViewCell;
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            cell.set(item: item, location: location);
            return cell;
        case .linkPreview(let url):
            let id = "ChatTableViewLinkPreviewCell";
            let cell: LinkPreviewChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! LinkPreviewChatTableViewCell;
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            cell.set(item: item, url: url);
            return cell;
        case .attachment(let url, let appendix):
            
            var id = isContinuation(at: indexPath.row, for: item) ? "ChatTableViewAttachmentContinuationCell" : "ChatTableViewAttachmentCell" ;
            
            let code = item.state.rawValue
            
            switch code {
            case 0,2,4,6:
//                    return .incoming(.displayed);
                print("sender :  .incoming(.displayed)")
                
                break
            case 1,3,5,7,9:
//                    return .outgoing(.sent);
                print("sender : .outgoing(.sent)")
                if id == "ChatTableViewAttachmentCell"{
                    id = "RChatTableViewAttachmentCell"
                }
                else{
                    id = "ChatTableViewAttachmentContinuationCell"
                }
                break
            default:
                assert(false, "Invalid conversation entry state code")
//                    return .outgoing(.sent)
            }

            let cell: AttachmentChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! AttachmentChatTableViewCell;
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            cell.set(item: item, url: url, appendix: appendix);

                if let row = selectedMarkerRow, row < indexPath.row, code == 9{
                    cell.setStampImg(11)
                }else{
                    cell.setStampImg(code)
                }

//            cell.setNeedsUpdateConstraints();
//            cell.updateConstraintsIfNeeded();
            
            return cell;
        case .invitation(let message, let appendix):
            let id = "ChatTableViewInvitationCell";
            let cell: InvitationChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! InvitationChatTableViewCell;
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            cell.set(item: item, message: message, appendix: appendix);
            return cell;
        case .marker(let type, let senders):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewMarkerCell", for: indexPath) as! ChatTableViewMarkerCell;
            cell.set(item: item, type: type, senders: senders);
            cell.contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0);
            return cell;
        default:
            return tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCellIncoming", for: indexPath);
        }
    }
    
    private func getPreviousEntry(before row: Int) -> ConversationEntry? {
        guard row >= 0 && (row + 1) < dataSource.count else {
            return nil;
        }
        return dataSource.getItem(at: row + 1);
    }
    
    private func isContinuation(at row: Int, for entry: ConversationEntry) -> Bool {
        guard let prevEntry = getPreviousEntry(before: row) else {
            return false;
        }
        switch prevEntry.payload {
        case .messageRetracted, .message(_, _), .attachment(_, _):
            return entry.isMergeable(with: prevEntry);
        case .marker(_, _), .linkPreview(_):
            return isContinuation(at: row + 1, for: entry);
        default:
            return false;
        }
    }
    
    func beginUpdates() {
        tableView.beginUpdates();
    }
    
    func endUpdates() {
        tableView.endUpdates();
    }
    
    func itemsAdded(at rows: IndexSet, initial: Bool) {
        let paths = rows.map({ IndexPath(row: $0, section: 0) });
        tableView.insertRows(at: paths, with: initial ? .none : .fade)
    }
    
    func itemsUpdated(forRowIndexes rows: IndexSet) {
        let paths = rows.map({ IndexPath(row: $0, section: 0) });
        tableView.reloadRows(at: paths, with: .fade)
        markAsReadUpToNewestVisibleRow();
    }
    
    func itemUpdated(indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade);
        tableView.insertRows(at: [indexPath], with: .fade);
        markAsReadUpToNewestVisibleRow();
    }

    func isVisible(row: Int) -> Bool {
        return tableView.indexPathsForVisibleRows?.contains(where: { $0.row == row }) ?? false;
    }
    
    func scrollRowToVisible(_ row: Int) {
        tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .none, animated: true);
    }
    
    func itemsRemoved(at rows: IndexSet) {
        let paths = rows.map({ IndexPath(row: $0, section: 0)});
        tableView.deleteRows(at: paths, with: .fade);
    }
    
    func itemsReloaded() {
        tableView.reloadData();
        markAsReadUpToNewestVisibleRow();
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //super.scrollViewDidScroll(scrollView);
        markAsReadUpToNewestVisibleRow();
    }
    
    func markAsReadUpToNewestVisibleRow() {
        if let visibleRows = tableView.indexPathsForVisibleRows {
            if visibleRows.contains(IndexPath(row: 0, section: 0)) {
                self.dataSource.trimStore();
            }
            
            if UIApplication.shared.applicationState == .active, let newestVisibleUnreadTimestamp = visibleRows.compactMap({ index -> Date? in
                guard let item = dataSource.getItem(at: index.row) else {
                    return nil;
                }
                
                if let cell = tableView.cellForRow(at: index) as? BaseChatTableViewCell{
                    if let newCell = cell as? ChatTableViewCell{
                    
//                        newCell.setStampImg(11)
                    }
                }
               
                return item.timestamp;
            }).max() {
                newestVisibleDateSubject.send(newestVisibleUnreadTimestamp);
            }
        }
    }

    func markAsReadUpToIndex(_ index: Int) {
        print(index)
        //index 2
//        let oldIndexs = dataSource.count - index
//        for newIndex in index...dataSource.count{
//            if let cell = tableView.cellForRow(at: IndexPath(row: newIndex, section: 0)) as? ChatTableViewCell{
//                cell.setStampImg(11)
//            }
//        }
        
        selectedMarkerRow = index
        tableView.reloadData()
        
        
    }
    
    func reloadVisibleItems() {
        if let indexPaths = self.tableView.indexPathsForVisibleRows {
            self.tableView.reloadRows(at: indexPaths, with: .none);
        }
    }
        
    @objc func refreshCell(_ notification: Notification) {
        guard let cell = notification.object as? UITableViewCell, let idx = tableView.indexPath(for: cell) else {
            return;
        }
        
        tableView.reloadRows(at: [idx], with: .automatic);
    }
    
    private var tempRightBarButtonItem: UIBarButtonItem?;
}

extension ConversationLogController {
    
    private var withTimestamps: Bool {
        get {
            return Settings.copyMessagesWithTimestamps;
        }
    };
        
    @objc func editCancelClicked() {
        hideEditToolbar();
    }
    
    func showMap(item: ConversationEntry) {
        guard case let .location(coordinate) = item.payload else {
            return;
        }
        let placemark = MKPlacemark(coordinate: coordinate);
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000);
        let item = MKMapItem(placemark: placemark);
        item.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ])
    }
    
    func copySelectedMessages() {
        copyMessageInt(paths: tableView.indexPathsForSelectedRows ?? []);
        hideEditToolbar();
    }

    @objc func shareSelectedMessages() {
        shareMessageInt(paths: tableView.indexPathsForSelectedRows ?? []);
        hideEditToolbar();
    }

    func copyMessageInt(paths: [IndexPath]) {
        getTextOfSelectedRows(paths: paths, withTimestamps: false) { (texts) in
            UIPasteboard.general.strings = texts;
            UIPasteboard.general.string = texts.joined(separator: "\n");
        };
    }
    
    func shareMessageInt(paths: [IndexPath]) {
        getTextOfSelectedRows(paths: paths, withTimestamps: withTimestamps) { (texts) in
            let text = texts.joined(separator: "\n");
            let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil);
            let visible = self.tableView.indexPathsForVisibleRows ?? [];
            if let firstVisible = visible.first(where:{ (indexPath) -> Bool in
                return paths.contains(indexPath);
                }) ?? visible.first {
                activityController.popoverPresentationController?.sourceRect = self.tableView.rectForRow(at: firstVisible);
                activityController.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: firstVisible);
                self.navigationController?.present(activityController, animated: true, completion: nil);
            }
        }
    }
    
    @objc func showEditToolbar(_ notification: Notification) {
        guard let cell = notification.object as? UITableViewCell else {
            return;
        }

        DispatchQueue.main.async {
            self.view.endEditing(true);
                let selected = self.tableView?.indexPath(for: cell);
                UIView.animate(withDuration: 0.3) {
                    self.tableView?.isEditing = true;
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        self.tableView?.selectRow(at: selected, animated: false, scrollPosition: .none);
                    }
                
                    self.tempRightBarButtonItem = self.conversationLogDelegate?.navigationItem.rightBarButtonItem;
                    self.conversationLogDelegate?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ConversationLogController.editCancelClicked));
                    self.conversationLogDelegate?.navigationController?.navigationBar.tintColor = R.color.buttons_green() ?? .red
                    let timestampsSwitch = TimestampsBarButtonItem();
                    self.conversationLogDelegate?.navigationController?.toolbar.tintColor = UIColor.systemTintColor;
                    let items = [
                        
                        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                        UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ConversationLogController.shareSelectedMessages))
                        //                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    ];
                
                    self.conversationLogDelegate?.navigationController?.setToolbarHidden(false, animated: true);
                    self.conversationLogDelegate?.setToolbarItems(items, animated: true);
                }
        }
    }
        
    func hideEditToolbar() {
        UIView.animate(withDuration: 0.3) {
            self.conversationLogDelegate?.navigationController?.setToolbarHidden(true, animated: true);
            self.conversationLogDelegate?.setToolbarItems(nil, animated: true);
            if let temp = self.tempRightBarButtonItem {
                self.conversationLogDelegate?.navigationItem.rightBarButtonItem = temp;
            }
            self.tempRightBarButtonItem = nil;
            self.tableView?.isEditing = false;
        }
    }
    
    func getTextOfSelectedRows(paths: [IndexPath], withTimestamps: Bool, handler: (([String]) -> Void)?) {
        let items: [ConversationEntry] = paths.map({ index in dataSource.getItem(at: index.row)! }).sorted { (it1, it2) -> Bool in
              it1.timestamp.compare(it2.timestamp) == .orderedAscending;
        };
        
        let withoutPrefix = Set(items.map({it in it.state.direction})).count == 1;
    
        let formatter = DateFormatter();
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd.MM.yyyy jj:mm", options: 0, locale: NSLocale.current);
    
        let texts = items.compactMap({ (it) -> String? in
            switch it.payload {
            case .message(let message, _):
                let prefix = withoutPrefix ? "" : "\(it.sender.nickname ?? "") ";
                if withTimestamps {
                    return "\(formatter.string(from: it.timestamp)) \(prefix)\(message)"
                } else {
                    return "\(prefix)\(message)"
                }
            case .location(let location):
                let prefix = withoutPrefix ? "" : "\(it.sender.nickname ?? "") ";
                if withTimestamps {
                    return "\(formatter.string(from: it.timestamp)) \(prefix)\(location.geoUri)"
                } else {
                    return "\(prefix)\(location.geoUri)"
                }
            default:
                return nil;
            }
        });
            
        handler?(texts);
    }

    class TimestampsBarButtonItem: UIBarButtonItem {
        
        var value: Bool {
            get {
                Settings.copyMessagesWithTimestamps;
            }
            set {
                Settings.copyMessagesWithTimestamps = newValue;
                updateTimestampSwitch();
            }
        }
        
        override init() {
            super.init();
            self.style = .plain;
            self.target = self;
            self.action = #selector(switchWithTimestamps)
            self.updateTimestampSwitch();
        }
        
        required init?(coder: NSCoder) {
            return nil;
        }
        
        @objc private func switchWithTimestamps() {
            value = !value;
        }
        
        private func updateTimestampSwitch() {
            image = UIImage(systemName: value ? "clock.fill" : "clock");
            title = nil;
        }
    }
}

protocol ConversationLogDelegate: AnyObject {
 
    var navigationItem: UINavigationItem { get }
    var navigationController: UINavigationController? { get }
    
    func initialize(tableView: UITableView);
    
    func setToolbarItems(_ toolbarItems: [UIBarButtonItem]?,
                         animated: Bool);
}
