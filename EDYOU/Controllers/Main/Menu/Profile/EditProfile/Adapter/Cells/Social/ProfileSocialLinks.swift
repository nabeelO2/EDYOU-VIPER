//
//  ProfileSocialLinks.swift
//  EDYOU
//
//  Created by Admin on 13/06/2022.
//

import UIKit

protocol SocialLinkAction : AnyObject{
    func deleteSocialLink(indexPath: IndexPath)
    func didUpdateSocialLink(indexPath: IndexPath, value: String)
    func tapLinkOption(_ indexPath: IndexPath)
}

class ProfileSocialLinks: UITableViewCell {

    @IBOutlet weak var btnLink: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var txtSocailUserName: UITextField!
    @IBOutlet weak var btnDrag: UIButton!
    @IBOutlet weak var imgSocial: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    weak var delegate: SocialLinkAction?
    var data: PostSocialLinkData!
    var isAdding = false
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        defaultView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultView()
    }
    
    func defaultView() {
        self.selectionStyle = .none
        self.btnCancel.isHidden = true
        self.btnLink.isHidden = false
        self.txtSocailUserName.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(socialLink: PostSocialLinkData, indexPath: IndexPath ){
        imgSocial.image =  socialLink.image
        self.data = socialLink
        self.indexPath = indexPath
        self.lblName.text = socialLink.name
        
        let link = socialLink.socialHandle
        
        self.txtSocailUserName.isHidden = true
        self.btnLink.isHidden = false
        self.btnCancel.isHidden = true

        if !link.isEmpty {
            self.enableFieldView()
        }
        if self.data.enableToEdit {
            self.enableFieldView()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.txtSocailUserName.becomeFirstResponder()
            }
        }
    }
    
    private func enableFieldView() {
        self.txtSocailUserName.isHidden = false
        self.txtSocailUserName.text = self.data.socialHandle
        self.btnLink.isHidden = true
        self.btnCancel.isHidden = false
    }
    
    @IBAction func didTaplink(_ sender: UIButton) {
        self.delegate?.tapLinkOption(self.indexPath)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.delegate?.deleteSocialLink(indexPath: indexPath)
    }
//    Action Defined with textField
    @IBAction func didChangeSocialLink(_ textfield: UITextField) {
        self.delegate?.didUpdateSocialLink(indexPath: indexPath, value: textfield.text ?? "")
    }
}
