//
//  NotificationFriendRequestCell.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 03/01/2022.
//

import UIKit

class NotificationFriendRequestCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnAddFriend: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
