//
//  EventGuestAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 19/10/2022.
//

import Foundation
import UIKit

class EventGuestAdapater: NSObject {
    var tableView: UITableView
    var collectionView: UICollectionView
    private var event: Event
    private var options: [PeopleProfileTypes]
    private var selectedOption: PeopleProfileTypes!
    
    private var userList: [User] = []
    
    // MARK: - Inititaizers for Cell and Table and Collection
    init(tableView: UITableView, collectionView: UICollectionView, event: Event,options: [PeopleProfileTypes]) {
        self.tableView = tableView
        self.collectionView = collectionView
        self.event = event
        self.options = options
        self.selectedOption = options.first!
        super.init()
        self.configureUserList()
        self.registerTableViewCell()
        self.registerCollectionViewCell()
    }
    
    func registerTableViewCell() {
        tableView.register(UserCell.nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    func registerCollectionViewCell() {
        self.collectionView.register(PeopleTypeCollectionViewCell.nib, forCellWithReuseIdentifier: PeopleTypeCollectionViewCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func reloadData() {
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
}

// MARK: - Data Setter Functions
extension EventGuestAdapater {
    func configureUserList() {
        self.userList = self.event.peoplesProfile?.getUsersFrom(type: self.selectedOption) ?? []
    }
    
    func search(text: String) {
        if text.count > 0 {
            self.userList = self.userList.filter({
                $0.name?.completeName.lowercased().contains(text.lowercased()) == true
            })
        } else {
            self.configureUserList()
        }
        self.tableView.reloadData()
    }
}


extension EventGuestAdapater: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.disableAllOptions()
        cell.setData(self.userList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension EventGuestAdapater: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleTypeCollectionViewCell.identifier, for: indexPath) as! PeopleTypeCollectionViewCell
        let option = self.options[indexPath.row]
        cell.setData(type: option, event: event, selected: self.selectedOption == option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.options.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedOption = self.options[indexPath.row]
        self.configureUserList()
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
}
