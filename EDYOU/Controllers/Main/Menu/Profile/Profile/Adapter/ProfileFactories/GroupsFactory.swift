//
//  GroupsFactory.swift
//  EDYOU
//
//  Created by Admin on 20/06/2022.
//  Copyright © 2022 Moghees. All rights reserved.
//

import Foundation
import UIKit

class GroupsFactory {
    
    var tableView: UITableView!
    weak var delegate: PostCellActions?
    var groups: [Group] = []
    
    var parent: ProfileController? {
        return tableView.viewContainingController() as? ProfileController
    }
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    init(tableView: UITableView){
        self.tableView = tableView
        registerCells()
    }
    
    func registerCells(){
        tableView.register(NewGroupCell.nib, forCellReuseIdentifier: NewGroupCell.identifier)
        self.tableView.register(EmptyTableCell.nib, forCellReuseIdentifier: EmptyTableCell.identifier)
    }
    func numberOfSections() -> Int {
        return 0
    }
    
    func tableView(numberOfRowsInSection section: Int, showSkeleton: Bool = false) -> Int {
        if showSkeleton {
            return 5
        }
        switch groups.count == 0 {
        case true:
            return 1
        case false:
            return groups.count
        }
    }
    
    func getCell(indexPath: IndexPath, totalRecord: Int , showSkeleton: Bool = false) -> UITableViewCell {
        if showSkeleton {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
            cell.beginSkeltonAnimation()
            return cell
        }
        
        switch groups.count == 0 {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath) as! EmptyTableCell
            cell.setConfiguration(configuration: .group)
            return cell
        case false:

            let group = groups[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: NewGroupCell.identifier, for: indexPath) as! NewGroupCell
            cell.setData(group)
            cell.btnViewGroupActivity.addTarget(self, action: #selector(navigateToDetailView(sender:)), for: .touchUpInside)
            cell.btnViewGroupActivity.tag = indexPath.row
            return cell
        }
    }
    @objc func navigateToDetailView(sender: UIButton) {
        if groups.count == 0 {
            return
        }
        if let g = groups.object(at: sender.tag) {
            let controller = GroupDetailsController(group: g)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
