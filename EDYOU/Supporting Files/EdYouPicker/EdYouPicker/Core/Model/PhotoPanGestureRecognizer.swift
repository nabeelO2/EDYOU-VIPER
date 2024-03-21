//
//  PhotoPanGestureRecognizer.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/7/1.
//

import UIKit

class PhotoPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}
