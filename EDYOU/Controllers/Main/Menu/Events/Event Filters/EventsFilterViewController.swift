//
//  EventsFilterViewController.swift
//  EDYOU
//
//  Created by Aksa on 11/08/2022.
//

import UIKit

protocol ApplyEventsFilter : AnyObject {
    func applyEventsFilter()
}

class EventsFilterViewController: BaseController {
    
    // MARK: - Outlets
    
    // MARK: - Event Type
    @IBOutlet weak var onlineButton: UIButton!
    @IBOutlet weak var inPersonButton: UIButton!
    
    // MARK: - Categories
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var birthdayButton: UIButton!
    @IBOutlet weak var breakfastButton: UIButton!
    
    // MARK: - Scroll container
    @IBOutlet weak var scrollContainerHeightConstraint: NSLayoutConstraint!
    
    var category: String?
    weak var delegate : ApplyEventsFilter?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if (AppDefaults.shared.eventTypeFilter == "online") {
            onlineButton.isSelected = true
            onlineButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.eventTypeFilter == "in_person") {
            inPersonButton.isSelected = true
            inPersonButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.eventsCategoryFilter == "beauty") {
            beautyButton.isSelected = true
            beautyButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.eventsCategoryFilter == "birthday") {
            birthdayButton.isSelected = true
            birthdayButton.tintColor = UIColor.init(hexString: "53B36E")
        } else if (AppDefaults.shared.eventsCategoryFilter == "breakfast") {
            breakfastButton.isSelected = true
            breakfastButton.tintColor = UIColor.init(hexString: "53B36E")
        } else {
            self.category = AppDefaults.shared.eventsCategoryFilter
        }
    }
    
    // MARK: - IBActions
    @IBAction func filtersButtonTapped(sender: UIButton) {
        clearAll()
        
        let tag = sender.tag
        
        // tag 1,2 for Event type
        if (tag == 1) {
            onlineButton.isSelected = true
            AppDefaults.shared.eventTypeFilter = "online"
        }
        
        if (tag == 2) {
            inPersonButton.isSelected = true
            AppDefaults.shared.eventTypeFilter = "in_person"
        }
        
        // tag 3,4,5 for categories
        if (tag == 3) {
            beautyButton.isSelected = true
            AppDefaults.shared.eventsCategoryFilter = "beauty"
        }
        
        if (tag == 4) {
            birthdayButton.isSelected = true
            AppDefaults.shared.eventsCategoryFilter = "birthday"
        }
        
        if (tag == 5) {
            breakfastButton.isSelected = true
            AppDefaults.shared.eventsCategoryFilter = self.category ?? "breakfast"
        }
        
        sender.tintColor = sender.isSelected ? UIColor.init(hexString: "53B36E") : UIColor.init(hexString: "C4C4C4")
    }
    
    @IBAction func showAllButtonTapped(_ sender: UIButton) {
        // tag 1 for categories show all
        
        if (sender.tag == 1) {
            let userEventFilter = ReusbaleOptionSelectionController(options: ["Beauty", "Birthday", "Breakfast", "Drinks", "Hangout", "Lunch / Dinner", "Special Occasion", "Sport / Activities", "Work Meeting", "Other"], previouslySelectedOption: self.category?.capitalized, screenName: "Event Category", completion: { selected in
                
                if (selected == "Hangout") {
                    self.category = "hangout"
                } else if (selected == "Lunch / Dinner") {
                    self.category = "lunch/dinner"
                } else if (selected == "Special Occasion") {
                    self.category = "special_occasions"
                } else if (selected == "Sport / Activities") {
                    self.category = "sport_activities"
                } else if (selected == "Work Meeting") {
                    self.category = "work_meeting"
                } else {
                    self.category = selected.lowercased()
                }
                
                AppDefaults.shared.eventsCategoryFilter = self.category ?? "beauty"
            })
            
            self.presentPanModal(userEventFilter)
        }
    }
    
    @IBAction func applyFIlterButtonTapped(_ sender: UIButton) {
        self.delegate?.applyEventsFilter()
        self.goBack()
    }
    
    @IBAction func clearAllButtonTapped(_ sender: UIButton) {
        clearAll()
        self.delegate?.applyEventsFilter()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.goBack()
    }
    
    func clearAll() {
        onlineButton.isSelected = false
        inPersonButton.isSelected = false
        beautyButton.isSelected = false
        birthdayButton.isSelected = false
        breakfastButton.isSelected = false
        
        onlineButton.tintColor = UIColor.init(hexString: "C4C4C4")
        inPersonButton.tintColor = UIColor.init(hexString: "C4C4C4")
        beautyButton.tintColor = UIColor.init(hexString: "C4C4C4")
        birthdayButton.tintColor = UIColor.init(hexString: "C4C4C4")
        breakfastButton.tintColor = UIColor.init(hexString: "C4C4C4")
        
        AppDefaults.shared.eventTypeFilter = ""
        AppDefaults.shared.eventsCategoryFilter = ""
    }
}
