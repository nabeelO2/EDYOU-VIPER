//
//  ContactCell.swift
//  EDYOU
//
//  Created by imac3 on 19/04/2023.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {

    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var numberLbl : UILabel!
    @IBOutlet weak var inviteLbl : UILabel!
    @IBOutlet weak var tickImgV : UIImageView!
    @IBOutlet weak var inviteBGV : UIView!
    @IBOutlet weak var profileImgV : UIImageView!
    @IBOutlet weak var profileLbl : UILabel!
    
    var contact : CNContact!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(contact : CNContact, alreadyInvitedUser : [Invite]){
        self.contact = contact
        let name = getCompleteName(from: contact)
        nameLbl.text = name
        if getPhoneNumbers(for: contact).count > 0 {
            numberLbl.text = getPhoneNumbers(for: contact)[0]
        }
        if let imageData = contact.imageData{
            let img = UIImage(data: imageData)
          //  print(img)
            profileImgV.image = img
            profileImgV.isHidden = false
            profileLbl.isHidden = true
        }
        else{
            profileImgV.isHidden = true
            profileLbl.isHidden = false
            profileLbl.text = getProfileName(for: contact)
//            profileImgV.image = UIImage(named: "EventUser1")
        }
        if isAlreadyInvited(numberLbl.text ?? "", alreadyInvitedUser){
            let status =  getStatus(numberLbl.text ?? "", alreadyInvitedUser)
            inviteLbl.text = status
            tickImgV.isHidden = false
        }
        else{
            inviteLbl.text = "Invite"
            tickImgV.isHidden = true
        }
            
    }
    func getCompleteName(from contact: CNContact) -> String {
        let nameComponents = [contact.givenName, contact.middleName, contact.familyName]
        
        // Filter out empty name components
        let filteredNameComponents = nameComponents.filter { !$0.isEmpty }
        
        // Concatenate the filtered name components
        let completeName = filteredNameComponents.joined(separator: " ")
        
        return completeName
    }
    
    func getProfileName(for contact: CNContact) -> String {
        
        let firstNameInitial = contact.givenName.prefix(1)
        let lastNameInitial = contact.familyName.prefix(1)
        
        return String(firstNameInitial+lastNameInitial)
    }
    
    func getFirstName() -> String {
        let nameComponents = [contact.givenName]
        
        // Filter out empty name components
        let filteredNameComponents = nameComponents.filter { !$0.isEmpty }
        
        // Concatenate the filtered name components
        let completeName = (filteredNameComponents.joined(separator: " ")).trimmed
        
        return completeName
    }
    
    func getPhoneNumbers(for contact: CNContact) -> [String] {
        var phoneNumbers = [String]()
        
        for phoneNumber in contact.phoneNumbers {
            let value = phoneNumber.value.stringValue
            phoneNumbers.append(value)
        }
        
        return phoneNumbers
    }
    func isAlreadyInvited(_ number : String,
                          _ invitedUser : [Invite])->Bool{
        let found = invitedUser.contains { user in
            user.sourceType?.lowercased() == "sms" && user.address?.lowercased() == number.lowercased()
        }
        return found
    }
    
    func getStatus(_ number : String,
                          _ invitedUser : [Invite])->String{
        
        let user = invitedUser.first { user in
            user.sourceType?.lowercased() == "sms" && user.address?.lowercased() == number.lowercased()
        }
        return user?.inviteStatus ?? "Invited"
    }
    func getRefferalCode(_ number : String,
                          _ invitedUser : [Invite])->String{
        
        let user = invitedUser.first { user in
            user.sourceType?.lowercased() == "sms" && user.address?.lowercased() == number.lowercased()
        }
        return user?.referralCode ?? ""
    }

}
