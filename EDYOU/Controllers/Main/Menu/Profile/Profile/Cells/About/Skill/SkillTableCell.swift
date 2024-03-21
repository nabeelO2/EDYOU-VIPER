//
//  SkillTableCell.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit
import TagListView
class SkillTableCell: AboutSectionParentCell {

    @IBOutlet weak var skillTagView: TagListView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(skills:[String]){
        skillTagView.removeAllTags()
        skillTagView.textFont =  .systemFont(ofSize: 12)
        skillTagView.addTags(skills)
    }
}

