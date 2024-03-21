//
//  UIImage.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//

import UIKit
import Intents

extension UIImage {
    public func scaled(maxWidthOrHeight: CGFloat, isOpaque: Bool = false) -> UIImage? {
        guard maxWidthOrHeight < size.height || maxWidthOrHeight < size.width else {
            return self;
        }
        let newSize = size.height > size.width ? CGSize(width: (size.width / size.height) * maxWidthOrHeight, height: maxWidthOrHeight) : CGSize(width: maxWidthOrHeight, height: (size.height / size.width) * maxWidthOrHeight);
        let format = imageRendererFormat;
        if isOpaque {
            format.opaque = isOpaque;
        }
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize));
        };
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0);
//        self.imageRendererFormat
//        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
//        defer {
//            UIGraphicsEndImageContext();
//        }
//        return  UIGraphicsGetImageFromCurrentImageContext();
    }
    
    public func inImage() -> INImage? {
        guard let data = self.jpegData(compressionQuality: 0.7) else {
            return nil;
        }
        return INImage(imageData: data);
    }
}

