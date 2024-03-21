//
//  MediaViewerController.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 13/03/2022.
//

import UIKit
import RealmSwift

class MediaViewerController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var adapter: MediaViewerAdapter!
    
    var media = [MediaAsset]()
    var videos = List<String>()
    var images = List<String>()
    var selectedIndex = 0
    var indexChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = MediaViewerAdapter(collectionView: collectionView)
        adapter.media = media
        adapter.videos = videos
        adapter.images = images
        collectionView.alpha = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if indexChanged == false && selectedIndex < adapter.media.count {
            indexChanged = true
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            collectionView.alpha = 1
        }
        else if indexChanged == false && selectedIndex < (adapter.images.count + adapter.videos.count) {
            indexChanged = true
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            collectionView.alpha = 1
        }
    }
    
    init(media: [MediaAsset], selectedIndex: Int) {
        super.init(nibName: MediaViewerController.name, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .coverVertical
        
        self.media = media
        self.selectedIndex = selectedIndex
    }
    init(video: List<String>, images: List<String>, selectedIndex: Int) {
        super.init(nibName: MediaViewerController.name, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .coverVertical
        
        self.videos = video
        self.images = images
        self.selectedIndex = selectedIndex
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
