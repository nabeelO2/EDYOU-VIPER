//
//  Application.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import EZCustomNavigation

final class Application {
    static let shared = Application()
    
    var window: UIWindow?
    
    private init() {
       
    }
    var safeAreaInsets: UIEdgeInsets {
        var padding: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            if let b = window?.safeAreaInsets {
                padding = b
            }
        }
        return padding
    }
}

extension Application {
    
    func switchToLogin() {
        window = UIWindow()
        
        let onBoarding = OnboardingRouter.createModule()
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [onBoarding]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }
    
    func switchToSignup(){

        window = UIWindow()
        let controller = SignupRouter.createModule(navigationController: UINavigationController())
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()
    }
    
    func switchToHome() {
        window = UIWindow()
        let initialViewController: UIViewController = MainTabBarController()
        
        EZNavigationConfiguration.defaultConfiguration = EZNavigationConfiguration(unpop: EZUnpopConfiguration(ttl: 30, stackDepth: 5))
        
        let navigationController = EZNavigationController(rootViewController: initialViewController)
        navigationController.isNavigationBarHidden = true
        
        if UserDefaults.standard.object(forKey: "invitationCode") == nil && UserDefaults.standard.bool(forKey: "isEmailVerified"){
            let controller = InviteCodeController(nibName: "InviteCodeController", bundle: nil)
            controller.hideBackButton = true
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.isNavigationBarHidden = true
            
            window?.rootViewController = navigationController
        }
        else if UserDefaults.standard.object(forKey: "isUserAddedMajor") != nil {
//            let controller = AddMajorViewController(nibName: "AddMajorViewController", bundle: nil)
//            let navigationController = UINavigationController(rootViewController: controller)
//            navigationController.isNavigationBarHidden = true
            let major = AddMajorRouter.createModule(navigationController: UINavigationController())
//            self.navigationController?.pushViewController(major, animated: true)
            window?.rootViewController = major
        } else {
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
//        (UIApplication.shared.delegate as? AppDelegate)?.registerForPushNotifications()
        
    }
    func switchToOtp(_ otp : [String]){
        
        let controller = VerifyEmailController(code: otp)
        
       
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        window?.rootViewController = navigationController
    }
    
}
extension Application {
    
    var topViewController: UIViewController? {
            let controller = getTopViewController(base: window?.rootViewController)
            return controller
    }
    
    func getTopViewController(base: UIViewController?) -> UIViewController? {
            if let nav = base as? UINavigationController {
                return getTopViewController(base: nav.visibleViewController)
                
            } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
                
            } else if let presented = base?.presentedViewController {
                return getTopViewController(base: presented)
            }
            return base
    }
    
    func dismissToRoot() {
        DispatchQueue.main.async {
            let navC = self.window?.rootViewController as? UINavigationController
            navC?.presentedViewController?.dismiss(animated: false, completion: nil)
            
            if let tabBarVC = (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
                tabBarVC.presentedViewController?.dismiss(animated: false, completion: nil)
                for controller in (tabBarVC.viewControllers ?? []) {
                    controller.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func dissmisControllers(for vc: UIViewController?) {
        DispatchQueue.main.async {
            while (vc?.presentedViewController != nil) {
                vc?.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
}



extension Application {
    func openProfile(userId id: String) {
        dismissToRoot()
        let navC = self.window?.rootViewController as? UINavigationController
        if let tabBarVC = navC?.viewControllers.first as? UITabBarController {
            tabBarVC.selectedIndex = 0
            navC?.popToRootViewController(animated: false)
            
            let user = User(userID: id)
            let controller = ProfileController(user: user)
            navC?.pushViewController(controller, animated: true)
        }
    }
   
    func openPostDetails(postId id: String,actionType : String?) {
        dismissToRoot()
        let navC = self.window?.rootViewController as? UINavigationController
        if let vc = navC?.viewControllers.first(where: { $0 is PostDetailsController }) as? PostDetailsController, vc.post.postID == id {
            navC?.popToViewController(vc, animated: true)
            vc.getPostDetails()
            return
        }
        if let tabBarVC = navC?.viewControllers.first as? UITabBarController {
            tabBarVC.selectedIndex = 0
            navC?.popToRootViewController(animated: false)
            
            let post = Post(userID: "", postID: id)
            let commentId = actionType?.lowercased() == "comment" ? id : nil
            
            let controller = PostDetailsController(post: post, prefilledComment: nil,commentId: commentId)
            navC?.pushViewController(controller, animated: true)
        }
    }
    func openGroupDetails(groupId id: String,shouldCallInvite: Bool = false) {
        dismissToRoot()
        let navC = self.window?.rootViewController as? UINavigationController
        
        if let vc = navC?.viewControllers.first(where: { $0 is GroupDetailsController }) as? GroupDetailsController, vc.group.groupID == id {
            vc.shouldCallInvite = shouldCallInvite
            navC?.popToViewController(vc, animated: true)
            vc.getDetails()
            return
        }
        if let tabBarVC = navC?.viewControllers.first as? UITabBarController {
            tabBarVC.selectedIndex = 4
            navC?.popToRootViewController(animated: false)
            
            let group = Group(groupID: id)
            let controller = GroupDetailsController(group: group)
            controller.shouldCallInvite = shouldCallInvite
            navC?.pushViewController(controller, animated: true)
        }
    }
    func openEventDetails(eventId id: String) {
        dismissToRoot()
        let navC = self.window?.rootViewController as? UINavigationController
        if let vc = navC?.viewControllers.first(where: { $0 is EventDetailsController }) as? EventDetailsController, vc.event.eventID == id {
            navC?.popToViewController(vc, animated: true)
            vc.getEventDetails()
            return
        }
        if let tabBarVC = navC?.viewControllers.first as? UITabBarController {
            tabBarVC.selectedIndex = 4
            navC?.popToRootViewController(animated: false)
            
            let event = Event(event: EventBasic(eventID: id))
            let controller = EventDetailsController(event: event)
            navC?.pushViewController(controller, animated: true)
        }
    }
}


