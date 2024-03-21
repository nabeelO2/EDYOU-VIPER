//
//  ReelsCommentsAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 07/09/2022.
//

import Foundation
import UIKit

class ReelsCommentsAdapater : NSObject {
    var tableView: UITableView
    var reels: Reels
    var comments: [Comment] {
        return self.reels.comments ?? []
    }
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    
    init(tableView: UITableView, reels: Reels) {
        self.tableView = tableView
        self.reels = reels
        super.init()
        self.registerTableViewCell()
    }
    
    func registerTableViewCell() {
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ReelsCommentsAdapater: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        cell.setDataForReels(self.comments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
