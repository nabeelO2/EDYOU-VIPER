//
// MediaHelper.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import AVKit
import Shared

extension MediaHelper {
    
    static func askImageQuality(controller: UIViewController, forceQualityQuestion askQuality: Bool, _ completionHandler: @escaping (Result<ImageQuality,ShareError>)->Void) {
        if let quality = askQuality ? nil : Settings.imageQuality {
            completionHandler(.success(quality));
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: NSLocalizedString("Select quality", comment: "media quality selection instruction"), message: nil, preferredStyle: .alert);
                
                let values: [ImageQuality] = [.original, .highest, .high, .medium, .low];
                for value in  values {
                    alert.addAction(UIAlertAction(title: value.rawValue.capitalized, style: .default, handler: { _ in
                        completionHandler(.success(value));
                    }));
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "button label"), style: .cancel, handler: { _ in
                    completionHandler(.failure(.noAccessError));
                }))
                controller.present(alert, animated: true);
            }
        }
    }
    
    static func askVideoQuality(controller: UIViewController, forceQualityQuestion askQuality: Bool, _ completionHandler: @escaping (Result<VideoQuality,ShareError>)->Void) {
        if let quality = askQuality ? nil : Settings.videoQuality {
            completionHandler(.success(quality));
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: NSLocalizedString("Select quality", comment: "media quality selection instruction"), message: nil, preferredStyle: .alert);
                
                let values: [VideoQuality] = [.original, .high, .medium, .low];
                for value in  values {
                    alert.addAction(UIAlertAction(title: value.rawValue.capitalized, style: .default, handler: { _ in
                        completionHandler(.success(value));
                    }));
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "button label"), style: .cancel, handler: { _ in
                    completionHandler(.failure(.noAccessError));
                }))
                controller.present(alert, animated: true);
            }
        }
    }
    
}
