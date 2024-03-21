//
//  ImagePickerSetupClass.swift
//  EDYOU
//
//  Created by Raees on 27/08/2022.
//

import Foundation
//import HXPHPicker
class ImagePickerSetupClass {
    func setupConfigs() -> PickerConfiguration {
        let config = PhotoTools.getWXPickerConfig()
        //MARK: Add configurationChanges here
        config.maximumSelectedCount = 10
        config.maximumSelectedVideoDuration = 20
        return config
    }
}

