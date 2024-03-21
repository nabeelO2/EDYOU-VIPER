//
//  ReelsPostAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 11/09/2022.
//

import Foundation
import UIKit
import PanModal

class ReelsPostAdapter: NSObject {
    
    var reelsFilters = ReelsPostOptions.allCases.map { option in
        FilterOptions(image: option.image, title: option.title, isSwitch: option.filterType == FilterType.boolean, switchValue: false, value: option.defaultValue, filterType: option.filterType)
    }
    
    var tableView: UITableView!
    var request: ReelsCreateRequest!
    var parent: ReelsPostViewController!
    
    init(tableView: UITableView, request: ReelsCreateRequest, controller: ReelsPostViewController) {
        self.tableView = tableView
        self.request = request
        self.parent = controller
        super.init()
        self.configureTableCell()
    }
    
    func configureTableCell() {
        //        self.tableView.register
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(FilterReusableTableViewCell.nib, forCellReuseIdentifier: FilterReusableTableViewCell.identifier)
        self.tableView.register(FilterReusableShowResultsTableViewCell.nib, forCellReuseIdentifier: FilterReusableShowResultsTableViewCell.identifier)
    }
    func reloadTable() {
        self.tableView.reloadData()
    }
}

extension ReelsPostAdapter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reelsFilters.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterReusableTableViewCell.identifier, for: indexPath) as! FilterReusableTableViewCell
        let option = reelsFilters[indexPath.row]
        cell.setData(option: option)
        cell.filtersDelegate = self
        cell.switchOption.tag = indexPath.row
        if option.filterType == .boolean {
            cell.switchOption.isOn = option.switchValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = ReelsPostOptions(rawValue: indexPath.row)!
        if option.filterType == .dropdown {
            self.handleDropDowns(option: option, indexPath: indexPath)
        }
    }
    
    private func handleDropDowns(option: ReelsPostOptions, indexPath: IndexPath) {
        let userEventFilter = ReusbaleOptionSelectionController(options: option.subOptions, previouslySelectedOption: "", screenName: option.title,completion: { selected in
            if option == .categories {
                self.request.category = selected
            }
            if option == .location {
                self.request.location = selected
            }
            if option == .privacy {
                self.request.privacy = selected == ReelsPrivacy.public.description ? ReelsPrivacy.public.serverValue : ReelsPrivacy.friends.serverValue
            }
            self.reelsFilters[indexPath.row].value = selected
            self.reelsFilters[indexPath.row].valueChanged = true
            self.tableView.reloadData()
        }, shouldShowPanWithoutBackground: true , dynamicContentHeight: 400)
        self.parent.presentPanModal(userEventFilter)
    }
}

extension ReelsPostAdapter: FilterReusableProtocol {
    func switchValueChanged(indexPathRow: Int, value: Bool) {
        let option = ReelsPostOptions(rawValue: indexPathRow)!
        if option == .saveToGallery {
            self.request.saveToGallery = value
        }
        if option == .allowComments {
            self.request.allowComments = value
        }
        self.reelsFilters[indexPathRow].switchValue = value
        self.reelsFilters[indexPathRow].valueChanged = true
        self.tableView.reloadData()
    }
    
    func dateValueAdded(indexPathRox: Int, date: String) {
        
    }
    func textFieldValueAdded(indexPathRox: Int, textFieldText: String) {
        
    }
    func textFieldStartEditing(_ starts: Bool) {
        
    }
}
