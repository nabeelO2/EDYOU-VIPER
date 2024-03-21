//
//  CalendarController.swift
//  EDYOU
//
//  Created by  Mac on 09/11/2021.
//

import UIKit
import FSCalendar

class CalendarController: BaseController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
    var adapter: CalendarAdapter!
    var eventsAdapter: CalendarEventsAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        adapter = CalendarAdapter(calendar, didSelectEvents: { [weak self] events in
            self?.eventsAdapter.events = events
            self?.tableView.reloadData()
        })
        eventsAdapter = CalendarEventsAdapter(tableView: tableView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCalendarEvents()
    }
    
    

}

// MARK: - Actions
extension CalendarController {
    @IBAction func didTapCreateButton(_ sender: UIButton) {
        let controller = CreateEventController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func didTapCalendarPreviousButton(_ sender: UIButton) {
        let currentMonth = calendar.currentPage
        guard let previousMonth = self.gregorian.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        calendar.setCurrentPage(previousMonth, animated: true)
    }
    @IBAction func didTapCalendarNextButton(_ sender: UIButton) {
        let currentMonth = calendar.currentPage
        guard let previousMonth = self.gregorian.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        calendar.setCurrentPage(previousMonth, animated: true)
    }
}




// MARK: - Web APIs
extension CalendarController {
    func getCalendarEvents() {
        
        APIManager.social.getCalendarEvents { events, error in
            if error == nil {
                self.adapter.events = events
            } else {
                self.showErrorWith(message: error!.message)
            }
            self.calendar.reloadData()
        }
    }
}
