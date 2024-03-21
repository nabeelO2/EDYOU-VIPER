//
//  DatePickerViewController.swift
//  EDYOU
//
//  Created by imac3 on 02/05/2023.
//

import UIKit
import PanModal

class DatePickerViewController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    var changedate: ((_ updateDate: Date) -> Void)?
   
   
    var selectedDate : Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datePicker.addTarget(self, action: #selector(onDateValueChanged(_:)), for: .valueChanged)

        self.datePicker.minimumDate = Date()
        self.datePicker.date = selectedDate ?? Date()
         
    }
    
    @objc private func onDateValueChanged(_ datePicker: UIDatePicker) {
       //do something here
        changedate?(datePicker.date)
   }
}



extension DatePickerViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(400)
        
            
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(400)
    }
    var panModalBackgroundColor: UIColor {
        
        return UIColor(.black).withAlphaComponent(0.7)
        
    }
}
