//
//  ContactHeaderView.swift
//  connect-app
//
//  Created by Ali Raza on 25/05/2019.
//  Copyright © 2019 AlqaTech. All rights reserved.
//

import Foundation

import UIKit


class MenuHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
}
