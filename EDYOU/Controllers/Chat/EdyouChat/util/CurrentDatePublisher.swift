//
// CurrentDatePublisher.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Combine

struct CurrentTimePublisher {
    
    private static var cancellable: Cancellable?;
    public private(set) static var publisher: AnyPublisher<Date,Never> = {
        let publisher = CurrentValueSubject<Date,Never>(Date());
        cancellable = Timer.publish(every: 30, on: .main, in: .default).autoconnect().assign(to: \.value, on: publisher);
        return publisher.eraseToAnyPublisher();
    }();

}
