//
//  HistoryAdapter.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2023.
//

import Foundation
import Contacts
import UIKit
import EmptyDataSet_Swift

class HistoryAdapter: NSObject {
    
    weak var tableView: UITableView!
    
    var parent: WelcomeInviteController? {
        if tableView != nil {
            return tableView.viewContainingController() as? WelcomeInviteController
        }
        return nil
        
    }
    
    var navigationController: UINavigationController? {
        let navC = parent?.tabBarController?.navigationController ?? parent?.navigationController
        return navC
    }
    var AllContacts: [CNContact] = []
    let contactStore = CNContactStore()
    var phoneNumberToContact: [[String: CNContact]] = [[:]]
    var invitedUser = [Invite]()
    
    // MARK: - Initializers
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        configure()
    }
    func configure() {
//        fetchContacts()
        tableView.register(HistoryCell.nib, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = true
        getInvitedUser()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    
    func getInvitedUser(){
        
        APIManager.social.getInvitedUser(completion: { invites, error in
            if error == nil{
                self.invitedUser = (invites?.invitedUsers ?? [])
                
                let totalUsers = invites?.maximumLimit ?? 4
                
                DispatchQueue.main.async {
//                    self.parent?.totalInvitesLbl.text = "Congratulations! You've been awarded \(totalUsers) app invitations"
                    DispatchQueue.global(qos: .background).async {
                        self.fetchContacts()
                    }
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
                
                self.AllContacts.append(contact)
            }
          
                
//                for contact in self.AllContacts {
//                    // Iterate over the phone numbers of the contact
//                    for phoneNumber in contact.phoneNumbers {
//                        // Extract the phone number value
//                        let phoneNumberValue = phoneNumber.value.stringValue
//
//                        // Check if the phone number exists in the phoneNumbers array
//                        if self.invitedUser.contains(where: { invite in
//                            invite.address!.lowercased() == phoneNumberValue.lowercased()
//                        }){
//                            print(phoneNumberValue)
//                            self.phoneNumberToContact.append([phoneNumberValue : contact])
//                        }
//
//                    }
//                }
                for user in self.invitedUser {
                    if let address = user.address, user.sourceType?.lowercased() == "sms"{
                        if  let contact = self.AllContacts.first(where: { contact in
                            contact.phoneNumbers.contains { phoneNumber in
                                phoneNumber.value.stringValue.lowercased() == address.lowercased()
                            }
                        }){
                            self.phoneNumberToContact.append([address: contact])
                        }
                    }
                }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
           
            // Process the list of contacts here
            print("Fetched \(AllContacts.count) contacts")
        } catch {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
    
}


extension HistoryAdapter : UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedUser.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as! HistoryCell
        if let contact = phoneNumberToContact.first(where: { dict in
            dict.keys.first?.lowercased() == invitedUser[indexPath.row].address
        }){
            print(contact)
            cell.setData(invite: invitedUser[indexPath.row], contact: contact.values.first)
        }
        else{
            cell.setData(invite: invitedUser[indexPath.row])
        }
        
        
        return cell
           
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //send sms
//        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell{
//            if cell.inviteLbl.text?.lowercased() == "invite"{
//                if let phoneNumber = cell.numberLbl.text{
//                    parent?.invitedBySMS(phoneNumber)
//                }
//            }
//            else if cell.inviteLbl.text?.lowercased() == "pending"{
//                if let phoneNumber = cell.numberLbl.text{
//                    parent?.currentRefferalCode = cell.getRefferalCode(phoneNumber, invitedUser)
//                    parent?.sendSMS(phoneNumber)
//                }
//            }
//            else{
//                print("invite send already")
//            }
//
//        }
    }
    func getPhoneNumbers(for contact: CNContact) -> [String] {
        var phoneNumbers = [String]()
        
        for phoneNumber in contact.phoneNumbers {
            let value = phoneNumber.value.stringValue
            phoneNumbers.append(value)
        }
        
        return phoneNumbers
    }
}


extension HistoryAdapter: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No invite send yet", attributes: [NSAttributedString.Key.font :  UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let description = "invite your friends" //NetworkMonitor.shared.isInternetAvailable ? "Add a new feeds for university friends" : "please check your internet connection"
       return NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: R.color.sub_title()!])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Invite-cuate 4")
    }
    
}
