//
//  PostEventCell.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 07/02/2022.
//

import UIKit

class PostEventCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInstituteName: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgArrowGroup: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
//    @IBOutlet weak var btnGroupName: UIButton!
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblEventType: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgAddToCalendar: UIImageView!
    @IBOutlet weak var imgCalendar: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
//    @IBOutlet weak var btnMore: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setData(_ event: Event) {
        endSkeltonAnimation()
        
        imgProfile.setImage(url: event.owner?.profileImage, placeholder: R.image.profile_image_dummy())
        lblName.text = event.owner?.name?.completeName ?? "N/A"
//        var graduationDate = ""
//        if let date = event.owner?.education.first?.degreeEnd?.toDate {
//            graduationDate = date.toddMMMyyyy()
//        }
        lblInstituteName.text = event.owner?.education.first?.instituteName ?? "N/A" 
        
        let e = EventType(rawValue: event.eventType ?? "") ?? .inPerson
        imgCover.setImage(url: event.coverImages?.first, placeholderColor: R.color.image_placeholder())
        lblEventType.text = e.name
        lblEventType.textColor = e.color
        lblTitle.text = event.eventName
        
        if let s = event.startTime?.toDate, let e = event.endTime?.toDate {
            lblDate.text = "\(s.stringValue(format: "EEE, dd MM", timeZone: .current)) - \(e.stringValue(format: "EEE, dd MM", timeZone: .current))"
            lblEventDate.text = "\(s.stringValue(format: "EEE, dd MM", timeZone: .current)) - \(e.stringValue(format: "EEE, dd MM", timeZone: .current))"
        }
        let isLiked = event.peoplesProfile?.likes?.contains(where: { $0.userID == Cache.shared.user?.userID ?? "" })
        imgLike.image = isLiked == true ? R.image.heart_selected() : R.image.heart_unselected()
        
    }
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        imgLike.isHidden = true
        imgAddToCalendar.isHidden = true
        let views: [UIView] = [imgCover, imgCalendar, lblEventType, lblTitle, lblDate]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        imgLike.isHidden = false
        imgAddToCalendar.isHidden = true
        let views: [UIView] = [imgCover, imgCalendar, lblEventType, lblTitle, lblDate]
        views.forEach { $0.stopSkelting() }
    }
    
}
