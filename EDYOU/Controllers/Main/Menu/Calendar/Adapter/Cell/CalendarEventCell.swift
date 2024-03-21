//
//  CalendarEventCell.swift
//  EDYOU
//
//  Created by  Mac on 04/11/2021.
//

import UIKit

class CalendarEventCell: UITableViewCell {
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgCalendar: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setData(_ event: Event) {
        endSkeltonAnimation()
        
        imgCover.setImage(url: event.coverImages?.first, placeholderColor: R.color.image_placeholder())
        lblTitle.text = event.eventName
        
        if let s = event.startTime?.toDate, let e = event.endTime?.toDate {
            lblDate.text = "\(s.stringValue(format: "EEE, dd MM", timeZone: .current)) - \(e.stringValue(format: "EEE, dd MM", timeZone: .current))"
        }
        
    }
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        let views: [UIView] = [imgCover, lblTitle, lblDate]
        views.forEach { $0.startSkelting() }
        
        
    }
    func endSkeltonAnimation() {
        let views: [UIView] = [imgCover, lblTitle, lblDate]
        views.forEach { $0.stopSkelting() }
    }
}
