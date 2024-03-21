//
//  EventsTimeFilterViewController.swift
//  EDYOU
//
//  Created by Aksa on 11/08/2022.
//

import UIKit

protocol ApplyEventsTimeFilter : AnyObject{
    func applyTimeFilter()
}

class EventsTimeFilterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var chooseDateLbl: UILabel!
    @IBOutlet weak var customDateTextField: UITextField!
    @IBOutlet weak var anyTimeButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var tomorrowButton: UIButton!
    @IBOutlet weak var thisWeekendButton: UIButton!
    @IBOutlet weak var thisWeekButton: UIButton!
    
    weak var delegate : ApplyEventsTimeFilter?
    static var selectedEventGoOutTypeFilter: EventGoOutType = .anyTime
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.customDateTextField.datePicker(target: self,
                                          doneAction: #selector(doneAction),
                                          cancelAction: #selector(cancelAction),
                                          datePickerMode: .date)
        if (EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .anyTime) {
            anyTimeButton.isSelected = true
            anyTimeButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .today) {
            todayButton.isSelected = true
            todayButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .tomorrow) {
            tomorrowButton.isSelected = true
            tomorrowButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .thisWeek) {
            thisWeekButton.isSelected = true
            thisWeekButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (EventsTimeFilterViewController.selectedEventGoOutTypeFilter == .thisWeekend) {
            thisWeekendButton.isSelected = true
            thisWeekendButton.tintColor = UIColor.init(hexString: "53B36E")
        }
    }
    
    @objc func cancelAction() {
        self.chooseDateLbl.isHidden = false
        self.customDateTextField.text = ""
        EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .anyTime
        AppDefaults.shared.eventFilterCustomDate = ""
        self.customDateTextField.resignFirstResponder()
    }
    
    @objc func doneAction() {
        if let datePickerView = self.customDateTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.customDateTextField.text = dateString
            self.chooseDateLbl.isHidden = true
            print(datePickerView.date)
            print(dateString)
            
            
            self.customDateTextField.resignFirstResponder()
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .chooseADate
            AppDefaults.shared.eventFilterCustomDate = dateString
        }
    }

    // MARK: - IBActions
    
    @IBAction func filtersButtonTapped(sender: UIButton) {
        // tag 1,2,3,4,5 for Anytime, Today, Tomorrow, This week, This weekend
        clearFilters()
        let tag = sender.tag
        
        if (tag == 1) {
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .anyTime
        } else if (tag == 2) {
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .today
        } else if (tag == 3) {
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .tomorrow
        } else if (tag == 4) {
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .thisWeek
        } else if (tag == 5) {
            EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .thisWeekend
        }
        
        if (sender.tag > 0 && sender.tag < 6) {
            sender.isSelected = !sender.isSelected
            sender.tintColor = sender.isSelected ? UIColor.init(hexString: "53B36E") : UIColor.init(hexString: "C4C4C4")
        }
    }
    
    @IBAction func applyFIlterButtonTapped(_ sender: UIButton) {
        delegate?.applyTimeFilter()
        self.goBack()
    }
    
    func clearFilters() {
        EventsTimeFilterViewController.selectedEventGoOutTypeFilter = .anyTime
        AppDefaults.shared.eventFilterCustomDate = ""
        anyTimeButton.isSelected = false
        todayButton.isSelected = false
        tomorrowButton.isSelected = false
        thisWeekButton.isSelected = false
        thisWeekendButton.isSelected = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        clearFilters()
        self.goBack()
    }
}
