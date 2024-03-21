//
// BaseChatViewControllerWithDataSource.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class BaseChatViewControllerWithDataSource: BaseChatViewController, ConversationLogDelegate  {
                
    private(set) var dataSource: ConversationDataSource!;
    
    override var conversationLogController: ConversationLogController? {
        didSet {
            dataSource = conversationLogController?.dataSource;
            conversationLogController?.conversationLogDelegate = self;
        }
    }
    
    func initialize(tableView: UITableView) {
    }

}
