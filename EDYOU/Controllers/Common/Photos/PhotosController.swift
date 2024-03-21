//
//  PhotosController.swift
//  EDYOU
//
//  Created by  Mac on 23/09/2021.
//

import UIKit

class PhotosController: BaseController {

    @IBOutlet weak var collectionView: UICollectionView!
    var adapter: PhotosAdapter!
    @IBOutlet var tabButtons: [UIButton]!
    
    var images = [MediaAsset]()
    var videos = [MediaAsset]()
    
    enum Tab: Int {
        case image = 0
        case video = 1
    }
    var selectedTab: Tab = .image
    
    
    enum MediaType {
        case group, profile
    }
    
    var id = ""
    var type: MediaType = .group
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = PhotosAdapter(collectionView: collectionView)
        
        if type == .group {
            getGroupMedia()
        } else {
            getProfileMedia()
        }
    }
    
    
    init(id: String, type: MediaType) {
        super.init(nibName: PhotosController.name, bundle: nil)
        
        
        self.id = id
        self.type = type
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    @IBAction func didTapTabButton(_ sender: UIButton) {
        tabButtons.forEach { $0.setTitleColor(R.color.sub_title(), for: .normal) }
        sender.setTitleColor(R.color.buttons_green(), for: .normal)
        selectedTab = Tab(rawValue: sender.tag) ?? .image
        setData()
    }
    func setData() {
        if selectedTab == .image {
            adapter.media = images
        } else {
            adapter.media = videos
        }
        self.collectionView.reloadData()
    }
}

extension PhotosController {
    func getGroupMedia() {
        APIManager.social.getGroupMedia(groupId: id) { media, error in
            
            self.adapter.isLoading = false
            if error == nil {
                self.images = (media?.images ?? []).map({ PostMedia(url: $0, type: .image) })
                self.videos = (media?.videos ?? []).map({ PostMedia(url: $0, type: .video) })
                self.setData()
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.collectionView.reloadData()
            
            
        }
    }
    func getProfileMedia() {
        APIManager.social.getProfileMedia(userId: id) { media, error in
            
            self.adapter.isLoading = false
            if error == nil {
                self.images = (media?.images ?? []).map({ PostMedia(url: $0, type: .image) })
                self.videos = (media?.videos ?? []).map({ PostMedia(url: $0, type: .video) })
                self.setData()
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.collectionView.reloadData()
            
        }
    }
}
