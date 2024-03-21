//
//  InviteFriendsViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 18/10/2022.
//

import UIKit
import TransitionButton
class InviteFriendViewController: BaseController {
    
    @IBOutlet weak var inviteFriendsTableView: UITableView!
    var suggestedPeople = [User]()
    @IBOutlet weak var nextButton: TransitionButton!
    @IBOutlet weak var skipButton: UIButton!
    var adapter: InviteFriendAdapter!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        adapter = InviteFriendAdapter(tableView: inviteFriendsTableView)
        nextButton.alpha = 0.5
        nextButton.isUserInteractionEnabled = false
        self.getSuggestedPeople()
        // Do any additional setup after loading the view.
    }
    
    func updateUI()
    {
        nextButton.alpha = 1.0
        nextButton.isUserInteractionEnabled = true
        skipButton.isHidden = true
    }
    
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        let controller = SelectPhotoController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
   
    
    @IBAction func skipButtonTouched(_ sender: Any) {
        let controller = SelectPhotoController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func getSuggestedPeople()
    {
        APIManager.social.suggestion(type: .peoples) { (results, error) in
            if (error == nil) {
                self.suggestedPeople = results?.people ?? []
                self.adapter.people = results?.people ?? []
                self.adapter.tableView.reloadData()
                
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}
