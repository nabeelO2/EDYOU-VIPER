//
//  LivePhotoError.swift
//  EdYouPicker
//
//  Created by imac3 on 2021/1/7.
//

import Foundation

public enum LivePhotoError {
    case imageError(Error?)
    case videoError(Error?)
    case allError(Error?, Error?)
}
