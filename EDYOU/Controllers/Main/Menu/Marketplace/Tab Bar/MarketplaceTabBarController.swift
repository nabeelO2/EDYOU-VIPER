//
//  MarketplaceTabBarController.swift
//  EDYOU
//
//  Created by  Mac on 23/10/2021.
//

import UIKit

class MarketplaceTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    func setupUI() {
        
        let home = MarketplaceController()
        home.tabBarItem = UITabBarItem(title: "Home", image: R.image.tab_home_icon(), selectedImage: R.image.tab_home_selected_icon())
        home.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        home.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        let chat = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatsListViewController") as! ChatsListViewController
        chat.tabBarItem = UITabBarItem(title: "Chat", image: R.image.tab_chat_icon(), selectedImage: R.image.tab_chat_selected_icon())
        chat.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        chat.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        let saved = SavedMarketplaceItemsController()
        saved.tabBarItem = UITabBarItem(title: "Saved", image: R.image.heart_unselected(), selectedImage: R.image.heart_selected())
        saved.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        saved.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        self.viewControllers = [home, chat, saved]
        tabBar.tintColor = R.color.buttons_green()
        tabBar.isTranslucent = false
        tabBar.barTintColor = .white
        
        
        if #available(iOS 13, *) {
            let appearance = tabBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            tabBar.standardAppearance = appearance
        }
        
    }
}

