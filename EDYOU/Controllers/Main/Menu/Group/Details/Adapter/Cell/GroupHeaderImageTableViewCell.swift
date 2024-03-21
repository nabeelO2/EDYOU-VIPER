//
//  GroupHeaderImageTableViewCell.swift
//  EDYOU
//
//  Created by admin on 21/09/2022.
//

import UIKit

protocol GroupHeaderImageProtocol {
    func backActionTapped()
    func moreActionTapped()
}

class GroupHeaderImageTableViewCell: UITableViewCell {

    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var headerImage: UIImageView!
    private var delegate: GroupHeaderImageProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(image: String?, delegate: GroupHeaderImageProtocol) {
        self.headerImage.setImage(url: image, placeholder: UIImage(named: "group_cover_placeholder"))
        self.delegate = delegate
    }
    
    @IBAction func actBack(_ sender: UIButton) {
        self.delegate.backActionTapped()
    }
    @IBAction func actMore(_ sender: UIButton) {
        self.delegate.moreActionTapped()
    }
}
