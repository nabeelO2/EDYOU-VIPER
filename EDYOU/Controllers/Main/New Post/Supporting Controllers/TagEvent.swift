//
//  TagEvent.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit
import PanModal

protocol TagEventVCDelegate: AnyObject {
    func updateTaggedEvent(event: Event?)
}

class TagEvent: BaseController {
    // MARK: - Outlets
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var events = [Event]()
    var searchedEvents = [Event]()
    weak var delegate: TagEventVCDelegate?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.register(PostEventTableViewCell.nib, forCellReuseIdentifier: PostEventTableViewCell.identifier)
        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.separatorStyle = .none
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getEvents()
    }
    
    // MARK: - Fctions
    func search(_ text: String) {
        let t = text.trimmed.lowercased()
        if t.count > 0 {
            let f = events.filter { $0.eventName?.lowercased().contains(t) == true }
            self.searchedEvents = f
        } else {
            self.searchedEvents = events
        }
        
        eventTableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate?.updateTaggedEvent(event: nil)
        
        if (navigationController?.presentationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension TagEvent : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchedEvents = self.events
        self.eventTableView.reloadData()
    }
}

// MARK: - TableView delegate and datasource
extension TagEvent : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostEventTableViewCell.identifier, for: indexPath) as! PostEventTableViewCell
        
        cell.setData(events[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (navigationController?.presentationController != nil) {
            delegate?.updateTaggedEvent(event: searchedEvents[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.updateTaggedEvent(event: searchedEvents[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension TagEvent {
    func getEvents() {
        APIManager.social.getMyEvents(query: .me) { [weak self] eventsIAmGoing, eventsICreated, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested, error  in
            guard let self = self else { return }
            
            if error == nil {
                self.events = eventsICreated ?? []
                self.searchedEvents = self.events
            } else {
//                self.showErrorWith(message: error!.message)
            }
            
            self.eventTableView.reloadData()
        }
    }
}

extension TagEvent: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return eventTableView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(self.view.frame.height - 50)
    }
}
