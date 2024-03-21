//
// ContactBasicTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class ContactBasicTableViewCell: UITableViewCell {

    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var nameView: UILabel!
    @IBOutlet var companyView: UILabel!
    @IBOutlet var jidView: UILabel!;
    @IBOutlet var accountView: UILabel!;
    
    var account: BareJID!;
    var jid: BareJID!;
    var vcard: VCard? {
        didSet {
            var fn = vcard?.fn;
            if fn == nil {
                if let given = vcard?.givenName, let surname = vcard?.surname {
                    fn = "\(given) \(surname)";
                }
            }
            nameView.text = fn ?? jid.stringValue;
            
            let org = vcard?.organizations.first?.name;
            let role = vcard?.role;
            
            if org != nil && role != nil {
                companyView.text = "\(role!) at \(org!)";
            } else {
                companyView.text = org ?? role;
            }
            
            avatarView.image = AvatarManager.instance.avatar(for: jid, on: jid) ?? AvatarManager.instance.defaultAvatar;

            
            jidView.text = vcard?.title;
//            accountView.text = String.localizedStringWithFormat(NSLocalizedString("using %@", comment: "account info label"), account.stringValue);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.layer.masksToBounds = true;
        avatarView.layer.cornerRadius = avatarView.frame.width / 2;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
