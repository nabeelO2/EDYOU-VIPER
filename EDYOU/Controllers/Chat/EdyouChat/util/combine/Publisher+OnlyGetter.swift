//
// Publisher+OnlyGetter.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Combine

extension Publisher where Self.Output : Comparable {
    
    func onlyGreater(than initialValue: Output? = nil) -> Publishers.Filter<Self> {
        var value: Output? = initialValue;
        return self.filter({ nextValue in
            if value == nil || (value! < nextValue) {
                value = nextValue;
                return true;
            }
            return false;
        });
    }
    
}
