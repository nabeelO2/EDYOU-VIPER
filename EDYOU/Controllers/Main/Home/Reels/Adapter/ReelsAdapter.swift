//
//  ReelsAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 11/08/2022.
//

import Foundation
import UIKit
import AVFoundation

class ReelsAdapter: NSObject {
    var collectionView: UICollectionView
    private var currentPlayer: AVPlayer?
    var reels: [Reels] = [] {
        didSet {
            self.reloadData()
        }
    }
    var reelsCount: Int {
        return reels.count
    }
    var parent: ReelsViewController
    // to play first video
    var firstTimePlay: Bool = false
    init(collectionView: UICollectionView, parent: ReelsViewController) {
        self.parent = parent
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ReelsCollectionViewCell.nib, forCellWithReuseIdentifier: ReelsCollectionViewCell.identifier)
        
    }
    
    func resetAdapted() {
        self.currentPlayer?.pause()
        self.currentPlayer = nil
        self.firstTimePlay = false
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
}

extension ReelsAdapter : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReelsCollectionViewCell.identifier, for: indexPath) as! ReelsCollectionViewCell
        cell.setData(data: self.reels[indexPath.row], index: indexPath, action: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reelsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width , height: frameSize.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ReelsCollectionViewCell else { return }
        if indexPath.row == 0 && !firstTimePlay {
            firstTimePlay = true
            self.currentPlayer = cell.playVideoFromStart()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ReelsCollectionViewCell else { return }
            print("Begin:" + cell.description)
            cell.resetAvPlayer()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = collectionView.frame.size.height;
        let currentPage = collectionView.contentOffset.y / pageHeight;
        var activePage = 0
        if (0.0 != fmodf(Float(currentPage), 1.0)) {
            activePage = Int(currentPage + 1)
        }
        else {
            activePage = Int(currentPage)
        }
        collectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ReelsCollectionViewCell else { return }
            print("Ended AT:" + (cell.description))
            if cell.index.row == activePage {
                print("Played:" + (cell.description))
                self.currentPlayer = cell.playVideoFromStart()
            }
        }
    }
}

extension ReelsAdapter: ReelsCollectionViewActions {
    func likeAndDislikeReels(reel: Reels, index: IndexPath) {
        guard let userId = Cache.shared.user?.userID else { return }
        guard let cell = collectionView.cellForItem(at: index) as? ReelsCollectionViewCell else { return }
        let like = !(reel.likes?.contains(userId) ?? false)
        APIManager.social.likeDislikeVideo(videoId: reel.videoId ?? "", like: like) { error in
            if let error = error {
                self.parent.showErrorWith(message: error.message)
            } else {
                reel.manageLikeDislike(userId: userId, like: like)
                cell.manageLikeDislike(reel: reel)
            }
        }
    }
    
    func showReelsComments(reel: Reels) {
        self.parent.showCommentsOfReel(reel: reel)
    }
}

// MARK: - View Appear/ Disappear Management
extension ReelsAdapter {
    func handleViewDisappear() {
        self.currentPlayer?.pause()
    }
    func handleViewAppear() {
        self.currentPlayer?.play()
    }
}
