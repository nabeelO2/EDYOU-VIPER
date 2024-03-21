//
//  PeopleTypeCollectionViewCell.swift
//  EDYOU
//
//  Created by Masroor Elahi on 19/10/2022.
//

import UIKit

class PeopleTypeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblOption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(type: PeopleProfileTypes, event: Event, selected: Bool) {
        guard let peopleProfile = event.peoplesProfile else { return }
        self.lblOption.text = type.title + " (\(peopleProfile.getCountFromType(type: type))) "
        self.lblOption.backgroundColor = selected ? UIColor.init(hexString: "EBF8EF") : UIColor.init(hexString: "F3F5F8")
    }
}
