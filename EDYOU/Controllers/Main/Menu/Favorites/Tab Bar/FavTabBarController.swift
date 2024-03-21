//
//  FavoritesTabBarController.swift
//  EDYOU
//
//  Created by  Mac on 07/10/2021.
//

import UIKit


class FavTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    func setupUI() {
        
        let home = FavFriendsController()
        home.tabBarItem = UITabBarItem(title: "Friends", image: R.image.friends_tab_icon(), selectedImage: R.image.friends_tab_icon())
        home.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        home.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        let search = FavGroupsController()
        search.tabBarItem = UITabBarItem(title: "Groups", image: R.image.groups_tab_icon(), selectedImage: R.image.groups_tab_icon())
        search.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        search.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        let newPost = FavEventsController()
        newPost.tabBarItem = UITabBarItem(title: "Events", image: R.image.events_tab_icon(), selectedImage: R.image.events_tab_icon())
        newPost.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        let chat = FavPostsController()
        chat.tabBarItem = UITabBarItem(title: "Posts", image: R.image.posts_tab_icon(), selectedImage: R.image.posts_tab_icon())
        chat.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        chat.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        self.viewControllers = [home, search, newPost, chat]
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
