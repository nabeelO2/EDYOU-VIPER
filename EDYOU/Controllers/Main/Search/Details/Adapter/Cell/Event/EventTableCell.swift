//
//  EventTableCell.swift
//  EDYOU
//
//  Created by  Mac on 04/11/2021.
//

import UIKit

class EventTableCell: UITableViewCell {
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblEventType: UILabel!
    @IBOutlet weak var imgEventType: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgCalendar: UIImageView!
    @IBOutlet weak var imageEventUser1: UIImageView!
    @IBOutlet weak var imageEventUser2: UIImageView!
    @IBOutlet weak var imageEventUser3: UIImageView!
    @IBOutlet weak var totalUsersView: UIView!
    @IBOutlet weak var lblTotalUsers: UILabel! // e.g., 2+
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint! // 40 : 15
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSectionHeader: UILabel!
    @IBOutlet weak var eventInterestView: UIView!
    @IBOutlet weak var sepratorTopSpaceConstant: NSLayoutConstraint!
    @IBOutlet weak var goingUserStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        imgCover.layer.cornerRadius = 12
        imgCover.layer.masksToBounds = true
        imgCover.clipsToBounds = true
    }
    
//    func showEventInterestView(show: Bool) {
//        if (show) {
//            eventInterestView.isHidden = false
//        } else {
//            eventInterestView.isHidden = true
//        }
//    }
//    func showSectionHeader(show: Bool, myEventsView: Bool = false) {
//        if (show) {
//            lblSectionHeader.isHidden = false
//            containerViewTopConstraint.constant = 40
//            sepratorTopSpaceConstant.constant = 8
//        } else {
//            lblSectionHeader.isHidden = true
//            containerViewTopConstraint.constant = 15
//            sepratorTopSpaceConstant.constant = -8
//        }
//
//        if (myEventsView) {
//            sepratorTopSpaceConstant.constant = 8
//        }
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setData(_ event: Event) {
        endSkeltonAnimation()        
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        self.imgEventType.image = e.joiningTypeImage.withRenderingMode(.alwaysTemplate)
        imgCover.setImage(url: event.coverImages?.first, placeholder: R.image.event_placeholder_square())
        lblEventType.text = e.name
        lblTitle.text = event.eventName
        lblDescription.text = event.eventDescription
        if (event.peoplesProfile?.going?.count ?? 0 > 0 && event.peoplesProfile?.going?.count ?? 0 < 2) {
            // 1 user in this event
            imageEventUser1.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser2.isHidden = true
            imageEventUser3.isHidden = true
            totalUsersView.isHidden = true
        } else if (event.peoplesProfile?.going?.count ?? 0 > 1 && event.peoplesProfile?.going?.count ?? 0 < 3) {
            // 2 users in this event
            imageEventUser1.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser2.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser3.isHidden = true
            totalUsersView.isHidden = true
        } else if (event.peoplesProfile?.going?.count ?? 0 > 2 && event.peoplesProfile?.going?.count ?? 0 < 4) {
            // 3 users in this event
            imageEventUser1.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser2.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser3.setImage(url: event.peoplesProfile?.going?[2].profileImage, placeholder: R.image.profile_image_dummy())
            totalUsersView.isHidden = true
        } else if ((event.peoplesProfile?.going?.count ?? 0 > 3)) {
            // more than 3 users in this event
            imageEventUser1.setImage(url: event.peoplesProfile?.going?[0].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser2.setImage(url: event.peoplesProfile?.going?[1].profileImage, placeholder: R.image.profile_image_dummy())
            imageEventUser3.setImage(url: event.peoplesProfile?.going?[2].profileImage, placeholder: R.image.profile_image_dummy())
            totalUsersView.isHidden = false
            
            if let count = event.peoplesProfile?.allUsers.count {
                lblTotalUsers.text = (count - 3).description + "+"
            }
        } else {
            goingUserStackView.isHidden = true
        }
        
        if let s = event.startTime?.toDate {
            lblDate.text = "\(s.stringValue(format: "EEE dd MMM yyyy, hh:mm a", timeZone: .current))"
        }
    }
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        let views: [UIView] = [imgCover, imgCalendar, lblEventType, lblTitle, lblDate, goingUserStackView]
        views.forEach { $0.startSkelting() }
    }
    
    func endSkeltonAnimation() {
        let views: [UIView] = [imgCover, imgCalendar, lblEventType, lblTitle, lblDate, goingUserStackView]
        views.forEach { $0.stopSkelting() }
    }
    
}
