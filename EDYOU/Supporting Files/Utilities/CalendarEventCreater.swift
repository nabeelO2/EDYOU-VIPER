//
//  CalendarEventCreater.swift
//  EDYOU
//
//  Created by Mudassir Asghar on 01/01/2022.
//

import EventKit
import Foundation

final class CalendarEventCreater {
    
    static let shared = CalendarEventCreater()
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    
    func addEventToCalender(event: Event, completionHandler: @escaping CompletionHandler) {
        let eventStore : EKEventStore = EKEventStore()
              
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        let eventObj :EKEvent = EKEvent(eventStore: eventStore)
        
        eventObj.title = event.title ?? event.eventName
        if let startTime = event.startTime, let endTime = event.endTime, endTime > startTime {
            eventObj.startDate = startTime.toDate
            eventObj.endDate = endTime.toDate
        } else {
            DispatchQueue.main.async {
                completionHandler(false)
            }
            return
        }
        eventObj.location = event.location?.locationName
        eventObj.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(eventObj, span: .thisEvent)
            DispatchQueue.main.async {
                completionHandler(true)
            }
        } catch let error as NSError {
            print("failed to save event with error : \(error)")
            DispatchQueue.main.async {
                completionHandler(false)
            }
        }
        
        print("Saved Event")
        
    }
}

