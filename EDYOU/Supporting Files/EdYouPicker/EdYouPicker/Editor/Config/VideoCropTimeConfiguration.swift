//
//  VideoCropTimeConfiguration.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/10.
//

import UIKit

public struct VideoCropTimeConfiguration {
    
    /// Video maximum cropping duration, minimum 1
    public var maximumVideoCroppingTime: TimeInterval = 10
    
    /// Video minimum cropping duration, minimum 1
    public var minimumVideoCroppingTime: TimeInterval = 1
    
    public init() { }
}
