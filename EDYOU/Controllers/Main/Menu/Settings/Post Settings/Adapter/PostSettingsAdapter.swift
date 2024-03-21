//
//  
//  PostSettingsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//
//

import UIKit

class PostSettingsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    var parent : PostSettingsDropDownController!
    var settings: [PostSettings] = [.oneDay, .sevenDays, .thirtyDays, .sixtyDays, .never, .saveToMyPhone]
    var selectedIndex = 0
    var selectedSetting: PostSettings {
        get {
            return settings.object(at: selectedIndex) ?? .oneDay
        }
        set {
            if let index = settings.firstIndex(of: newValue) {
                selectedIndex = Int(index)
            }
        }
    }
    
    // MARK: - Initializers
    init(tableView: UITableView, parent: PostSettingsDropDownController? = nil) {
        super.init()
        
        self.tableView = tableView
        self.parent = parent
        configure()
    }
    func configure() {
        tableView.register(PostSettingsDescriptionCell.nib, forCellReuseIdentifier: PostSettingsDescriptionCell.identifier)
        tableView.register(PostSettingsCell.nib, forCellReuseIdentifier: PostSettingsCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension PostSettingsAdapter {
}


// MARK: - TableView DataSource and Delegates
extension PostSettingsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostSettingsDescriptionCell.identifier, for: indexPath) as! PostSettingsDescriptionCell
            
            cell.closeButton.addTarget(self, action: #selector(closePostSettingScreenBtn), for: .touchUpInside)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PostSettingsCell.identifier, for: indexPath) as! PostSettingsCell
        cell.lblSetting.text = settings[indexPath.row].name
        cell.imgCheckMark.isHidden = indexPath.row != selectedIndex
        return cell
    }
    
    @objc func closePostSettingScreenBtn() {
        if (parent != nil) {
            parent.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedIndex = indexPath.row
            tableView.reloadData()
            
            if (parent != nil) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.parent.dismiss(animated: true, completion: {
                        self.parent.completion?(self.selectedSetting)
                    })
                }
            }
        }
    }
}
