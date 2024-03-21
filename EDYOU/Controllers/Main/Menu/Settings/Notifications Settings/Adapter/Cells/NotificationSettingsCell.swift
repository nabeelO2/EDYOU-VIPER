//
//  NotificationSettingsCell.swift
//  EDYOU
//
//  Created by  Mac on 24/09/2021.
//

import UIKit

protocol NotificationSettingsCellDelegate {
    func updateSettings(setting: NotificationSettings, isEnabled: Bool)
}


class NotificationSettingsCell: UITableViewCell {
    var delegate: NotificationSettingsCellDelegate?
    @IBOutlet weak var settingIconImageView: UIImageView!
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var switchSetting: UISwitch!
    
    var settings: NotificationSettings = .chat
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        switchSetting.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }
    
    override func prepareForReuse() {
        switchSetting.isOn = false
    }
    func updateUI(title: String?, image: UIImage?, setting: NotificationSettings)
    {
        self.settingIconImageView.image = image
        self.lblSetting.text = title
        self.settings = setting
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func settingSwitchUpdated(_ sender: Any) {
        delegate?.updateSettings(setting: self.settings, isEnabled: switchSetting.isOn)
    }
}
