//
// NavigationControllerWrappingSegue.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class NavigationControllerWrappingSegue: UIStoryboardSegue {
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        let navController = UINavigationController(rootViewController: destination);
        super.init(identifier: identifier, source: source, destination: navController)
    }
    
}
