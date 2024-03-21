//
//  DataPickerAdapter.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit
import Foundation
class DataPickerAdapter<T:Any>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var selectedItem = -1
    var singleSelection: Bool = false
    
    var parent: DataPickerController<Any>? {
        return tableView.viewContainingController() as? DataPickerController
    }
    var data = [DataPickerItem<T>]()
    var filteredData = [DataPickerItem<T>]()
    
    
    // MARK: - Initializers
    init(tableView: UITableView, data: [DataPickerItem<T>], singleSelection: Bool = false) {
        super.init()
        
        self.tableView = tableView
        self.data = data
        self.filteredData = data
        self.singleSelection = singleSelection
        configure()
    }
    func configure() {
        tableView.register(DataPickerCell.nib, forCellReuseIdentifier: DataPickerCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    func filter(text: String) {
        
        let t = text.lowercased().trimmed
        
        if t.count == 0 {
            self.filteredData = data
        } else {
            filteredData = self.data.filter { $0.title.lowercased().contains(t) }
        }
        tableView.reloadData()
    }
    
    
    // MARK: - TableView DataSource and Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: DataPickerCell.identifier, for: indexPath) as! DataPickerCell
        
        let data = filteredData[indexPath.row]
        
        if let img = data.image {
            cell.imgLogo.image = img
            cell.imgLogo.isHidden = false
        } else if let imgURL = data.imageURL {
            cell.imgLogo.setImage(url: imgURL, placeholder: nil)
            cell.imgLogo.isHidden = false
        } else {
            cell.imgLogo.isHidden = true
        }
        cell.layoutIfNeeded()
        cell.lblTitle.text = data.title
        cell.imgCheckMark.image = data.isSelected ? UIImage(named: "selectedCheck") : UIImage(systemName: "")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < filteredData.count {
            if singleSelection {
                for (index, _) in data.enumerated() {
                    data[index].isSelected = false
                }
                filteredData[indexPath.row].isSelected = true
            } else {
                filteredData[indexPath.row].isSelected = true
            }
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name("dismiss_picker_view"), object: nil)

        }
    }
    
}
