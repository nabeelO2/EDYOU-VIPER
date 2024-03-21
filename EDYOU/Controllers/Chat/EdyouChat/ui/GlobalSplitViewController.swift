//
// GlobalSplitViewController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return Appearance.current.isDark ? .lightContent : .default;
//    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.delegate = self;
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool{
        return true
    }
 
    func splitViewController(_ splitViewController: UISplitViewController, showDetail detailvc: UIViewController, sender: Any?) -> Bool {
        let mastervc = splitViewController.viewControllers[0] as! UITabBarController;
        if splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
//            mastervc.selectedViewController?.showViewController(detailvc, sender: sender);
            if let detail = detailvc as? UINavigationController {
                (mastervc.selectedViewController as? UINavigationController)?.pushViewController(detail.viewControllers[0], animated: true);
            } else {
                (mastervc.selectedViewController as? UINavigationController)?.pushViewController(detailvc, animated: true);
            }
        } else {
            splitViewController.viewControllers = [mastervc, detailvc];
        }
        return true;
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let mastervc = splitViewController.viewControllers[0] as! UITabBarController;
        if let uinav = mastervc.selectedViewController as? UINavigationController {
            if uinav.viewControllers.count > 1 {
                return uinav.popViewController(animated: false);
            }
        }
        return nil;
    }
    
}
