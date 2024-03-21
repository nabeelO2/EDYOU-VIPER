//
//  SelectLocationAdapter.swift
//  Carzly
//
//  Created by Zuhair Hussain on 28/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import UIKit

class SelectLocationAdapter: NSObject {
    
    weak var tableView: UITableView!
    var parent: SelectLocationController? {
        return tableView.viewContainingController() as? SelectLocationController
    }
    var tableViewMaxHeight: CGFloat = 300
    var tableData = [LocationModel]()
    
    init(with tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        
        tableView.register(LocationCell.nib, forCellReuseIdentifier: LocationCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
}

// MARK: - Utility Methods
extension SelectLocationAdapter {
    func reloadTableData() {
        tableView.reloadData()
        let h = CGFloat(tableData.count) * 66
        parent?.cstTableViewHeight.constant = h > tableViewMaxHeight ? tableViewMaxHeight : h
        parent?.view.layoutIfNeeded(true)
    }
}

// MARK: - TableView DataSource and Delegate
extension SelectLocationAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
        cell.setData(tableData[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = tableData[indexPath.row]
        tableData = []
        parent?.setLocation(location)
        reloadTableData()
    }
}

extension SelectLocationAdapter {
    func getLocations(text: String) {
        LocationManager.shared.getGooglePlaces(text: text) { [weak self] (locations, error) in
            guard let self = self else { return }
            
            let text = self.parent?.txtSearch.text?.trimmed ?? ""
            if error == nil && text != "" {
                self.tableData = locations
            } else {
                self.tableData = []
            }
            self.reloadTableData()
        }
    }
}
