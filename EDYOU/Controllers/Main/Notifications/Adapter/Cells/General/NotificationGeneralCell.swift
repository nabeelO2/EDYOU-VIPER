//
//  NotificationGeneralCell.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 03/01/2022.
//

import UIKit

class NotificationGeneralCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func setData(_ notification: NotificationData) {
        endSkeltonAnimation()
        imgView.setImage(url: notification.senderProfile?.profileImage, placeholder: R.image.profileImagePlaceHolder())
        lblName.text = notification.senderProfile?.name?.firstName ?? "--"
        lblMessage.text = notification.alert
        lblTime.text = notification.createdAt?.toDate?.timeText
    }
    
    func beginSkeltonAnimation() {
        layoutIfNeeded()
        let views: [UIView] = [imgView, lblName, lblMessage, lblTime]
        views.forEach { $0.startSkelting() }
    }
    func endSkeltonAnimation() {
        let views: [UIView] = [imgView, lblName, lblMessage, lblTime]
        views.forEach { $0.stopSkelting() }
    }
    
//    func startLoading() {
//        viewLoader.isHidden = false
//    }
//    func stopLoading() {
//        viewLoader.isHidden = true
//    }
    
}
