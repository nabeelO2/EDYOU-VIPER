//
//  VideoQuality.swift
//  Shared
//
//  Created by imac3 on 20/12/2023.
//

import Foundation
import AVKit

public enum VideoQuality: String {
    case original
    case high
    case medium
    case low
    
    public var label: String {
        switch self {
        case .original:
            return NSLocalizedString("Original", comment: "video quality")
        case .high:
            return NSLocalizedString("High", comment: "video quality")
        case .medium:
            return NSLocalizedString("Medium", comment: "video quality")
        case .low:
            return NSLocalizedString("Low", comment: "video quality")
        }
    }
    
    public var preset: String {
        switch self {
        case .original:
            return AVAssetExportPresetPassthrough;
        case .high:
            return AVAssetExportPresetHighestQuality;
        case .medium:
            return AVAssetExportPresetMediumQuality;
        case .low:
            return AVAssetExportPresetLowQuality;
        }
    }
}
