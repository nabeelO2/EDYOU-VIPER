//
// Publisher+ThrottledSink.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    
    func throttledSink<S>(for interval: S.SchedulerTimeType.Stride, scheduler: S, receiveValue: @escaping (Output)->Void) where S : Scheduler {
        var cancellable: AnyCancellable? = nil;
        cancellable = self.throttle(for: interval, scheduler: scheduler, latest: true).sink(receiveCompletion: { result in
            cancellable?.cancel();
            cancellable = nil;
        }, receiveValue: receiveValue);
    }
}
