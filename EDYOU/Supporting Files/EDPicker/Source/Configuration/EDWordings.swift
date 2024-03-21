//
//  YPWordings.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation

public struct EDWordings {
    
    public var permissionPopup = PermissionPopup()
    public var videoDurationPopup = VideoDurationPopup()

    public struct PermissionPopup {
        public var title = EDLocalized("YPImagePickerPermissionDeniedPopupTitle")
        public var message = EDLocalized("YPImagePickerPermissionDeniedPopupMessage")
        public var cancel = EDLocalized("YPImagePickerPermissionDeniedPopupCancel")
        public var grantPermission = EDLocalized("YPImagePickerPermissionDeniedPopupGrantPermission")
    }
    
    public struct VideoDurationPopup {
        public var title = EDLocalized("YPImagePickerVideoDurationTitle")
        public var tooShortMessage = EDLocalized("YPImagePickerVideoTooShort")
        public var tooLongMessage = EDLocalized("YPImagePickerVideoTooLong")
    }
    
    public var ok = EDLocalized("YPImagePickerOk")
    public var done = EDLocalized("YPImagePickerDone")
    public var cancel = EDLocalized("YPImagePickerCancel")
    public var save = EDLocalized("YPImagePickerSave")
    public var processing = EDLocalized("YPImagePickerProcessing")
    public var trim = EDLocalized("YPImagePickerTrim")
    public var cover = EDLocalized("YPImagePickerCover")
    public var albumsTitle = EDLocalized("YPImagePickerAlbums")
    public var libraryTitle = EDLocalized("YPImagePickerLibrary")
    public var cameraTitle = EDLocalized("YPImagePickerPhoto")
    public var videoTitle = EDLocalized("YPImagePickerVideo")
    public var next = EDLocalized("YPImagePickerNext")
    public var filter = EDLocalized("YPImagePickerFilter")
    public var crop = EDLocalized("YPImagePickerCrop")
    public var warningMaxItemsLimit = EDLocalized("YPImagePickerWarningItemsLimit")
}
