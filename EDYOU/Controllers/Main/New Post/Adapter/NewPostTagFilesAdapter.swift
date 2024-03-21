//
//  NewPostTagFilesAdapter.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit

class NewPostTagFilesAdapter: NSObject {
    weak var tableView: UITableView!
    
    var fileURLs = [URL]()
    var documentsMedia = [Media]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        
        configure()
    }
    
    func configure() {
        tableView.register(PostFileCell.nib, forCellReuseIdentifier: PostFileCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func deleteFileTapped(sender: UIButton) {
        if sender.tag < documentsMedia.count {
            documentsMedia.remove(at: sender.tag)
            fileURLs.remove(at: sender.tag)
            
            tableView.reloadData()
            
            if documentsMedia.count == 0 {
                tableView.isHidden = true
            }
        }
    }
}

extension NewPostTagFilesAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsMedia.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostFileCell.identifier, for: indexPath) as! PostFileCell
        let row = indexPath.row
        
        cell.documentNameLbl.text = fileURLs[row].lastPathComponent
        cell.documentTypeLbl.text = fileURLs[row].pathExtension.uppercased()
        cell.documentSizeLbl.text = fileURLs[row].fileSizeString
        
        cell.deleteDocumentBtn.tag = row
        cell.deleteDocumentBtn.addTarget(self, action: #selector(deleteFileTapped), for: .touchUpInside)
        
        return cell
    }
}
