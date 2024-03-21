//
// VCardEditAddressTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class VCardEditAddressTableViewCell: VCardEntryTypeAwareTableViewCell, UITextFieldDelegate {

    var address: VCard.Address! {
        didSet {
            typeView.text = vcardEntryTypeName(for: address.types.first);
            streetView.text = address.street;
            postalCodeView.text = address.postalCode;
            cityView.text = address.locality;
            countryView.text = address.country;
        }
    }
    
    @IBOutlet var streetView: UITextField!
    @IBOutlet var postalCodeView: UITextField!
    @IBOutlet var cityView: UITextField!
    @IBOutlet var countryView: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        streetView.delegate = self;
        postalCodeView.delegate = self;
        countryView.delegate = self;
        cityView.delegate = self;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func typeSelected(_ type: VCard.EntryType) {
        address.types = [type];
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case streetView:
            address.street = textField.text;
        case postalCodeView:
            address.postalCode = textField.text;
        case cityView:
            address.locality = textField.text;
        case countryView:
            address.country = textField.text;
        default:
            break;
        }
    }
    
}
