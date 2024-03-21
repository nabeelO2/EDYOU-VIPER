//
// Publisher+ThrottleFixed.swift
//
// EdYou
// Copyright (C) 2022 "O2Geeks." <admin@o2geeks.com>
//
 
//


import Foundation
import Combine

extension Publisher where Failure == Never {
    
    func throttleFixed<S>(for interval: TimeInterval, scheduler: S, latest: Bool) -> AnyPublisher<Output,Never> where S: DispatchQueue {
        if #available(iOS 13.2, macOS 10.15, *) {
            return self.throttle(for: S.SchedulerTimeType.Stride.init(floatLiteral: interval), scheduler: scheduler, latest: latest).eraseToAnyPublisher();
        } else {
            return self.throttle(for: RunLoop.SchedulerTimeType.Stride.init(floatLiteral: interval), scheduler: RunLoop.main, latest: latest).eraseToAnyPublisher();
        }
    }
    
}
