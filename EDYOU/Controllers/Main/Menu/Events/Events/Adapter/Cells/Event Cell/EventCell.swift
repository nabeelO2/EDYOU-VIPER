//
//  EventCell.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class EventCell: UICollectionViewCell {
    
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
    @IBOutlet weak var eventInterestView: UIView!
    @IBOutlet weak var sepratorTopSpaceConstant: NSLayoutConstraint!
    @IBOutlet weak var goingUserStackView: UIStackView!
    @IBOutlet weak var lblDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        imgCover.layer.cornerRadius = 12
        imgCover.layer.masksToBounds = true
        imgCover.clipsToBounds = true
    }
    
    
    func setData(_ event: Event) {
        endSkeltonAnimation()
        
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        self.imgEventType.image = e.joiningTypeImage.withRenderingMode(.alwaysTemplate)
        if event.coverImages?.count ?? 0 > 0 {
        imgCover.setImage(url: event.coverImages?.first, placeholder: R.image.event_placeholder_square())
        } else {
            imgCover.image = UIImage(named: "event_placeholder_square")
        }
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
