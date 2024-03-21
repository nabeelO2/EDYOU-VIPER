//
//  DataPickerAdapter.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit

class PickerViewAdapter: NSObject {
    
    weak var textField: UITextField!
    var data = [String]()
    var picker = UIPickerView()
    var selectedValue: ((_ value: String) -> Void)?
    
    init(textField: UITextField, data: [String], selectedValue: @escaping (_ value: String) -> Void) {
        super.init()
        
        self.textField = textField
        self.data = data
        self.selectedValue = selectedValue
        configure()
    }
    func configure() {
        picker.backgroundColor = .white
        textField.inputView = picker
        textField.tintColor = .clear
        textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(didTapDoneButton))
        picker.dataSource = self
        picker.delegate = self
    }
    @objc func didTapDoneButton() {
        let row = picker.selectedRow(inComponent: 0)
        if row < data.count {
            selectedValue?(data[row])
        }
    }
    
}

extension PickerViewAdapter: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < data.count {
            return data[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < data.count {
            selectedValue?(data[row])
        }
    }
}
