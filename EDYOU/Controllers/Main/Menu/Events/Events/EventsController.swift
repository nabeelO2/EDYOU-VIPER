//
//  EventsController.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit



class EventsController: BaseController {
    
    // MARK: - Controls
    @IBOutlet weak var eventChoiceLbl: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var cstCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var eventCategoryCollectionView: UICollectionView!
    @IBOutlet weak var myEventsHeader: UIView!
    @IBOutlet weak var popularEventsHeader: UIView!
    
    // MARK: - Properties
    var adapter: EventsAdapter!
    var query: EventQuery = .public
    var events = [Event]()
    var myEvents = [Event]()
    var goingEvents = [Event]()
    var notGoingEvents = [Event]()
    var interestedEvents = [Event]()
    var iAmInvitedEvents = [Event]()
    var selectedFilter: Filter = .iAmIn
    var options = ["Events i am going", "Events i created", "Events i am invited", "My favourite events"]
    
    static var EventRefreshNotification = "ReloadApiAfterEventCreated"
    
    enum Filter: String {
        case iCreated, iAmIn, invitations, myFavourite
        
        var name : String {
            switch self {
            case .iAmIn: return "i am going"
            case .myFavourite: return "my favourite"
            case .iCreated: return "i created"
            case .invitations: return "i am invited"
            }
        }
        
        var selectedOption : String {
            switch self {
            case .iAmIn: return "Events i am going"
            case .myFavourite: return "My favourite events"
            case .iCreated: return "Events i created"
            case .invitations: return "Events i am invited"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = EventsAdapter(collectionView: collectionView, eventCategoryCollectionView: eventCategoryCollectionView)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: EventsController.EventRefreshNotification), object: nil, queue: nil) { notification in
            self.loadViewData()
        }
        self.loadViewData()
        txtSearch.delegate = self
    }
    
    func loadViewData() {
        self.getEvents()
        self.getMyEvents()
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstCollectionViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstCollectionViewBottom.constant = 0
        }
        view.layoutIfNeeded(true)
    }
    
    func changeLayout(selectedTab: EventQuery) {
        if (selectedTab == .me) {
            self.popularEventsHeader.isHidden = true
            self.myEventsHeader.isHidden = false
            if (selectedFilter == .iAmIn) {
                self.adapter.events = self.goingEvents
            } else if (selectedFilter == .myFavourite) {
                self.adapter.events = self.interestedEvents
            } else if (selectedFilter == .iCreated) {
                self.adapter.events = self.myEvents
            } else if (selectedFilter == .invitations) {
                self.adapter.events = self.iAmInvitedEvents
            }
            self.adapter.search(self.txtSearch.text ?? "")
        } else {
            self.popularEventsHeader.isHidden = false
            self.myEventsHeader.isHidden = true
        }
        
        self.query = selectedTab
        self.eventCategoryCollectionView.reloadData()
        self.collectionView.reloadData()
    }
}

extension EventsController {
    @IBAction func didTapEventsChoiceButton(_ sender: UIButton) {
        // show user choice filters
        let previousSelectedOption = self.selectedFilter.selectedOption
        let userEventFilter = ReusbaleOptionSelectionController(options: options, previouslySelectedOption: previousSelectedOption, screenName: "My Events", completion: { selected in
            if (selected.contains("going")) {
                self.selectedFilter = .iAmIn
                self.eventChoiceLbl.text = self.selectedFilter.name
                self.adapter.events = self.goingEvents
            } else if (selected.contains("created")) {
                self.selectedFilter = .iCreated
                self.eventChoiceLbl.text = self.selectedFilter.name
                self.adapter.events = self.myEvents
            } else if (selected.contains("invited")) {
                self.selectedFilter = .invitations
                self.eventChoiceLbl.text = self.selectedFilter.name
                self.adapter.events = self.iAmInvitedEvents
            } else if (selected.contains("favourite")) {
                self.selectedFilter = .myFavourite
                self.eventChoiceLbl.text = self.selectedFilter.name
                self.adapter.events = self.interestedEvents
            }
            self.adapter.search(self.txtSearch.text ?? "")
            self.adapter.eventsCollectionView.reloadData()
        })
        self.presentPanModal(userEventFilter)
    }
    
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCreateButton(_ sender: UIButton) {
        let controller = CreateEventController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        txtSearch.becomeFirstResponder()
        viewSearch.showView()
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        view.endEditing(true)
        viewSearch.hideView()
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")

    }
    
    @IBAction func didTapClearButton(_ sender: UIButton) {
        txtSearch.text = ""
        btnClear.isHidden = true
        adapter.search("")
    }
}

// MARK: TextField Delegate
extension EventsController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let expectedText = textField.expectedText(changeCharactersIn: range, replacementString: string)
        btnClear.isHidden = expectedText.count == 0
        adapter.search(expectedText)
        return true
        
    }
}

// MARK: - APIs
extension EventsController {
    func getEvents() {
        APIManager.social.getEvents(query: query) { [weak self] events, error in
            guard let self = self else { return }
            self.adapter.isLoading = false
            if error == nil {
                self.events = events ?? []
                self.adapter.events = self.events
                self.adapter.search(self.txtSearch.text ?? "")
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.refreshAdapater()
        }
    }
    
    func getMyEvents() {
        APIManager.social.getMyEvents(query: .me) { [weak self] eventsIAmGoing, eventsICreated, eventsIAmNotGoing, eventsIAmInvited, eventsIAmInterested, error  in
            guard let self = self else { return }
            self.adapter.isLoading = false
            if error == nil {
                self.myEvents = eventsICreated ?? []
                self.goingEvents = eventsIAmGoing ?? []
                self.notGoingEvents = eventsIAmNotGoing ?? []
                self.interestedEvents = eventsIAmInterested ?? []
                self.iAmInvitedEvents = eventsIAmInvited ?? []
            } else {
//                self.showErrorWith(message: error!.message)
            }
            self.refreshAdapater()
        }
    }
    
    func refreshAdapater() {
        self.changeLayout(selectedTab: self.query)
    }
}
