//
// VCardEditPhoneTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class VCardEditPhoneTableViewCell: VCardEntryTypeAwareTableViewCell, UITextFieldDelegate {
    
    @IBOutlet var phoneView: UITextField!
    
    var phone: VCard.Telephone! {
        didSet {
            phoneView.text = phone.number;
            typeView.text = vcardEntryTypeName(for: phone.types.first);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let typePicker = UIPickerView();
        typePicker.dataSource = self;
        typePicker.delegate = self;
        typeView.inputView = typePicker;
        
        phoneView.delegate = self;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func typeSelected(_ type: VCard.EntryType) {
        phone.types = [type];
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        phone.number = textField.text;
    }
}
