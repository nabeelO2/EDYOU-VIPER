//
//  
//  ShowStoriesAdapter.swift
//  EDYOU
//
//  Created by  Mac on 05/10/2021.
//
//

import UIKit

class ShowStoriesAdapter: NSObject, StoryCellDelegate {
    
    func setCurrentStoryIndex(currenIndex: Int) {
        parent?.currentStoryIndex = currenIndex
    }
    
    func endProgressOfStories() {
        if (((self.parent?.presentedViewController?.isKind(of: ReusbaleOptionSelectionController.self))) != nil)  {
            self.parent?.dismiss(animated: true)
        }
    }
    
    func bottomMenuUpdate(isHidden: Bool) {
        parent?.bottomBgV.isHidden = isHidden
        parent?.reactionStack.isHidden = isHidden
    }
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: ShowStoriesController? {
        return collectionView.viewContainingController() as? ShowStoriesController
    }
    
    var currentPage = 0
    var stories = [Story]()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(StoryCell.nib, forCellWithReuseIdentifier: StoryCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    func openEmojiController()
    {
        pauseStory()
       
        self.parent?.showEmojiController(true,completion: { selected in
            //MARK:  API call here
            self.resumeStory()
            if !selected.isEmpty{
                
                
                if let postId = self.parent?.getCurrentPost()?.postID{
                    APIManager.social.addReaction(postId: postId, isAdd: true, reaction: selected) { [weak self] (error) in
                        guard let self = self else { return }
                        if error == nil {

                        }
                    }
                }

            }
        })
        
        
    }
    func stopProgress()
    {
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.identifier, for: visibleIndexPath) as! StoryCell
            cell.timer?.invalidate()
        }
    }
    func stopVideo()
    {
        
        let visibleRect = collectionView.visibleCells
        let cell = visibleRect.first as? StoryCell
        cell?.cleanUpCell()
        
//        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.identifier, for: visibleIndexPath) as! StoryCell
        print(visibleRect.count)
//            cell.cleanUpCell()
//        }
    }
    
    func pauseStory(){
        
        if let cell = collectionView.visibleCells.first as? StoryCell {
            
            cell.pauseProgress()
            
        }
    }
    
    func resumeStory(){
        
        if let cell = collectionView.visibleCells.first as? StoryCell {
            
            cell.resumeProgress()
            
        }
    }
    
    
    
}


// MARK: - Utility Methods
extension ShowStoriesAdapter {
    @objc func didLongPressCell(_ sender: UILongPressGestureRecognizer) {
        
        if let view = sender.view as? StoryCell {
            
            if sender.state == .began {
                view.pauseProgress()
                view.isChangeProgress = false
            } else if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
                view.resumeProgress()
                view.isChangeProgress = true
            }
            
        }
        
    }
    @objc func didTapCell(_ sender: UITapGestureRecognizer) {
        
        if let view = sender.view as? StoryCell {
            let location = sender.location(in: view)
            
            if location.x < (view.frame.width / 2) {
                view.showPreviousStory()
            } else {
                view.showNextStory() 
            }
        }
    }
    
    
}


// MARK: - CollectionView DataSource and Delegates
extension ShowStoriesAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let top = Application.shared.safeAreaInsets.top
        let bottom = Application.shared.safeAreaInsets.bottom
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - top - (bottom/2) )
        return size
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCell.identifier, for: indexPath) as! StoryCell
        cell.borderColor = .red
        cell.delegate = self
        cell.setData(story: stories[indexPath.row])
        self.parent?.selectedIndex = indexPath.row
        cell.parentView = collectionView
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell(_:))))
//        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell(_:))))
//        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//        tap.numberOfTapsRequired = 2
//        cell.addGestureRecognizer(tap)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? StoryCell
        cell?.cleanUpCell()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        var page = Int(round((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
        page = page < 0 ? 0 : page
        page = page > stories.count ? stories.count : page
        
        if page != currentPage {
            currentPage = page
            let indexPath = IndexPath(row: page, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? StoryCell
            
            cell?.progress = 0
            cell?.timer?.invalidate()
            cell?.showStory()
//            print("scrollViewDidEndDecelerating")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.frame.size.width
        var page = Int(round((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
        page = page < 0 ? 0 : page
        page = page > stories.count ? stories.count : page
        
        if page != currentPage {
            currentPage = page
            let indexPath = IndexPath(row: page, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? StoryCell
            
            cell?.progress = 0
            cell?.timer?.invalidate()
            cell?.showStory()
//            print("scrollViewDidEndScrollingAnimation")
        }
        
    }
}


