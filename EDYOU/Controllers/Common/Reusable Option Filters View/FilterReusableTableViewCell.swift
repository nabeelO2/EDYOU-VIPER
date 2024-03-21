//
//  FilterReusableTableViewCell.swift
//  EDYOU
//
//  Created by admin on 27/08/2022.
//

import UIKit
protocol FilterReusableProtocol: AnyObject
{
    func switchValueChanged(indexPathRow:Int, value: Bool)
    func dateValueAdded(indexPathRox: Int, date: String)
    func textFieldValueAdded(indexPathRox: Int, textFieldText: String)
    func textFieldStartEditing(_ starts: Bool)
}
class FilterReusableTableViewCell: UITableViewCell {

    @IBOutlet weak var fillerimage: UIImageView!
    @IBOutlet weak var filterTitle: UILabel!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var selectedValue: UILabel!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var switchOption: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var imgCheck: UIImageView!
    var filtersDelegate: FilterReusableProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    func setData(option: FilterOptions) {
        self.fillerimage.image = option.image
        self.filterTitle.text = option.title
        self.switchOption.isHidden = !option.isSwitch
        self.optionsView.isHidden = option.isSwitch
        self.selectedValue.text = option.value
        if option.filterType == .datePicker {
            self.datePicker.isHidden = false
        } else {
            self.datePicker.isHidden = true
        }
        if option.filterType == .textField {
            if option.value == "Any Company" {
                self.filterTextField.text = ""
            } else {
                filterTextField.text = option.value
            }
            self.filterTextField.isHidden = false
            filterTextField.delegate = self
        } else {
            self.filterTextField.isHidden = true
        }
        self.imgCheck.isHidden = true
    }
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        filtersDelegate?.switchValueChanged(indexPathRow: sender.tag, value: sender.isOn)
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        self.selectedValue.text = dateFormatter.string(from: datePicker.date)
        self.optionsBtn.setImage(UIImage(named: "ic_cross_rounded_filled"), for: .normal)
        filtersDelegate?.dateValueAdded(indexPathRox: sender.tag,date: self.selectedValue.text ?? "")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
extension FilterReusableTableViewCell : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.filtersDelegate?.textFieldStartEditing(false)
        if textField.text != "" {
        filtersDelegate?.textFieldValueAdded(indexPathRox: textField.tag, textFieldText: textField.text ?? "")
        } else {
            filtersDelegate?.textFieldValueAdded(indexPathRox: textField.tag, textFieldText: "Any Company")
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.filtersDelegate?.textFieldStartEditing(true)
    }
}
