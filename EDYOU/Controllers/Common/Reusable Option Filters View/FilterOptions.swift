//
//  FilterOptions.swift
//  EDYOU
//
//  Created by Raees on 27/08/2022.
//

import Foundation
import UIKit

struct FilterOptions {
    var image : UIImage?
    var title = String()
    var isSwitch = Bool()
    var switchValue = Bool()
    var value = String()
    var filterType = FilterType.dropdown
    var valueChanged = false
    var defaultValue = String()
}
//MARK: Filter Enum
enum FilterType: String {
    case boolean, dropdown, textField, datePicker, none
    
}
