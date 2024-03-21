//
//  PostPrivacyAdapter.swift
//  EDYOU
//
//  Created by  Mac on 28/09/2021.
//

import Foundation
import UIKit
import PanModal

class PostPrivacyAdapter: NSObject {
    
    // MARK: - Properties
    var parent: PostPrivacyDropDownController? {
        return tableView.viewContainingController() as? PostPrivacyDropDownController
    }
    weak var tableView: UITableView!
    
    var settings: [PostPrivacy] = [.friends, .closeFriends, .friendsExcept, .mySchoolOnly, .public , .groups]
    var selectedIndex = 0
    var selectedSetting: PostPrivacy {
        get {
            return settings.object(at: selectedIndex) ?? .public
        }
        set {
            if let index = settings.firstIndex(of: newValue) {
                selectedIndex = Int(index)
            }
        }
    }
    var selectedFriends = [User]()
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(PostSettingsDescriptionCell.nib, forCellReuseIdentifier: PostSettingsDescriptionCell.identifier)
        tableView.register(PostPrivacyCell.nib, forCellReuseIdentifier: PostPrivacyCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension PostPrivacyAdapter {
}


// MARK: - TableView DataSource and Delegates
extension PostPrivacyAdapter: UITableViewDataSource, UITableViewDelegate {
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
            cell.lblTitle.text = "Who can see your post?"
            cell.lblDescription.text = "Friends, you decide who can see your post, stories, and Uclips. You can post to the Public, which everyone can see, or post to only your friends and Groups so only your friends will see. EDYOU provides you the choice of who sees your content. The current default setting is set for Public."
            cell.closeButton.addTarget(self, action: #selector(closePostPrivacyVC), for: .touchUpInside)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: PostPrivacyCell.identifier, for: indexPath) as! PostPrivacyCell
        cell.lblSetting.text = settings[indexPath.row].name
        cell.imgCheckMark.isHidden = indexPath.row != selectedIndex
        cell.imgIcon.image = settings[indexPath.row].icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedIndex = indexPath.row
            tableView.reloadData()
            
            if selectedSetting == .closeFriends || selectedSetting == .friendsExcept {
                let controller = SelectFriendsController { friends in
                    self.selectedFriends = friends
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.parent?.dismiss(animated: true, completion: {
                            self.parent?.delegate.friendPrivacy(self.selectedSetting, self.selectedFriends)
                        })
                    }
                }
                self.parent?.present(controller, animated: true, completion: nil)
            } else if selectedSetting == .groups {
                self.handleGroupSelection()
            }
            else {
                self.parent?.dismiss(animated: true, completion: {
                    self.parent?.delegate.friendPrivacy(self.selectedSetting, self.selectedFriends)
                })
            }
        }
    }
    
    @objc func closePostPrivacyVC() {
        parent?.dismiss(animated: true, completion: nil)
    }
    private func handleGroupSelection() {
        self.showGroupsForAdapater()
    }
}
extension PostPrivacyAdapter :  TagGroupVCDelegate {
    
    func showGroupsForAdapater() {
        let tagGroupVC = TagGroup()
        tagGroupVC.delegate = self
        self.parent?.presentPanModal(tagGroupVC)
    }
    
    func updateTaggedGroup(group: Group?) {
        guard let group = group else {
            return
        }
        self.parent?.delegate.groupSelected(group: group)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.parent?.dismiss(animated: true, completion: nil)
        })
    }
}
