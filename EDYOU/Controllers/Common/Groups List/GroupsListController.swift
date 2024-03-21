//
//  UsersListController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit

class GroupsListController: BaseController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var adapter: GroupsListAdapter!
    var strTitle = ""
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = strTitle
        adapter = GroupsListAdapter(collectionView: self.collectionView)
        self.getGroups()
        
    }
    
    init(title: String, user: User?)  {
       
        super.init(nibName: GroupsListController.name, bundle: nil)
        self.strTitle = title
        self.user = user
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        goBack()
    }
    
}


extension GroupsListController {
    func getGroups() {
        
        
        APIManager.social.getGroups(userId: self.user?.userID) { [weak self] my, joined, invited, pending, error in
            guard let self = self else { return }
            
            self.adapter.isLoading = false
           
            if error == nil {
                var g = my
                g.append(contentsOf: joined)
                self.adapter.groups = g
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            self.collectionView.reloadData()
            
        }
    }
}
