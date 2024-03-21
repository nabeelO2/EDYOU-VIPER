//
// VCardEditEmailTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class VCardEditEmailTableViewCell: VCardEntryTypeAwareTableViewCell, UITextFieldDelegate{

    @IBOutlet var emailView: UITextField!
    
    var email: VCard.Email! {
        didSet {
            typeView.text = self.vcardEntryTypeName(for: email.types.first);
            emailView.text = email.address;
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let typePicker = UIPickerView();
        typePicker.dataSource = self;
        typePicker.delegate = self;
        typeView.inputView = typePicker;
        
        emailView.delegate = self;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func typeSelected(_ type: VCard.EntryType) {
        email.types = [type];
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        email.address = textField.text;
    }
    
}
