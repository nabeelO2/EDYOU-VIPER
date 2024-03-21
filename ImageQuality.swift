//
//  ImageQuality.swift
//  Shared
//
//  Created by imac3 on 20/12/2023.
//

import UIKit

public enum ImageQuality: String {
    case original
    case highest
    case high
    case medium
    case low
    
    public var label: String {
        switch self {
        case .original:
            return NSLocalizedString("Original", comment: "video quality")
        case .highest:
            return NSLocalizedString("Highest", comment: "video quality")
        case .high:
            return NSLocalizedString("High", comment: "video quality")
        case .medium:
            return NSLocalizedString("Medium", comment: "video quality")
        case .low:
            return NSLocalizedString("Low", comment: "video quality")
        }
    }
    public var size: CGFloat {
        switch self {
        case .original:
            return CGFloat.greatestFiniteMagnitude;
        case .highest:
            return CGFloat.greatestFiniteMagnitude;
        case .high:
            return 2048;
        case .medium:
            return 1536;
        case .low:
            return 1024;
        }
    }
    
    public var quality: CGFloat {
        switch self {
        case .original:
            return 1;
        case .highest:
            return 1;
        case .high:
            return 0.85;
        case .medium:
            return 0.7;
        case .low:
            return 0.6;
        }
    }
}
