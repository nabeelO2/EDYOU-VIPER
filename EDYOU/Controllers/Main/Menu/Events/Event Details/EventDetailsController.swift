//
//  EventDetailsController.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit
import EventKit

class EventDetailsController: BaseController {
    
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var eventOwnerImage: UIImageView!
    
    @IBOutlet weak var zoomOrInpersonAddressLbl: UILabel!
    @IBOutlet weak var linkOrInpersonImage: UIImageView!
    @IBOutlet weak var eventTypeImage: UIImageView!
    @IBOutlet weak var lblEventType: UILabel!
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var imgBookmark: UIImageView!
    
    @IBOutlet weak var imgGoing: UIImageView!
    @IBOutlet weak var imgInterested: UIImageView!
    @IBOutlet weak var imgNotGoig: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var user1Image: UIImageView!
    @IBOutlet weak var user2Image: UIImageView!
    @IBOutlet weak var user3Image: UIImageView!
    @IBOutlet weak var user4Image: UIImageView!
    @IBOutlet weak var totalUsersView: UIView!
    @IBOutlet weak var lblTotalRemainingGoingUser: UILabel!
    
    @IBOutlet weak var lblGoings: UILabel!
    @IBOutlet weak var lblGoingUserNames: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCategoryChat: UILabel!
    @IBOutlet weak var lblEventDressType: UILabel!
    @IBOutlet weak var stackJoinerProfile: UIStackView!
    @IBOutlet weak var imgGuestList: UIImageView!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var constBottomBarHeight: NSLayoutConstraint!
    @IBOutlet weak var constScrollBottom: NSLayoutConstraint!
    @IBOutlet weak var vBottomView: UIView!
    var event: Event
    var eventsAdapter : EventsAdapter!
    private var GOING_TAG = 4
    // MAKR: - ViewController Methods
    
    init(event: Event) {
        self.event = event
        super.init(nibName: EventDetailsController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.event = Event(event: EventBasic.init())
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getEventDetails()
    }
    
    func setData() {
        guard let userId = Cache.shared.user?.userID else { return }
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        imgCover.setImage(url: event.coverImages?.first, placeholder: R.image.event_placeholder_Rectangle())
        lblEventType.text  = " \(e.name) "
        lblTitle.text = event.inviterName
        if (lblTitle.text == "") {
            lblTitle.text = event.owner?.name?.firstName ?? "Me"
        }
        
        eventOwnerImage.setImage(url: event.owner?.profileImage, placeholder: R.image.profile_image_dummy())
        eventOwnerImage.contentMode = .scaleAspectFill
        lblCategory.text = "  \(event.category.rawValue)  "
        lblCategoryChat.text = "  \(event.category.rawValue)  "
        lblDescription.text = event.eventDescription
        zoomOrInpersonAddressLbl.text = e == .online ? self.event.meetingLink.asStringOrEmpty() : self.event.eventLocationAddress
        if self.event.isIAmAdmin {
            self.imgGuestList.image = R.image.arrowRight()
        } else {
            self.imgGuestList.image = event.guestListVisible.asBoolOrFalse() ? R.image.arrowRight() : R.image.ic_lock_guest()
        }
        
        lblEventTitle.text = event.eventName
        lblEventDressType.text = event.dressCode
        eventTypeImage.image = e.joiningTypeImage
        linkOrInpersonImage.image = e.linkOrAddress
        lblDate.text = event.formattedStartDate
        
        let eventGoing = event.checkMeGoing(userId: userId)
        imgGoing.image = eventGoing.image
        imgGoing.tintColor = eventGoing.going ? R.color.edYouGreen() : R.color.sub_title()
        
        let notInterested = event.checkMeInterested(userId: userId)
        imgInterested.image = notInterested.image
        imgInterested.tintColor = notInterested.going ? R.color.edYouGreen() : R.color.sub_title()
        
        let notGoing = event.checkMeNotGoing(userId: userId)
        imgNotGoig.image = notGoing.image
        imgNotGoig.tintColor = notGoing.going ? R.color.edYouGreen() : R.color.sub_title()
        self.showJoinerProfile()
        self.handleFavoriteUI()
        self.handleBottomBar()
    }
    
    private func handleBottomBar() {
        self.vBottomView.isHidden = self.event.isIAmAdmin
        self.constBottomBarHeight.constant = self.event.isIAmAdmin ? 0 : 110
        self.constScrollBottom.constant = self.event.isIAmAdmin ? 0 : 80
    }
    
    private func showJoinerProfile() {
        self.resetJoinedProfile()
        var iterationCount = self.event.peoplesProfile?.going?.count ?? 0
        iterationCount = iterationCount < 5 ? iterationCount : 5
        let remainingCount = (self.event.peoplesProfile?.going?.count ?? 0) - iterationCount
        var joinerList: [String] = []
        for tagValue in 0 ..< iterationCount {
            let view = self.stackJoinerProfile.viewWithTag(tagValue + 1)
            view?.isHidden = false
            if let imageView = view as? UIImageView {
                let profileUrl = self.event.peoplesProfile?.going?[tagValue].profileImage
                imageView.setImage(url: profileUrl, placeholder: R.image.profile_image_dummy())
                joinerList.append(self.event.peoplesProfile?.going?[tagValue].name?.firstName ?? "")
            }
            if tagValue == GOING_TAG {
                self.lblTotalRemainingGoingUser.text = "\(remainingCount)+"
            }

        }
        self.setJoiningMemebersName(memeber: joinerList, totalCount: self.event.peoplesProfile?.going?.count ?? 0)
    }
    private func resetJoinedProfile() {
        self.setJoiningMemebersName(memeber: [], totalCount: 0)
        self.stackJoinerProfile.arrangedSubviews.forEach { v in
            v.isHidden = true
        }
    }
    func setJoiningMemebersName(memeber: [String], totalCount: Int) {
        lblGoingUserNames.text = memeber.count == 0 ? "Waiting for users to join" : memeber.joined(separator: ",")
        if totalCount == 0 {
            lblGoings.text = "No members joined yet"
        } else if totalCount == 1 {
            lblGoings.text = "\(totalCount) member is going"
        } else {
            lblGoings.text = "\(totalCount) members are going"
        }
    }
    func handleFavoriteUI(){
        self.btnFavorite.isSelected = event.isFavorite.asBoolOrFalse()
    }
}

// MAKR: - Actions
extension EventDetailsController {
    @IBAction func didTapAddToCalendar(_ sender: Any) {
        //Check permission first
        EKEventStore().requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                CalendarEventCreater.shared.addEventToCalender(event: self.event, completionHandler: { (success) -> Void in
                    
                    // Event saved successfully, post event to server
                    if success {
                        self.addEventToCalendar()
                    } else {
                        self.showErrorWith(message: "Failed to save event")
                    }
                })
            } else {
                self.showErrorWith(message: "Please allow the app save calendar events")
            }
        }
    }
    
    @IBAction func didTapEventTypeAddress(_ sender: Any) {
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        
        if (e == .online) {
            // redirect to zoom url
        } else {
            // for now do nothing its user address
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapAllGuestsButton(_ sender: UIButton) {
        if self.event.guestListVisible.asBoolOrFalse() || self.event.isIAmAdmin {
            self.handleGuestListDisplay(option: PeopleProfileTypes.guestListTypes)
        }
    }
    
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        let isAdmin = event.peoplesProfile?.admins?.contains(where: { $0.userID == Cache.shared.user?.userID })
        
        let adminOptions = ["Edit", "Manage", "Delete Event"]
        let adminOptionsImages = ["edit-group", "icon-settings", "trash-icon"]
        
        let isFavourite = event.isFavorite == true ? "Remove from Favourite" : "Add to Favourite"
        let memberOptions = [isFavourite]
        let memberOptionsImages = ["favourite_event"]
        
        if isAdmin == true {
            let controller = GroupManageOptionsController(options: adminOptions, optionImages: adminOptionsImages, screenName: "", completion: { selected in
                if (selected == "Edit") {
                    let controller = CreateEventController()
                    controller.eventEdit = true
                    controller.event = self.event
                    self.navigationController?.pushViewController(controller, animated: true)
                } else if (selected == "Manage") {
                    self.handleGuestListDisplay(option: PeopleProfileTypes.manageList)
                } else {
                    // delete event
                    let alert = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete the event?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                        self.deleteEvent()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            self.presentPanModal(controller)
        } else {
            let controller = GroupManageOptionsController(options: memberOptions, optionImages: memberOptionsImages, screenName: "", completion: { selected in
                if self.event.isFavorite == true {
                    self.unfavorite(eventId: self.event.eventID ?? "")
                } else {
                    self.favorite(eventId: self.event.eventID ?? "")
                }
            })
            
            self.presentPanModal(controller)
        }
    }
    
    @IBAction func didTapGoingButton(_ sender: UIButton) {
        let isGoing = event.peoplesProfile?.going?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isGoing == true ? .maybe : .going
        self.updateEventInterest(eventAction: action)
    }
    
    @IBAction func didTapInterestedButton(_ sender: UIButton) {
        let isInterested = event.peoplesProfile?.interested?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isInterested == true ? .maybe : .interested
        self.updateEventInterest(eventAction: action)
        return
    }
    
    @IBAction func didTapNotGoingButton(_ sender: UIButton) {
        let isNotGoing = event.peoplesProfile?.notGoing?.contains(where: { $0.userID == Cache.shared.user?.userID })
        let action: EventAction = isNotGoing == true ? .maybe : .notGoing
        self.updateEventInterest(eventAction: action)
    }

    func updateEventInterest(eventAction: EventAction) {
        update(event: event, action: eventAction) { status in
            if status {
                self.getEventDetails()
            }
        }
    }
    
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        if self.event.isFavorite == true {
            self.unfavorite(eventId: self.event.eventID ?? "")
        } else {
            self.favorite(eventId: self.event.eventID ?? "")
        }
    }
    
}

// MAKR: - ScrollView Delegates
extension EventDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

// MAKR: - ScrollView Delegates
extension EventDetailsController {
    func favorite(eventId: String) {
        APIManager.social.addToFavorite(type: .events, id: eventId) { [weak self] error in
            self?.handleFavoriteResponse(favorite: true, error: error)
        }
    }
    func unfavorite(eventId: String) {
        APIManager.social.removeFromFavorite(type: .events, id: eventId) { [weak self] error in
            self?.handleFavoriteResponse(favorite: false, error: error)
        }
    }
    private func handleFavoriteResponse(favorite: Bool , error: ErrorResponse?) {
        if let error = error {
            self.showErrorWith(message: error.message)
        } else {
            self.event.isFavorite = favorite
        }
        self.handleFavoriteUI()
    }
    
    func getEventDetails() {
        guard let id = event.eventID else { return }
        APIManager.social.eventDetails(eventId: id) { basicEvent, error in
            if let error = error {
                self.showErrorWith(message: error.message)
                return
            }
            //Basic event is different from event
            guard let basicEvent = basicEvent else {
                return
            }
            self.event = Event(event: basicEvent)
            self.setData()

        }
    }
    
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.showErrorWith(message: error!.message)
            }
            self.sendNotificationToRefreshList()
            completion(error == nil)
        }
    }
    
    func addEventToCalendar() {
        APIManager.social.addEventToCalendar(data: self.event) { response, error in
            if error == nil {
                self.showSuccessMessage(message: "Event added to calendar successfully")
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func deleteEvent() {
        self.startLoading(title: "Deleting Event...")
        APIManager.social.deleteEvent(eventId: self.event.eventID ?? "") { error in
            self.stopLoading()
            if error == nil {
                self.sendNotificationToRefreshList()
            }
            
            for controller in (self.navigationController?.viewControllers ?? []) {
                if controller is EventsController {
                    self.navigationController?.popToViewController(controller, animated: true)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func sendNotificationToRefreshList() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EventsController.EventRefreshNotification), object: nil, userInfo: nil)
    }
}

// MARK: - GuestList / Manage Display
extension EventDetailsController {
    func handleGuestListDisplay(option: [PeopleProfileTypes]) {
        let controller = EventGuestListController(event: event, options: option)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
