//
//  Event+Extension.swift
//  EDYOU
//
//  Created by Masroor Elahi on 23/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation

extension Array where Element == EventBasic {
    func events() -> [Event] {
        var evnts = [Event]()
        for b in self {
            let e = Event(event: b)
            evnts.append(e)
        }
        return evnts
    }
}



extension Array where Element == Event {
    func events(for date: Date) -> [Event] {
        var evnts = [Event]()
        for evnt in self {
            if let s = evnt.startTime?.toDate?.startOfDay, let e = evnt.endTime?.toDate?.endOfDay {
                if s <= date && e >= date {
                    evnts.append(evnt)
                }
            }
        }
        return evnts
    }
    mutating func updateTitleAndEventName() {
        for (index, _) in self.enumerated() {
            self[index].eventName = self[index].eventName ?? self[index].title
        }
    }
}
