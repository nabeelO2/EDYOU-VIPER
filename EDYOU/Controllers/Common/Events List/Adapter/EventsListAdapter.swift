//
//  
//  UsersListAdapter.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//
//

import UIKit

class EventsListAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: EventsListController? {
        return collectionView.viewContainingController() as? EventsListController
    }
     var isLoading = true
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
        
    }
    
}


// MARK: - Action
extension EventsListAdapter {
    @objc func didTapLikeButton(_ sender: UIButton) {
        guard let event = events.object(at: sender.tag) else { return }
        let isLiked = event.peoplesProfile?.likes?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isLiked == true ? .leave : .like
        update(event: event, action: action) { status in
            if status {
                if self.events[sender.tag].peoplesProfile == nil {
                    self.events[sender.tag].peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                if action == .like {
                    self.events[sender.tag].peoplesProfile?.likes?.append(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.events[sender.tag].peoplesProfile?.likes?.remove(userId: Cache.shared.user?.userID ?? "")
                }
                
                self.collectionView.reloadData()
            }
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension EventsListAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.restore()
        if events.count == 0 {
            collectionView.addEmptyView("No Event(s)", "You have no event in list", EmptyCellConfirguration.events.image)
        }
        return isLoading ? 20 : events.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 160)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        if isLoading {
            cell.beginSkeltonAnimation()
        } else {
            cell.setData(events[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let event = events.object(at: indexPath.row) {
            let controller = EventDetailsController(event: event)
            parent?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension EventsListAdapter {
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.parent?.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
}

