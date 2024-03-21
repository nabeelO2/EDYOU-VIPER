//
//  MainTabBarController.swift
//  EDYOU
//
//  Created by  Mac on 07/09/2021.
//

import UIKit
import SwiftMessages
import PanModal

protocol TabbarControllerProtocol{
    func tabbarDidSelect()
}

class MainTabBarController: UITabBarController {

    var selectedTabbarIndex  = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getUserDetails()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

    }
    
    func setupUI() {
        let home = HomeController()
        let homeNavigationController = UINavigationController(rootViewController: home)
        homeNavigationController.hidesBottomBarWhenPushed = false
        homeNavigationController.setNavigationBarHidden(true, animated: false)
        
        let imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        let textAdjustment = UIOffset(horizontal: 0, vertical: 4)
        
        home.tabBarItem = UITabBarItem(title: "", image: R.image.tab_home_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_home_selected_icon()!.withRenderingMode(.alwaysOriginal))
        home.tabBarItem.imageInsets = imageInsets
        home.tabBarItem.titlePositionAdjustment = textAdjustment
        
        let search = SearchDetailsController()
        search.tabBarItem = UITabBarItem(title: "", image: R.image.tab_search_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_search_selected_icon()!.withRenderingMode(.alwaysOriginal))
        search.tabBarItem.imageInsets = imageInsets
        search.tabBarItem.titlePositionAdjustment = textAdjustment
        
//        let newEdyouPost = CreateNewController(delegate: self)
//        newEdyouPost.tabBarItem = UITabBarItem(title: nil, image: R.image.tab_edyou_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_edyou_icon()!.withRenderingMode(.alwaysOriginal))
//        newEdyouPost.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        let edyouPost =  NewPostController()
        edyouPost.tabBarItem = UITabBarItem(title: nil, image: R.image.tab_edyou_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_edyou_icon()!.withRenderingMode(.alwaysOriginal))
        edyouPost.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

        let chat = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatsListViewController") as! ChatsListViewController
        chat.tabBarItem = UITabBarItem(title: "", image: R.image.tab_chat_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_chat_selected_icon()!.withRenderingMode(.alwaysOriginal))
        chat.tabBarItem.imageInsets = imageInsets
        chat.tabBarItem.titlePositionAdjustment = textAdjustment
        let menu = MenuController()
        let menuNavigationController = UINavigationController(rootViewController: menu)

        menuNavigationController.hidesBottomBarWhenPushed = false
        menuNavigationController.setNavigationBarHidden(true, animated: false)

        menu.tabBarItem = UITabBarItem(title: "", image: R.image.tab_menu_icon()!.withRenderingMode(.alwaysOriginal), selectedImage: R.image.tab_menu_selected_icon()!.withRenderingMode(.alwaysOriginal))
        menu.tabBarItem.imageInsets = imageInsets
        menu.tabBarItem.titlePositionAdjustment = textAdjustment
//
        self.viewControllers = [homeNavigationController, search, edyouPost, chat,  menuNavigationController]
        tabBar.tintColor = R.color.navigationColor()
        tabBar.isTranslucent = false
        tabBar.barTintColor = R.color.navigationColor()
        
        if #available(iOS 13, *) {
            let appearance = tabBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            tabBar.standardAppearance = appearance
            tabBar.backgroundColor = R.color.navigationColor()
        }
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        lineView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
        self.tabBar.addSubview(lineView)
        self.delegate = self
    }
    
    func getUserDetails() {
        APIManager.social.getUserInfo { [weak self] user, error in
            guard let self = self else { return }

            if AccountManager.getActiveAccounts().first == nil ,let id = user?.userID, let pass  = Keychain.shared.accessToken {
                XMPPAppDelegateManager.shared.loginToExistingAccount(id: "\(id)@ejabberd.edyou.io" , pass: pass)
            }
            APIManager.social.getFriends(userId: Cache.shared.user?.userID,completion: {_,_  in })
            if let e = error {
                self.showErrorWith(message: e.message)
                
            }
            
        }
    }
    
    
    func showErrorWith(message: String){

        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 6)
        let error = MessageView.viewFromNib(layout: .messageView)
        error.configureTheme(.error)
        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }
    
    func showSuccessMessage(message: String){
        
        SwiftMessages.hide()
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 2)
        let error = MessageView.viewFromNib(layout: .messageView)
        error.configureTheme(.success)
        error.configureContent(title: "", body: message)
        error.button?.isHidden = true
        SwiftMessages.show(config: config, view: error)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is CreateNewController {
            let controller = CreateNewController(delegate: self)
            self.presentPanModal(controller)
            return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let controller = viewController  as? TabbarControllerProtocol else{
            return
        }
        controller.tabbarDidSelect()
        
        guard self.selectedIndex == selectedTabbarIndex else{
            selectedTabbarIndex = self.selectedIndex
            return
        }
      
    }
}

extension MainTabBarController: CreateNewOptionsProtocol {
    func createPost() {
        let controller = NewPostController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    func createStory() {
        let controller = AddStoryController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    func createReels() {
        self.selectedIndex = 0
        let controller = ReelsViewController()
        guard let navigationController = self.viewControllers?.first as? UINavigationController  else {
            return
        }
        navigationController.pushViewController(controller, animated: true)
    }
}
