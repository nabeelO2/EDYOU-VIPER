//
//  NotificationSettingsDescriptionCell.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

class NotificationSettingsDescriptionCell: UITableViewCell {

    @IBOutlet weak var notificationSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
