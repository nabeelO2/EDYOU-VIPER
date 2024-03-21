//
// OMEMOIdentityTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class OMEMOIdentityTableViewCell: UITableViewCell {
    
    @IBOutlet var deviceLabel: UILabel?;
    
    @IBOutlet var identityLabel: UILabel!
    
    @IBOutlet var trustSwitch: UISwitch!
    
    var valueChangedListener: ((UISwitch) -> Void)?;
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        valueChangedListener?(sender);
    }
}
