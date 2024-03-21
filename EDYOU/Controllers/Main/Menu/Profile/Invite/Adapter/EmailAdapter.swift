//
//  smsAdapter.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2023.
//

import Foundation
import Contacts
import UIKit
import EmptyDataSet_Swift

class EmailAdapter: NSObject {
    
    weak var tableView: UITableView!
    
    var parent: InviteController? {
        return tableView.viewContainingController() as? InviteController
    }
    
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    
    var invitedUser = [Invite]()
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(EmailCell.nib, forCellReuseIdentifier: EmailCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        getInvitedUser()
    }
    
    
    func getInvitedUser(){
        APIManager.social.getInvitedUser(completion: { invites, error in
            if error == nil{
                self.invitedUser = (invites?.invitedUsers ?? []).filter({ obj in
                    obj.sourceType?.lowercased() == "email"
                })
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }
        })
    }
    
}


extension EmailAdapter : UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedUser.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmailCell.identifier, for: indexPath) as! EmailCell
        
        cell.setData(invite: invitedUser[indexPath.row])
        
        return cell
           
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //send sms
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell{
            if cell.inviteLbl.text?.lowercased() == "invite"{
                if let phoneNumber = cell.numberLbl.text{
                    parent?.invitedBySMS(phoneNumber)
                }
            }
            else if cell.inviteLbl.text?.lowercased() == "pending"{
                if let phoneNumber = cell.numberLbl.text{
                    parent?.currentRefferalCode = cell.getRefferalCode(phoneNumber, invitedUser)
                    
                    let name = cell.nameLbl.text ?? ""
                    parent?.sendSMS(phoneNumber, name)
                }
            }
            else{
                print("invite send already")
            }
            
        }
    }
}

