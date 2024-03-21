//
//  NotificationCategoryAdapater.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/11/2022.
//

import UIKit

protocol PropertyDescriptionProtocol {
    var propertyDescription: String { get }
    var id: String { get }
}

enum NotificationCategory: Int, CaseIterable, PropertyDescriptionProtocol {
    case all = 0
    case friendRequests
    case comment
    case react
    case group
    case event
    
    var propertyDescription: String {
        switch self {
        case .all:
            return "All"
        case .friendRequests:
            return "Friends Requests"
        case .comment:
            return "Comment"
        case .react:
            return "React"
        case .group:
            return "Group"
        case .event:
            return "Events"
        }
    }
    var id: String {
        return "\(self.rawValue)"
    }
}

protocol NotificationCategoryAdapterProtocol {
    func notificationCategoryChanged(category: PropertyDescriptionProtocol)
}

class NotificationCategoryAdapater: NSObject {
    
    var collectionView: UICollectionView
    var delegate: NotificationCategoryAdapterProtocol
    var data:[PropertyDescriptionProtocol]
    var selectedCategory: PropertyDescriptionProtocol
    
    internal init(collectionView: UICollectionView, delegate: NotificationCategoryAdapterProtocol, data: [PropertyDescriptionProtocol] , selectedCategory: PropertyDescriptionProtocol) {
        self.collectionView = collectionView
        self.delegate = delegate
        self.data = data
        self.selectedCategory = selectedCategory
        super.init()
        self.configureCollectionView()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func configureCollectionView() {
        self.collectionView.register(NotificationCategoryCell.nib, forCellWithReuseIdentifier: NotificationCategoryCell.identifier)
    }
    
    func reloadCategories() {
        self.collectionView.reloadData()
    }
}

extension NotificationCategoryAdapater: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCategoryCell.identifier, for: indexPath) as! NotificationCategoryCell
        let category = self.data[indexPath.row]
        cell.setData(category:category, selected: category.id == self.selectedCategory.id)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = self.data[indexPath.row]
        self.delegate.notificationCategoryChanged(category: self.selectedCategory)
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = self.data[indexPath.row].propertyDescription
        return CGSize(width: category.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)]).width + 15, height: 26)
    }
}
