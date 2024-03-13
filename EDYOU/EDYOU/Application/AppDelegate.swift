//
//  AppDelegate.swift
//  EDYOU
//
//  Created by imac3 on 08/03/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let navigationController = UINavigationController()
        let onboardingController = OnboardingRouter.createModule(navigationController)
        navigationController.viewControllers = [onboardingController]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
        return true
    }

    


}

