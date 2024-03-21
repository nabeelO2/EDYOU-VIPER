//
//  EventsFactory.swift
//  EDYOU
//
//  Created by Moghees on 20/06/2022.
//

import Foundation
import EmptyDataSet_Swift


class EventsFactory {
    
    var tableView: UITableView!
    weak var delegate: PostCellActions?
    
    init(tableView: UITableView){
        self.tableView = tableView
        registerCells()
    }
    
    func registerCells(){
        self.tableView.register(EventTableCell.nib, forCellReuseIdentifier: EventTableCell.identifier)
        self.tableView.register(EmptyTableCell.nib, forCellReuseIdentifier: EmptyTableCell.identifier)
    }
    func numberOfSections() -> Int {
        return 0
    }
    
    func tableView(numberOfRowsInSection section: Int, events: [Event], showSkelton: Bool = false) -> Int {
        if showSkelton {
            return 5
        }
        switch events.count == 0 {
        case true:
            return 1
        case false:
            return events.count
        }
    }
    
    func tableView(heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    func getCell(events: [Event], indexPath: IndexPath, totalRecord: Int, showSkeleton: Bool = false) -> UITableViewCell {
        
        if showSkeleton {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableCell.identifier, for: indexPath) as! EventTableCell
            cell.beginSkeltonAnimation()
            return cell
        }
        
        switch events.count == 0 {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableCell.identifier, for: indexPath) as! EmptyTableCell
            cell.setConfiguration(configuration: EmptyCellConfirguration.events)
            return cell
        case false:
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: EventTableCell.identifier, for: indexPath) as! EventTableCell
            cell.setData(event)
            return cell
        }
    }
    
}


