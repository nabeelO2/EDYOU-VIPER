//
//  CalendarAdapter.swift
//  EDYOU
//
//  Created by  Mac on 09/11/2021.
//

import FSCalendar

class CalendarAdapter: NSObject {
    
    weak var calendar: FSCalendar!
    var events: [Event] = []
    var didSelectEvents: ((_ events: [Event]) -> Void)?
    
    init(_ calendar: FSCalendar, didSelectEvents: @escaping (_ events: [Event]) -> Void) {
        super.init()
        
        self.didSelectEvents = didSelectEvents
        self.calendar = calendar
        configure()
    }
    func configure() {
        
        calendar.delegate = self
        calendar.dataSource = self
        
        // Calendar
        calendar.scrollDirection                = .horizontal
        calendar.scrollEnabled                  = true
        calendar.allowsMultipleSelection        = false
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.headerHeight = 50
        calendar.weekdayHeight = 30
        
        // Calendar Appearance
        calendar.clipsToBounds   = true
        calendar.backgroundColor = .clear
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        // Placeholders
        calendar.placeholderType = .fillHeadTail
        
        // Header
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleColor = UIColor.white
        calendar.appearance.headerTitleFont  = UIFont.systemFont(ofSize: 22, weight: .medium)
        // Title
        calendar.appearance.calendar.calendarHeaderView.backgroundColor = R.color.buttons_blue()
        calendar.appearance.calendar.calendarWeekdayView.backgroundColor = R.color.buttons_blue()
        calendar.appearance.weekdayTextColor  = UIColor.white
        calendar.appearance.titleDefaultColor = UIColor.black
        
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        calendar.appearance.titleFont   = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        
        // Case Options
        
        calendar.appearance.titleSelectionColor  = UIColor.white
        calendar.appearance.selectionColor = R.color.buttons_green()
        calendar.appearance.todayColor = UIColor.clear
        
        calendar.appearance.eventDefaultColor = R.color.buttons_green()
        calendar.appearance.eventSelectionColor = R.color.buttons_green()
        
        // Today Appearance
        calendar.appearance.titleTodayColor = R.color.buttons_green()
        calendar.appearance.todaySelectionColor = R.color.buttons_green()
        
        
    }
    
    func numberOfEvents(for date: Date) -> Int {
        var count = 0
        for e in events {
            if let s = e.startTime?.toDate?.startOfDay, let e = e.endTime?.toDate?.endOfDay {
                if s <= date && e >= date {
                    count += 1
                }
            }
        }
        return count
    }
    
    
}

extension CalendarAdapter: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return numberOfEvents(for: date)
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let events = self.events.events(for: date)
        didSelectEvents?(events)
    }
}
