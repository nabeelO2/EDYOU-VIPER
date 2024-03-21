//
//  EventInviteController.swift
//  EDYOU
//
//  Created by Aksa on 02/09/2022.
//

import UIKit
import PanModal

class EventInviteController : BaseController {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var eventOwnerImage: UIImageView!
    
    @IBOutlet weak var zoomOrInpersonAddressLbl: UILabel!
    @IBOutlet weak var linkOrInpersonImage: UIImageView!
    @IBOutlet weak var eventTypeImage: UIImageView!
    @IBOutlet weak var lblEventType: UILabel!
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var user1Image: UIImageView!
    @IBOutlet weak var user2Image: UIImageView!
    @IBOutlet weak var user3Image: UIImageView!
    @IBOutlet weak var user4Image: UIImageView!
    @IBOutlet weak var totalUsersView: UIView!
    @IBOutlet weak var lblTotalRemainingGoingUser: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCategoryChat: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblEventDressType: UILabel!
    
    // MARK: - Variables
    var allInvitedEvents = [Event]()
    var event: Event!
    var currentEventIndex = 0
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        if let firstEvent = allInvitedEvents.first {
            event = firstEvent
            self.setData()
        }
    }
    
    // MARK: - Functions
    func update(event: Event, action: EventAction, completion: @escaping (_ status: Bool) -> Void) {
        guard let id = event.eventID else { return }
        APIManager.social.eventAction(eventId: id, action: action) { error in
            if error != nil {
                self.showErrorWith(message: error!.message)
            }
            completion(error == nil)
        }
    }
    
    func setData() {
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        
        if let imgUrl = event.coverImages?.first {
            imgCover.sd_setImage(with: URL(string: imgUrl), placeholderImage: R.image.profileImagePlaceHolder(), options: [])
        }
        
        lblEventType.text  = " \(e.name) "
        lblTitle.text = event.inviterName
        
        if (lblTitle.text == "") {
            lblTitle.text = event.owner?.name?.firstName ?? "Me"
        }
        
        if let img = event.owner?.profileImage {
            eventOwnerImage.sd_setImage(with: URL(string: img), placeholderImage: R.image.profileImagePlaceHolder(), options: [])
        }
        
        eventOwnerImage.contentMode = .scaleAspectFill
        lblCategory.text = "  \(event.eventCategory ?? "")  "
        lblCategoryChat.text = "  \(event.eventCategory ?? "")  "
        lblDescription.text = event.eventDescription
        
        var address = ""
        
        if let locName = event.location?.locationName {
            address += locName
        }
        
        if let locCity = event.location?.city {
            address += ", " + locCity
        }
        
        if let locCountry = event.location?.country {
            address += ", " + locCountry
        }

        if (address == "") {
            address = "No address"
        }
        
        zoomOrInpersonAddressLbl.text = e == .online ? "Zoom Meeting Link" : address
        lblEventTitle.text = event.eventName
        eventTypeImage.image = e == .online ? UIImage(named: "icon_video") : UIImage(named: "icon-map-pin")
        linkOrInpersonImage.image = e == .online ? UIImage(named: "link") : UIImage(named: "icon-corner-up-right")
        
        if let s = event.startTime?.toDate {
            lblDate.text = "\(s.stringValue(format: "EEE dd MMM yyyy, hh:mm a", timeZone: .current))"
        }
        
        if (event.peoplesProfile?.going?.count ?? 0 > 0 && event.peoplesProfile?.going?.count ?? 0 < 2) {
            // 1 user in this event
            user1Image.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
           
            user2Image.isHidden = true
            user3Image.isHidden = true
            user4Image.isHidden = true
            totalUsersView.isHidden = true
        } else if (event.peoplesProfile?.going?.count ?? 0 > 1 && event.peoplesProfile?.going?.count ?? 0 < 3) {
            // 2 users in this event
            user1Image.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            user2Image.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            user3Image.isHidden = true
            user4Image.isHidden = true
            totalUsersView.isHidden = true
        } else if (event.peoplesProfile?.going?.count ?? 0 > 2 && event.peoplesProfile?.going?.count ?? 0 < 4) {
            // 3 users in this event
            user1Image.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            user2Image.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            user3Image.setImage(url: event.peoplesProfile?.going?[2].profileImage, placeholder: R.image.profile_image_dummy())
            user4Image.isHidden = true
            totalUsersView.isHidden = true
        } else if (event.peoplesProfile?.going?.count ?? 0 > 3 && event.peoplesProfile?.going?.count ?? 0 < 5) {
            // 4 users in this event
            user1Image.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            user2Image.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            user3Image.setImage(url: event.peoplesProfile?.going?[2].profileImage, placeholder: R.image.profile_image_dummy())
            user4Image.setImage(url: event.peoplesProfile?.going?[3].profileImage, placeholder: R.image.profile_image_dummy())
            totalUsersView.isHidden = true
            
        } else if (event.peoplesProfile?.going?.count ?? 0 >= 4) {
            // more than 4 users in this event
            user1Image.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            user2Image.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            user3Image.setImage(url: event.peoplesProfile?.going?[2].profileImage, placeholder: R.image.profile_image_dummy())
            user4Image.setImage(url: event.peoplesProfile?.going?[3].profileImage, placeholder: R.image.profile_image_dummy())
            totalUsersView.isHidden = false
        } else {
            user1Image.isHidden = true
            user2Image.isHidden = true
            user3Image.isHidden = true
            user4Image.isHidden = true
            lblTotalRemainingGoingUser.text = "0"
        }
        
        self.view.layoutIfNeeded()
    }
    
    // MARK: - IBActions
    @IBAction func didTapNoButton(_ sender: UIButton) {
        let action: EventAction = .notGoing
        
        update(event: event, action: action) { status in
            if status {
                if self.event.peoplesProfile == nil {
                    self.event.peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                
                self.currentEventIndex += 1
                if (self.currentEventIndex < self.allInvitedEvents.count) {
                    self.event = self.allInvitedEvents[self.currentEventIndex]
                } else {
                    self.goBack()
                }
                
                if action == .notGoing {
                    self.event.peoplesProfile?.notGoing?.append(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.interested?.remove(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.going?.remove(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.event.peoplesProfile?.notGoing?.remove(userId: Cache.shared.user?.userID ?? "")
                }
            }
        }
    }
    
    @IBAction func didTapYesButton(_ sender: UIButton) {
        let action: EventAction = .going
        update(event: event, action: action) { status in
            if status {
                if self.event.peoplesProfile == nil {
                    self.event.peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                
                self.currentEventIndex += 1
                if (self.currentEventIndex < self.allInvitedEvents.count) {
                    self.event = self.allInvitedEvents[self.currentEventIndex]
                } else {
                    self.goBack()
                }
                
                if action == .going {
                    self.event.peoplesProfile?.going?.append(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.interested?.remove(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.notGoing?.remove(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.event.peoplesProfile?.going?.remove(userId: Cache.shared.user?.userID ?? "")
                }
            }
        }
    }
    
    @IBAction func didTapMaybeButton(_ sender: UIButton) {
        let action: EventAction = .interested
        update(event: event, action: action) { status in
            if status {
                if self.event.peoplesProfile == nil {
                    self.event.peoplesProfile = PeoplesProfile(admins: [], going: [], notGoing: [], maybe: [], interested: [], likes: [], invited: [])
                }
                
                self.currentEventIndex += 1
                if (self.currentEventIndex < self.allInvitedEvents.count) {
                    self.event = self.allInvitedEvents[self.currentEventIndex]
                } else {
                    self.goBack()
                }
                
                if action == .interested {
                    self.event.peoplesProfile?.interested?.append(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.going?.remove(userId: Cache.shared.user?.userID ?? "")
                    self.event.peoplesProfile?.notGoing?.remove(userId: Cache.shared.user?.userID ?? "")
                } else {
                    self.event.peoplesProfile?.interested?.remove(userId: Cache.shared.user?.userID ?? "")
                }
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
}

extension EventInviteController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return scrollView
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(self.view.frame.height - 80)
    }
}
