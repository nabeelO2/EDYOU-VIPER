//
//  NewPostEventsAdapter.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit

class NewPostEventsAdapter: NSObject {
    weak var tableView: UITableView!
    
    var event: Event!
    
    var textColor: UIColor = .black {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        
        configure()
    }
    
    func configure() {
        tableView.register(PostEventTableViewCell.nib, forCellReuseIdentifier: PostEventTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

extension NewPostEventsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (event != nil) {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostEventTableViewCell.identifier, for: indexPath) as! PostEventTableViewCell
        
        if let event = event {
            cell.setData(event)
        }
        
        return cell
    }
}
