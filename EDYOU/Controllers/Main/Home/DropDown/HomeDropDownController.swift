//
//  HomeDropDownController.swift
//  EDYOU
//
//  Created by  Mac on 13/09/2021.
//

import UIKit

class HomeDropDownController: UIViewController {
    
    @IBOutlet weak var imgCheckMarkFriends: UIImageView!
    @IBOutlet weak var imgCheckMarkGroups: UIImageView!
    @IBOutlet weak var imgCheckMarkFavorites: UIImageView!
    @IBOutlet weak var imgCheckMarkTrending: UIImageView!
    @IBOutlet weak var viewDropDownContainer: UIView!
    @IBOutlet weak var viewDropDown: UIView!
    
    @IBOutlet weak var cstViewDropDownContainerTop: NSLayoutConstraint!
    @IBOutlet weak var cstViewDropDownTop: NSLayoutConstraint!
    
    var top: CGFloat = 0
    var selectedOption: PostType = .friends
    var completion: ((_ option: PostType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cstViewDropDownContainerTop.constant = top
        viewDropDownContainer.frame.origin.y = top
//        view.layoutIfNeeded()
        select(option: selectedOption)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDropDown()
    }
    init(top: CGFloat, selectedOption: PostType, completion: @escaping (_ option: PostType) -> Void) {
        super.init(nibName: HomeDropDownController.name, bundle: nil)
        
        self.selectedOption = selectedOption
        self.top = top
        self.completion = completion
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func select(option: PostType) {
        imgCheckMarkFriends.isHidden = true
        imgCheckMarkGroups.isHidden = true
        imgCheckMarkFavorites.isHidden = true
        imgCheckMarkTrending.isHidden = true
        
        switch option {
        case .friends:
            imgCheckMarkFriends.isHidden = false
            break
        case .groups:
            imgCheckMarkGroups.isHidden = false
            break
        case .favourites:
            imgCheckMarkFavorites.isHidden = false
            break
        case .trending:
            imgCheckMarkTrending.isHidden = false
            break
        case .personal:
            print("personal option not available for now")
            break
        case .event:
            print("event option not available for now")
            break
        case .all:
            print("all option not available for now")
            break
        default:
            print("other options not available for now")
        }
    }

}

extension HomeDropDownController {
    
    @IBAction func didTapDropDownFriendsButton(_ sender: Any) {
        select(option: .friends)
        completion?(.friends)
        view.layoutIfNeeded(true)
        hideDropDown(delay: 0.3)
    }
    @IBAction func didTapDropDownGroupsButton(_ sender: Any) {
        select(option: .groups)
        completion?(.groups)
        view.layoutIfNeeded(true)
        hideDropDown(delay: 0.3)
    }
    @IBAction func didTapDropDownFavoritesButton(_ sender: Any) {
        select(option: .favourites)
        completion?(.favourites)
        view.layoutIfNeeded(true)
        hideDropDown(delay: 0.3)
    }
    @IBAction func didTapDropDownTrendingButton(_ sender: Any) {
        select(option: .trending)
        completion?(.trending)
        view.layoutIfNeeded(true)
        hideDropDown(delay: 0.3)
    }
    @IBAction func didTapDropDownBgButton(_ sender: Any) {
        hideDropDown()
    }
    @IBAction func didTapDropDownNotificationSettingsButton(_ sender: Any) {
        hideDropDown()
    }
}


// MARK: - Utility Methods
extension HomeDropDownController {
    func showDropDown() {
        if viewDropDownContainer.isHidden {
            viewDropDownContainer.isHidden = false
            viewDropDownContainer.backgroundColor = UIColor.clear
            cstViewDropDownTop.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.viewDropDownContainer.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                self.view.layoutIfNeeded()
            }
        }
    }
    func hideDropDown(delay: Double = 0) {
        if viewDropDownContainer.isHidden == false {
            cstViewDropDownTop.constant = -1 * viewDropDown.frame.height
            UIView.animate(withDuration: 0.3, delay: delay) {
                self.viewDropDownContainer.backgroundColor = UIColor.clear
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}
