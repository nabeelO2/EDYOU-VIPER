//
//  UIVIew.swift
//  ustories
//
//  Created by imac3 on 05/06/2023.
//

import UIKit

extension UIView{
    func getPresentedViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
       
    }
    
}
