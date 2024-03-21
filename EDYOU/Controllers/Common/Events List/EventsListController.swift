//
//  UsersListController.swift
//  EDYOU
//
//  Created by  Mac on 04/10/2021.
//

import UIKit

class EventsListController: BaseController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var adapter: EventsAdapter!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = EventsAdapter(collectionView: collectionView, eventCategoryCollectionView: nil)
        getEvents()
    }
    
    init(user: User?)  {
        super.init(nibName: EventsListController.name, bundle: nil)
        self.user = user
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        goBack()
    }
}


// MARK: - APIs
extension EventsListController {
    func getEvents() {
        APIManager.social.getEvents(query: .me, userId: self.user?.userID) { [weak self] events, error in
            
            guard let self = self else { return }
            
            self.adapter.isLoading = false
            if error == nil {
                self.adapter.events = events ?? []
            } else {
                self.showErrorWith(message: error!.message)
            }
            
            self.adapter.eventsCollectionView.reloadData()
        }
    }
}
