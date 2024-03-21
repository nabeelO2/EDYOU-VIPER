//
//  
//  FavFriendsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//
//

import UIKit
//import EmptyDataSet_Swift

class FavEventsAdapter: NSObject {
    
    weak var collectionView: UICollectionView!
    var parent: FavEventsController? {
        return collectionView.viewContainingController() as? FavEventsController
    }
    var isLoading = true
    var searchedEvents = [Event]()
    var events = [Event]()
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(EventCell.nib, forCellWithReuseIdentifier: EventCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.emptyDataSetSource = self
//        collectionView.emptyDataSetDelegate = self
    }
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = events.filter { $0.eventDescription?.lowercased().contains(t) == true || $0.title?.lowercased().contains(t) == true }
            self.searchedEvents = f
        } else {
            self.searchedEvents = events
        }
        collectionView.reloadData()
        
    }
}

extension FavEventsAdapter {
    @objc func didTapLikeButton(_ sender: UIButton) {
        guard let event = searchedEvents.object(at: sender.tag) else { return }
        let isLiked = event.peoplesProfile?.likes?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isLiked == true ? .leave : .like
        update(event: event, action: action) { status in
            if status {
                if self.searchedEvents[sender.tag].peoplesProfile == nil {
                    self.searchedEvents[sender.tag].peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                if action == .like {
                    self.searchedEvents[sender.tag].peoplesProfile?.likes?.append(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.searchedEvents[sender.tag].peoplesProfile?.likes?.remove(userId: Cache.shared.user?.userID ?? "")
                }
                
                let index = self.events.firstIndex { $0.eventID == event.eventID }
                if let i = index {
                    self.events[i] = self.searchedEvents[sender.tag]
                }
                
                self.collectionView.reloadData()
            }
        }
    }
    @objc func didTapMoreButton(_ sender: UIButton) {
        guard let eventId = searchedEvents.object(at: sender.tag)?.eventID else { return }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Remove from Favourite", style: .default, handler: { (_) in
            self.unfavorite(eventId: eventId)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.parent?.present(actionSheet, animated: true, completion: nil)
    }
}


// MARK: - CollectionView DataSource and Delegates
extension FavEventsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.restore()
        if searchedEvents.count == 0 {
            collectionView.addEmptyView("No Event(s)", "You have no favourite event", EmptyCellConfirguration.group.image)
        }
        collectionView.isUserInteractionEnabled = !isLoading
        return isLoading ? 20 : searchedEvents.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 160)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        if isLoading {
//            cell.imgMore.isHidden = true
//            cell.btnMore.isHidden = true
            cell.beginSkeltonAnimation()
        } else {
//            cell.imgMore.isHidden = false
//            cell.btnMore.isHidden = false
//            cell.btnMore.tag = indexPath.row
            
            cell.setData(searchedEvents[indexPath.row])
//            cell.btnMore.tag = indexPath.row
//            cell.btnMore.addTarget(self, action: #selector(didTapMoreButton(_:)), for: .touchUpInside)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let e = searchedEvents.object(at: indexPath.row), isLoading == false {
            let controller = EventDetailsController(event: e)
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

//extension FavEventsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "No Event(s)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .semibold)])
//    }
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        return NSAttributedString(string: "You have no favourite event", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
//    }
//}

extension FavEventsAdapter {
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
    func unfavorite(eventId: String) {
        collectionView.isUserInteractionEnabled = false
        APIManager.social.removeFromFavorite(type: .events, id: eventId) { [weak self] error in
            if error == nil {
                let searchedIndex = self?.searchedEvents.firstIndex(where: { $0.eventID == eventId })
                let index = self?.events.firstIndex(where: { $0.eventID == eventId })
                if let i = searchedIndex {
                    self?.searchedEvents.remove(at: i)
                }
                if let i = index {
                    self?.events.remove(at: i)
                }
                self?.collectionView.reloadData()
            } else {
                self?.parent?.showErrorWith(message: error!.message)
            }
            self?.collectionView.isUserInteractionEnabled = true
        }
    }
}
