//
//  MenuController.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import UIKit

class MenuController: BaseController {

    @IBOutlet weak var imgProfile: UIImageView!
    
    var navC: UINavigationController? {
        return tabBarController?.navigationController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imgProfile.setImage(url: Cache.shared.user?.profileImage ?? "", placeholder: R.image.profile_image_dummy())
    }

    @IBAction func actShowReels(_ sender: UIButton) {
        let controller = ReelsViewController()
        self.navigationController?.pushViewController(controller, animated: true)
//        navC?.pushViewController(controller, animated: true)
    }
}

extension MenuController {
    
    @IBAction func didTapProfileButton() {
        let controller = ProfileController(user: User.me)
        self.navigationController?.pushViewController(controller, animated: true)
//        navC?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapFriendsButton() {
        let controller = FriendsController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapGroupsButton() {
        let controller = GroupsController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapFavoritesButton() {
        let favoriteController = FavoriteViewController()
        navC?.pushViewController(favoriteController, animated: true)
    }
    
    @IBAction func didTapEventsButton() {
        let controller = EventsController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapCalendarButton() {
        let controller = CalendarController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)    }
    @IBAction func didTapClassesButton() {
    }
    @IBAction func didTapDealsButton() {
        let controller = DealsTabBarController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapStoreButton() {
        let controller = StoreController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapMarketplaceButton() {
        let controller = MarketplaceTabBarController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    @IBAction func didTapLeaderboardButton() {
        
        
        let controller = LeaderboardController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func didTapSettingsButton() {
        let controller = SettingsController()
        navC?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapContactUsButton() {
        let controller = ContactUsController()
        navC?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapSignOutButton() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            APIManager.auth.logout { response, error in
                XMPPAppDelegateManager.shared.logoutFromXMPP()
                Keychain.shared.clear()
                RealmContextManager.shared.clearRealmDB()
                Cache.shared.clear()
                UIApplication.shared.unregisterForRemoteNotifications()
                Application.shared.switchToLogin()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapInviteButton() {
        let controller = WelcomeInviteController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
