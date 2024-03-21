//
//  HistoryCell.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2023.
//

import UIKit
import Contacts

class HistoryCell: UITableViewCell {

    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var inviteLbl : UILabel!
    @IBOutlet weak var tickImgV : UIImageView!
    @IBOutlet weak var inviteBGV : UIView!
    @IBOutlet weak var profileImgV : UIImageView!
    @IBOutlet weak var profileLbl : UILabel!
    
    var invited : Invite!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        inviteBGV.cornerRadius = inviteBGV.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(invite : Invite, contact : CNContact? = nil){
        self.invited = invite
        let status =  getStatus()
        inviteLbl.text = status
        tickImgV.isHidden = false
        
        if invited.sourceType?.lowercased() == "sms"{
            
            let name = invited.address//getCompleteName(from: contact)
            titleLbl.text = ""
            detailLbl.text = name
            
            
            if let contact = contact{
                titleLbl.text = getCompleteName(from: contact)
                profileLbl.text = getProfileName(for: contact)
                profileLbl.isHidden = false
                profileImgV.isHidden = true
            }
            else{
                
                profileLbl.isHidden = true
                profileImgV.isHidden = false
                profileImgV.image = UIImage(named: "phone")?.withRenderingMode(.alwaysTemplate)
            }
               
            
        }
        else if invited.sourceType?.lowercased() == "share"{
            
            let address = self.isValid(email: invite.address ?? " ") ? invite.address : invite.referralCode
            titleLbl.text = address
            detailLbl.text = ""
            profileLbl.isHidden = true
            profileImgV.isHidden = false
            profileImgV.image = UIImage(named: "share")?.withRenderingMode(.alwaysTemplate)
        }
        
        else {
            
            let email = invite.address
            titleLbl.text = email
            detailLbl.text = ""
            profileLbl.isHidden = true
            profileImgV.isHidden = false
            profileImgV.image = UIImage(named: "mailIcon")?.withRenderingMode(.alwaysTemplate)
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
    func getPhoneNumbers(for contact: CNContact) -> [String] {
        var phoneNumbers = [String]()
        
        for phoneNumber in contact.phoneNumbers {
            let value = phoneNumber.value.stringValue
            phoneNumbers.append(value)
        }
        
        return phoneNumbers
    }
    func isAlreadyInvited(_ email : String,
                          _ invitedUser : [Invite])->Bool{
        let found = invitedUser.contains { user in
            user.sourceType?.lowercased() == "email" && user.address?.lowercased() == email.lowercased()
        }
        return found
    }
    
    func getStatus()->String{
        
        return invited.inviteStatus ?? "Invited"
    }
    func getRefferalCode(_ number : String,
                          _ invitedUser : [Invite])->String{
        
        let user = invitedUser.first { user in
            user.sourceType?.lowercased() == "email" && user.address?.lowercased() == number.lowercased()
        }
        return user?.referralCode ?? ""
    }
    
    func isValid(email: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        let nsRange = NSRange(location: 0, length: email.count)
        let results = regex.matches(in: email, range: nsRange)
        if results.count == 0
        {
            returnValue = false
        }
        return  returnValue
    }
}
