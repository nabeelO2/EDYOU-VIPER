//
//  EditSkillTableViewCell.swift
//  EDYOU
//
//  Created by Masroor on 09/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit

class AboutSectionParentCell: UITableViewCell {
    var delegate: AboutSectionCellDelegate?
    var indexPath: IndexPath?
    
    @objc func editButtonTapped(sender: UIButton) {
        self.delegate?.onEdit(index: indexPath?.row ?? 0)
    }
    
    @objc func deleteButtonTapped(sender: UIButton) {
        self.delegate?.onDelete(index: indexPath?.row ?? 0)
    }
}

class EditSkillTableViewCell: AboutSectionParentCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var cntView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnEdit.removeTarget(nil, action: nil, for: .allEvents)
        self.btnDelete.removeTarget(nil, action: nil, for: .allEvents)
        self.btnEdit.addTarget(self, action: #selector(editButtonTapped(sender:)), for: .touchUpInside)
        self.btnDelete.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
    func setData(skill: String, delegate: AboutSectionCellDelegate?){
        lblTitle.text = skill
        cntView.cornerRadius = cntView.bounds.height / 2
        self.delegate = delegate
    }
}
