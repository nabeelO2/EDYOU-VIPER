//
//  NewPostGroupsAdapter.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit

class NewPostGroupsAdapter: NSObject {
    weak var tableView: UITableView!
    
    var group : [Group] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
        tableView.register(NewGroupCell.nib, forCellReuseIdentifier: NewGroupCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

extension NewPostGroupsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.group.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
        cell.setData(group[indexPath.row], forCreatePost: true)
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

