//
//  PhotosFactory.swift
//  EDYOU
//
//  Created by Admin on 20/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation
import UIKit

enum PhotosSections: Int, CaseIterable {
    case header
    case collection
    var cells : Int {
        switch self {
        case .header:
            return 1
        case .collection:
            return 0
        }
    }
}

class PhotosFactory{
    
    var type: ProfilePhotosType = .all
    var tableView:UITableView
    var media = [MediaAsset]()
    weak var delegate:PhotoHeaderActions?
    init(tableView:UITableView){
        self.tableView = tableView
        registerCells()
    }
    
    
    private func registerCells(){
        tableView.register(PhotosSegmentTableCell.nib, forCellReuseIdentifier: PhotosSegmentTableCell.identifier)
        tableView.register(PhotosCollectionTableCell.nib, forCellReuseIdentifier: PhotosCollectionTableCell.identifier)
    }
    func updateDelegate(delegate: PhotoHeaderActions) {
        self.delegate = delegate
    }
    
    func numberOfSections() -> Int {
        return 0
    }
    
    func tableView(numberOfRowsInSection section: Int) -> Int {
        return PhotosSections.allCases.count
    }
    
    func getPhotosCell(photos: [MediaAsset], videos: [MediaAsset],isLoading:Bool, indexPath: IndexPath) -> UITableViewCell {
        let section = PhotosSections(rawValue: indexPath.row)
        if section == .header{
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotosSegmentTableCell.identifier, for: indexPath) as! PhotosSegmentTableCell
            cell.delegate = self
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
        }
        if section == .collection {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotosCollectionTableCell.identifier, for: indexPath) as! PhotosCollectionTableCell
            cell.setupData(photos: photos, videos: videos, isLoading: isLoading)
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            return cell
        }
        return UITableViewCell()
    }
}
extension PhotosFactory:PhotoHeaderActions{
    func photoSegmentChanged(type: ProfilePhotosType) {
        self.type = type
    }
    
    
}
