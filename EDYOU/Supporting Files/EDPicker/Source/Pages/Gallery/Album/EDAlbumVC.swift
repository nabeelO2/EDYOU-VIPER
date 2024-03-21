//
//  YPAlbumVC.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos

class EDAlbumVC: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
         return EDConfig.hidesStatusBar
    }
    
    var didSelectAlbum: ((EDAlbum) -> Void)?
    var albums = [EDAlbum]()
    let albumsManager: EDAlbumsManager
    
    let v = EDAlbumView()
    override func loadView() { view = v }
    
    required init(albumsManager: EDAlbumsManager) {
        self.albumsManager = albumsManager
        super.init(nibName: nil, bundle: nil)
        title = EDConfig.wordings.albumsTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: EDConfig.wordings.cancel,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(close))
        navigationItem.leftBarButtonItem?.setFont(font: EDConfig.fonts.leftBarButtonFont, forState: .normal)
        navigationController?.navigationBar.titleTextAttributes = [.font: EDConfig.fonts.navigationBarTitleFont,
                                                                   .foregroundColor: EDConfig.colors.albumTitleColor]
        navigationController?.navigationBar.barTintColor = EDConfig.colors.albumBarTintColor
        navigationController?.navigationBar.tintColor = EDConfig.colors.albumTintColor
        setUpTableView()
        fetchAlbumsInBackground()
    }
    
    func fetchAlbumsInBackground() {
        v.spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.albums = self?.albumsManager.fetchAlbums() ?? []
            DispatchQueue.main.async {
                self?.v.spinner.stopAnimating()
                self?.v.tableView.isHidden = false
                self?.v.tableView.reloadData()
            }
        }
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpTableView() {
        v.tableView.isHidden = true
        v.tableView.dataSource = self
        v.tableView.delegate = self
        v.tableView.rowHeight = UITableView.automaticDimension
        v.tableView.estimatedRowHeight = 80
        v.tableView.separatorStyle = .none
        v.tableView.register(EDAlbumCell.self, forCellReuseIdentifier: "AlbumCell")
    }
}

extension EDAlbumVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = albums[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? EDAlbumCell {
            cell.thumbnail.backgroundColor = .ypSystemGray
            cell.thumbnail.image = album.thumbnail
            cell.title.text = album.title
            cell.numberOfItems.text = "\(album.numberOfItems)"
            return cell
        }
        return UITableViewCell()
    }
}

extension EDAlbumVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAlbum?(albums[indexPath.row])
    }
}
