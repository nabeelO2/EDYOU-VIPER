//
// HttpFileUploadModule.swift
//
// EdYou
// Copyright (C) 2022 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Combine
import Martin

// Dummy implementation - it would be better to replace it with some better feature discovery than on each reconnection
class HttpFileUploadModule: Martin.HttpFileUploadModule {
    
    @Published
    var isAvailable: Bool = true;
    
    var isAvailablePublisher: AnyPublisher<Bool,Never> {
        return $isAvailable.eraseToAnyPublisher();
    }
    
}
