//
//  FavoriteViewController.swift
//  EDYOU
//
//  Created by Masroor Elahi on 12/12/2022.
//

import UIKit

class FavoriteViewController: BaseController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var selectedFavorite: FavoriteCategories = .post
    lazy var categoryAdapter = NotificationCategoryAdapater(collectionView: self.collectionView, delegate: self, data: FavoriteCategories.allCases, selectedCategory: self.selectedFavorite)
    lazy var favoriteAdapter = FavoriteAdapter(parent: self, tableView: self.tableView, favoriteType: selectedFavorite)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryAdapter.reloadCategories()
        self.getPosts()
        // Do any additional setup after loading the view.
    }
    @IBAction func actBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FavoriteViewController: NotificationCategoryAdapterProtocol {
    func notificationCategoryChanged(category: PropertyDescriptionProtocol) {
        self.selectedFavorite = category as! FavoriteCategories
        self.favoriteAdapter.updateDefaultType(type: self.selectedFavorite)
        
        switch self.selectedFavorite {
        case .post:
            self.getPosts()
            break
        case .events:
            self.getEvents()
            break
        case .groups:
            self.getGroups()
            break
//        case .friends:
//            break
//        case .marketplace:
//            break
        }
    }
}

extension FavoriteViewController {
    func getPosts() {
        self.favoriteAdapter.setSkeletonView(enable: true)
        APIManager.social.getFavorites(type: .posts) { [weak self] favorites, error in
            guard let self = self else { return }
            if error == nil {
                var posts = favorites?.posts ?? []
                posts.updateMediaArray()
                posts.setIsReacted()
                self.favoriteAdapter.setPosts(post: posts , totalRecords: posts.count)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getEvents() {
        self.favoriteAdapter.setSkeletonView(enable: true)
        APIManager.social.getFavorites(type: .events) { [weak self] favorites, error in
            guard let self = self else { return }
            if error == nil {
                let combinedEvents = (favorites?.events?.onlineEvents ?? []) + (favorites?.events?.inPersonEvents ?? [])
                self.favoriteAdapter.setEvents(event: combinedEvents)
            } else {
//                self.showErrorWith(message: error!.message)
            }
        }
    }
    func getGroups() {
        self.favoriteAdapter.setSkeletonView(enable: true)
        APIManager.social.getFavorites(type: .groups) { [weak self] favorites, error in
            guard let self = self else { return }
            if error == nil {
                let groups = favorites?.groups?.groups ?? []
                self.favoriteAdapter.setGroups(groups: groups)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
    
    func getFriends() {
        self.favoriteAdapter.setSkeletonView(enable: true)
        APIManager.social.getFavorites(type: .friends) { [weak self] favorites, error in
            guard let self = self else { return }
            if error == nil {
                let friends = favorites?.friends ?? []
               // self.favoriteAdapter.setGroups(groups: groups)
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}

//func getFavorites() {
//    APIManager.social.getFavorites(type: .groups) { [weak self] favorites, error in
//        guard let self = self else { return }
//
//        self.adapter.isLoading = false
//        if error == nil {
//
//            self.adapter.groups = favorites?.groups?.groups ?? []
//            if (self.txtSearch.text?.trimmed ?? "") == "" {
//                self.adapter.searchedGroups = self.adapter.groups
//            } else {
//                self.adapter.search(self.txtSearch.text ?? "")
//            }
//        } else {
//            self.showErrorWith(message: error!.message)
//        }
//        self.collectionView.reloadData()
//    }
//}
