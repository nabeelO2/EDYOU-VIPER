//
//  Country.swift
//  EDYOU
//
//  Created by Masroor Elahi on 22/07/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import Foundation


class CountryModel {
    var id = 0
    var name = ""
    
    init() {}
    
    init(data: NSDictionary) {
        id = data.int(for: "Id")
        name = data.string(for: "Name")
    }
    
}
