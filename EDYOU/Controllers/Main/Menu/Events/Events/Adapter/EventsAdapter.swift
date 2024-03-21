//
//  
//  EventsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//
//

import UIKit
import EmptyDataSet_Swift

class EventsAdapter: NSObject {
    
    // MARK: - Properties
    weak var eventsCollectionView: UICollectionView!
    weak var eventCategoryCollectionView: UICollectionView!
    
    var parent: EventsController? {
        return eventsCollectionView.viewContainingController() as? EventsController
    }
    var isLoading = true
    var searchedEvents = [Event]()
    var events = [Event]()
    var eventCategories = ["Filter", "Anytime", "My Events", "Public", "Friends"]
    
    // MARK: - Initializers
    init(collectionView: UICollectionView, eventCategoryCollectionView: UICollectionView?) {
        super.init()
        
        self.eventsCollectionView = collectionView
        self.eventCategoryCollectionView = eventCategoryCollectionView
        configure()
    }
    
    func configure() {
        eventsCollectionView.register(EventCell.nib, forCellWithReuseIdentifier: EventCell.identifier)
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        eventsCollectionView.emptyDataSetSource = self
        eventsCollectionView.emptyDataSetDelegate = self
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: eventsCollectionView.frame.width - 32, height: 140)
        layout2.scrollDirection = .vertical
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout2.headerReferenceSize = CGSize(width: 0, height: 0)
        eventsCollectionView.collectionViewLayout = layout2
        
        eventCategoryCollectionView.register(EventsSubNavBarCellItem.nib, forCellWithReuseIdentifier: EventsSubNavBarCellItem.identifier)
        eventCategoryCollectionView.dataSource = self
        eventCategoryCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 35)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.headerReferenceSize = CGSize(width: 0, height: 0)
        eventCategoryCollectionView.collectionViewLayout = layout
        
        eventCategoryCollectionView.reloadData()
    }
    
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        
        if t.count > 0 {
            let f = events.filter { $0.eventDescription?.lowercased().contains(t) == true || $0.title?.lowercased().contains(t) == true }
            self.searchedEvents = f
        } else {
            self.searchedEvents = events
        }
        
        eventsCollectionView.reloadData()
    }
    
    func applyFilter(timeFilter: Bool = false) {
        if (timeFilter) {
            if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .anyTime {
                self.searchedEvents = events
            } else if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .today {
                let todayDate = Date().toUTC()
                
                let f = events.filter { $0.startTime?.contains(todayDate) == true }
                self.searchedEvents = f
            } else if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .tomorrow {
                guard let tomorrowDate = Date().dateByAdding(days: 1)?.toUTC() else {
                    self.searchedEvents.removeAll()
                    self.eventsCollectionView.reloadData()
                    return
                }
                
                let f = events.filter { $0.startTime?.contains(tomorrowDate) == true }
                self.searchedEvents = f
            } else if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .thisWeek {
                let weekBoundary  = Calendar.currentWeekBoundary(Calendar.current)
                
                let f = events.filter { ($0.startTime?.toDate ?? Date()) > weekBoundary()?.startOfWeek ?? Date() || ($0.startTime?.toDate ?? Date()) < weekBoundary()?.endOfWeek ?? Date() }
                    self.searchedEvents = f
            } else if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .thisWeekend {
                let weekBoundary  = Calendar.currentWeekBoundary(Calendar.current)
                
                let f = events.filter { ($0.startTime?.toDate ?? Date()) == weekBoundary()?.endOfWeek ?? Date() }
                    self.searchedEvents = f
            } else if EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .chooseADate {
                let customDate = AppDefaults.shared.eventFilterCustomDate
                
                let f = events.filter {
                    print($0.startTime ?? "No event date attached")
                    return $0.startTime?.contains(customDate) == true
                }
                self.searchedEvents = f
            }
            
            eventsCollectionView.reloadData()
        } else {
            if AppDefaults.shared.eventTypeFilter.count > 0 {
                let f = events.filter { $0.eventType?.lowercased().contains(AppDefaults.shared.eventTypeFilter) == true
                }
                self.searchedEvents = f
            } else if AppDefaults.shared.eventsCategoryFilter.count > 0 {
                let f = events.filter { $0.eventCategory?.lowercased().contains(AppDefaults.shared.eventsCategoryFilter) == true
                }
                
                self.searchedEvents = f
            } else {
                self.searchedEvents = events
            }

            eventsCollectionView.reloadData()
        }
    }
}

// MARK: - Events Filter delegates
extension EventsAdapter : ApplyEventsFilter, ApplyEventsTimeFilter {
    func applyEventsFilter() {
        applyFilter()
    }
    
    func applyTimeFilter() {
        applyFilter(timeFilter: true)
    }
}

// MARK: - Action
extension EventsAdapter {
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
                
                self.eventsCollectionView.reloadData()
            }
        }
    }
}


// MARK: - CollectionView DataSource and Delegates
extension EventsAdapter: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == eventCategoryCollectionView) {
            return eventCategories.count
        } else {
            return isLoading ? 20 : searchedEvents.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == eventCategoryCollectionView) {
            let itemName = UILabel(frame: CGRect.zero)
            itemName.text = eventCategories[indexPath.row]
            itemName.sizeToFit()
            var width: CGFloat = 0
            
            if (indexPath.row == 0 || indexPath.row == 1) {
                width = itemName.frame.width + 70
            } else {
                width = itemName.frame.width + 40
            }
            
            return CGSize(width: width, height: 35)
        } else {
            return CGSize(width: collectionView.frame.width, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == eventCategoryCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventsSubNavBarCellItem.identifier, for: indexPath) as! EventsSubNavBarCellItem
            let row = indexPath.row
            cell.containerView.backgroundColor = UIColor(hexString: "F3F5F8")
            
            if (row == 0 || row == 1) {
                cell.design(showWithIcons: true, text: self.eventCategories[row])
                
                cell.leadingIcon.image = row == 0 ? R.image.filter_icon() : R.image.calendar_icon()
            } else {
                cell.design(showWithIcons: false, text: self.eventCategories[row])
                
                if (parent?.query == .me && row == 2) {
                    cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
                } else if (parent?.query == .public && row == 3) {
                    cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
                } else if (parent?.query == .friends && row == 4) {
                    cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
                } else if (parent?.query == .group && row == 5) {
                    cell.containerView.backgroundColor = UIColor(hexString: "EBF8EF")
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
            
            if isLoading {
                cell.beginSkeltonAnimation()
            } else {
                cell.setData(searchedEvents[indexPath.row])
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == eventCategoryCollectionView) {
            let row = indexPath.row
            if (row == 0) {
                // open filters
                let controller = EventsFilterViewController()
                controller.delegate = self
                parent?.navigationController?.pushViewController(controller, animated: true)
            } else if (row == 1) {
                // open time filters
                let controller = EventsTimeFilterViewController()
                controller.delegate = self
                parent?.navigationController?.pushViewController(controller, animated: true)
            } else {
                // query events
                if (row == 2) {
                    parent?.changeLayout(selectedTab: .me)
                    return
                } else if (row == 3) {
                    parent?.changeLayout(selectedTab: .public)
                    parent?.getEvents()
                    
                } else if (row == 4) {
                    parent?.changeLayout(selectedTab: .friends)
                    parent?.getEvents()
                } else {
                   
                    parent?.changeLayout(selectedTab: .specific)
                    parent?.getEvents()
                }
            }
        } else {
            if let event = searchedEvents.object(at: indexPath.row) {
                let controller = EventDetailsController(event: event)
                parent?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension EventsAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: EmptyCellConfirguration.events.title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        NSAttributedString(string: "You have no event in list", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold), NSAttributedString.Key.foregroundColor: R.color.sub_title()!])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return EmptyCellConfirguration.events.image
    }
}



extension EventsAdapter {
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
