//
//  ContactsAdapter.swift
//  EDYOU
//
//  Created by imac3 on 18/04/2023.
//

import Foundation
import Contacts
import UIKit
import EmptyDataSet_Swift

class ContactsAdapter: NSObject {
    
    weak var tableView: UITableView!
    
    var parent: InviteController? {
        if tableView != nil{
            return tableView.viewContainingController() as? InviteController
        }
       return nil
    }
    
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    var AllContacts: [CNContact] = []
    var contacts: [CNContact] = []
    let contactStore = CNContactStore()
    var invitedUser = [Invite]()
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
        tableView.register(ContactCell.nib, forCellReuseIdentifier: ContactCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        getContactList()
        getInvitedUser()
    }
    
    func getContactList()
    {
        contactStore.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Error requesting access to contacts: \(error.localizedDescription)")
                return
            }
            
            if granted {
                // Access to contacts granted, fetch the contact list
                DispatchQueue.global(qos: .background).async {
                    self.fetchContacts()
                }
                
            } else {
                // Access to contacts denied
                print("Access to contacts denied")
            }
        }

    }
    
    func getInvitedUser(){
        APIManager.social.getInvitedUser(completion: { invites, error in
            if error == nil{
                self.invitedUser = invites?.invitedUsers ?? []
                let totalUsers = invites?.maximumLimit ?? 4
                
                DispatchQueue.main.async {
                    self.parent?.inviteStatusLbl.text = "You have sent \(self.invitedUser.count) invites"
                    self.tableView.reloadData()
                    
                }
            }
        })
    }
    func fetchContacts() {
        let keys = [CNContactGivenNameKey,CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            
            
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                self.contacts.append(contact)
            }
            DispatchQueue.main.async {
               
                self.parent?.contacts = self.contacts
                self.AllContacts = self.contacts
                self.tableView.reloadData()
            }
            
           
            // Process the list of contacts here
            print("Fetched \(contacts.count) contacts")
        } catch {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
}


extension ContactsAdapter : UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        
        cell.setData(contact: contacts[indexPath.row], alreadyInvitedUser: invitedUser)
        
        return cell
           
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //send sms
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell{
            if cell.inviteLbl.text?.lowercased() == "invite"{
                if let phoneNumber = cell.numberLbl.text{
                    let name = cell.getFirstName()
                    parent?.invitedBySMS(phoneNumber,name)
                }
            }
            else if cell.inviteLbl.text?.lowercased() == "pending" || cell.inviteLbl.text?.lowercased() == "sent" {
                if let phoneNumber = cell.numberLbl.text{
                    parent?.currentRefferalCode = cell.getRefferalCode(phoneNumber, invitedUser)
                    let name = cell.nameLbl.text ?? ""
                    parent?.sendSMS(phoneNumber, name)
                }
            }
            else{
                print("invite send already")
                parent?.showSuccessMessage(message: "Invitation process for this user has been successfully completed and the user has signed up on EDYOU platform!")
            }
            
        }
    }
}
