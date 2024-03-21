//
// ChannelSelectAccountAndComponentController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class ChannelSelectAccountAndComponentController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var accountField: UITextField!;
    @IBOutlet var componentField: UITextField!;
    
    weak var delegate: ChannelSelectAccountAndComponentControllerDelgate?;

    private let accountPicker = UIPickerView();
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let accountPicker = UIPickerView();
        accountPicker.dataSource = self;
        accountPicker.delegate = self;
        accountField.inputView = accountPicker;
        accountField.text = delegate?.client?.userBareJid.stringValue;
        componentField?.text = delegate?.domain;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let account = BareJID(accountField!.text), let client = XmppService.instance.getClient(for: account) {
            delegate?.client = client;
        }
        let val = componentField.text?.trimmingCharacters(in: .whitespacesAndNewlines);
        delegate?.domain = (val?.isEmpty ?? true) ? nil : val;
        super.viewWillDisappear(animated);
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AccountManager.getActiveAccounts().count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AccountManager.getActiveAccounts()[row].name.stringValue;
    }
    
    func  pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.accountField.text = self.pickerView(pickerView, titleForRow: row, forComponent: component);
    }

}

protocol ChannelSelectAccountAndComponentControllerDelgate: AnyObject {
    var client: XMPPClient? { get set }
    var domain: String? { get set }
}
