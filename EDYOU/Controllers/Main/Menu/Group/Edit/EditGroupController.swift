//
//  EditGroupController.swift
//  EDYOU
//
//  Created by  Mac on 21/09/2021.
//

import UIKit
import TransitionButton



class EditGroupController: BaseController {
    
//    @IBOutlet weak var lblBio: UILabel!
//    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
//    @IBOutlet weak var lblEditBio: UILabel!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var imgGroupPhoto: UIImageView!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var progressBar: KDCircularProgress!
    
    @IBOutlet weak var txtTitle: UITextField! {
        didSet {
            let placeholderText = NSAttributedString(string: "Enter name...",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "4B4D53")])
            txtTitle.setRightPaddingPoints(30)
            
            txtTitle.attributedPlaceholder = placeholderText
        }
    }
    
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var descriptionCharacterCountLabel: UILabel!
    @IBOutlet weak var viewContainerDescription: UIView!
    
    var isInfoUpdated = false
    var groupPhoto: UIImage?
    var group: Group
    var isAdmin: Bool {
        let i = group.groupAdmins?.contains(where: { $0.userID == Cache.shared.user?.userID })
        return i ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    init(group: Group) {
        self.group = group
        super.init(nibName: EditGroupController.name, bundle: nil)
        
    }
    required init?(coder: NSCoder) {
        self.group = Group()
        super.init(coder: coder)
    }
    
    @IBAction func nameTextfieldEditingChanged(_ sender: Any) {
        characterCountLabel.text = String(format: "%d", (40 -  (txtTitle.text?.count ?? 0)))
        
        if characterCountLabel.text == "0"
        {
           
            characterCountLabel.textColor = .red
        }
        else
        {
          
            characterCountLabel.textColor = UIColor.init(hexString: "C4C4C4")
        }
    }
    
}
extension EditGroupController {
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        if isInfoUpdated {
            let alert = UIAlertController(title: nil, message: "Do you want to save changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                self.updateInfo()
            }))
            alert.addAction(UIAlertAction(title: "Discard", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        updateInfo()
    }
    @IBAction func didTapGroupPhotoButton(_ sender: UIButton) {
        if isAdmin {
            ImagePicker.shared.openGalleryWithType(from: self, mediaType: Constants.imageMediaType) { [weak self] data in
                self?.isInfoUpdated = true
                self?.groupPhoto = data.image
                self?.imgGroupPhoto.image = data.image
            }
        }
    }
    @IBAction func didTapNameButton(_ sender: UIButton) {
        if isAdmin {
            let controller = TextInputController(title: "Name", currentText: txtTitle.text ?? "", required: true, multiline: false) { [weak self] text in
                self?.isInfoUpdated = true
//                self?.lblName.text = text
                
                self?.txtTitle.text = text
                self?.nameTextfieldEditingChanged(self?.txtTitle!)
                self?.view.layoutIfNeeded()
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func didTapPrivacyButton(_ sender: UIButton) {
        if isAdmin {
            let actionSheet = UIAlertController(title: "Privacy", message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
            let publicAction = UIAlertAction(title: "Public", style: .default) { _ in
                self.isInfoUpdated = true
                self.lblPrivacy.text = "Public"
            }
            let privateAction = UIAlertAction(title: "Private", style: .default) { _ in
                self.isInfoUpdated = true
                self.lblPrivacy.text = "Private"
            }
            actionSheet.addAction(publicAction)
            actionSheet.addAction(privateAction)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
        
    }
   
    @IBAction func didTapBioButton(_ sender: UIButton) {
        if isAdmin {
            let controller = TextInputController(title: "Bio", currentText: txtDescription.text ?? "", required: true, multiline: true) { [weak self] text in
                self?.isInfoUpdated = true
                self?.txtDescription.text = text
                self?.textViewDidChange((self?.txtDescription)!)
                self?.view.layoutIfNeeded(true)
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Utility Methods
extension EditGroupController {
    func setupUI() {
        if let g = group.groupIcon {
            imgGroupPhoto.setImage(url: g, placeholderColor: R.color.image_placeholder())
        }
        txtDescription.delegate = self
        txtTitle.text = group.groupName
        txtDescription.text = group.groupDescription
        nameTextfieldEditingChanged(txtTitle!)
        textViewDidChange(txtDescription)
        
//        lblName.text = group.groupName
//        lblBio.text = group.groupDescription
        btnSave.isHidden = !isAdmin
        lblPrivacy.text = group.privacy?.capitalized
//        lblEditBio.isHidden = !isAdmin
    }
}

// MARK: - Web APIs
extension EditGroupController {
    func updateInfo() {
        
        guard let id = group.groupID else { return }
        
        let parameters: [String: Any] = [
            "group_name": txtTitle.text ?? "",
            "description": txtDescription.text ?? "",
            "privacy": lblPrivacy.text?.lowercased() ?? ""
        ]
        
        var media = [Media]()
        if let img = groupPhoto, let m = Media(withImage: img, key: "group_icon") {
            media.append(m)
        }
        
        viewProgressBar.isHidden = groupPhoto == nil
        btnSave.startAnimation()
        self.view.isUserInteractionEnabled = false
        
        APIManager.social.editGroup(groupId: id, parameters: parameters, media: media) {  [weak self] progress in
            let prog = Double(progress)
            if prog > 0{
                self?.progressBar.progress = prog
            }
        } completion: { [weak self] error in
            guard let self = self else { return }
            
            self.btnSave.stopAnimation()
            self.view.isUserInteractionEnabled = true
            self.viewProgressBar.isHidden = true
            
            if error == nil {
                self.isInfoUpdated = false
                self.showSuccessMessage(message: "You changes are saved")
            } else {
                self.showErrorWith(message: error!.message)
            }
        }
    }
}


extension EditGroupController : UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        
        descriptionCharacterCountLabel.text = String(format: "%d", (150 -  (txtDescription.text?.count ?? 0)))
        
        if descriptionCharacterCountLabel.text == "0"
        {
            descriptionCharacterCountLabel.textColor = .red
        }
        else
        {
            descriptionCharacterCountLabel.textColor = UIColor.init(hexString: "C4C4C4")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 150   // 10 Limit Value
    }
}


// MARK: - Utility Methods
extension EditGroupController {
    func validate() -> Bool {
        var status = true
        if (txtTitle.text?.trimmed ?? "") == "" {
            txtTitle.borderColor = .red
            txtTitle.borderWidth = 1
            txtTitle.cornerRadius = 4
            status = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.txtTitle.borderColor = UIColor.init(hexString: "C4C4C4")
            }
        }
        
        if (txtDescription.text?.trimmed ?? "") == "" {
            viewContainerDescription.borderColor = .red
            viewContainerDescription.borderWidth = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewContainerDescription.borderColor = UIColor.init(hexString: "C4C4C4")
                self.viewContainerDescription.borderWidth = 1
            }
            
            status = false
        }
        
        return status
    }
    func valdiateLength() -> Bool
    {
        if txtTitle.text?.count ?? 0 > 40 {
            self.showErrorWith(message: "Title should not be more than 40 characters")
            return false
        } else if txtDescription.text.count > 150 {
            self.showErrorWith(message: "Description should not be more than 150 characters")
            return false
        } else {
            return true
        }
    }
}


// MARK: - Textfield Delegates
extension EditGroupController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 40
    }
}
