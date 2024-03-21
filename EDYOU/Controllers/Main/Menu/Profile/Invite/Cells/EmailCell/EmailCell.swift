//
//  EmailCell.swift
//  EDYOU
//
//  Created by imac3 on 08/05/2023.
//

import UIKit
import Contacts

class EmailCell: UITableViewCell {

    @IBOutlet weak var emailLbl : UILabel!
    @IBOutlet weak var inviteLbl : UILabel!
    @IBOutlet weak var tickImgV : UIImageView!
    @IBOutlet weak var inviteBGV : UIView!
    @IBOutlet weak var emailImgV : UIImageView!
   
    
    var invited : Invite!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(invite : Invite){
        self.invited = invite
        let email = invite.address
        emailLbl.text = email
        
            let status =  getStatus()
            inviteLbl.text = status
            tickImgV.isHidden = false
        
        
            
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

}
