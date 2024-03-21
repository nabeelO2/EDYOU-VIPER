//
//  
//  CalendarEventsAdapter.swift
//  EDYOU
//
//  Created by  Mac on 09/11/2021.
//
//

import UIKit

class CalendarEventsAdapter: NSObject {
    
    // MARK: - Properties
    weak var tableView: UITableView!
    
    var events: [Event] = []
    
    
    var parent: CalendarController? {
        return tableView.viewContainingController() as? CalendarController
    }
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(CalendarEventCell.nib, forCellReuseIdentifier: CalendarEventCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - Utility Methods
extension CalendarEventsAdapter {
    
    @objc func didTapEventLikeButton(_ sender: UIButton) {
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
                
                self.tableView.reloadData()
            }
        }
    }
    
}


// MARK: - TableView DataSource and Delegates
extension CalendarEventsAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarEventCell.identifier, for: indexPath) as! CalendarEventCell
        cell.setData(events[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = events.object(at: indexPath.row) {
            let controller = EventDetailsController(event: event)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - APIs
extension CalendarEventsAdapter {
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
