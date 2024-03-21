//
//  YPFlashMode.swift
//  YPImagePicker
//
//  Created by Nik Kov on 13.08.2021.
//

import AVFoundation
import UIKit

enum EDFlashMode {
    case off
    case on
    case auto
}

extension EDFlashMode {
    init(torchMode: AVCaptureDevice.TorchMode?) {
        switch torchMode {
        case .on:
            self = .on
        case .off:
            self = .off
        case .auto:
            self = .auto
        case .none,
             .some:
            self = .auto
        }
    }
}

extension EDFlashMode {
    func flashImage() -> UIImage {
        switch self {
        case .on:
            return EDConfig.icons.flashOnIcon
        case .off:
            return EDConfig.icons.flashOffIcon
        case .auto:
            return EDConfig.icons.flashAutoIcon
        }
    }
}
