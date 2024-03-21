    //
    //  CreateGroupController.swift
    //  EDYOU
    //
    //  Created by  Mac on 16/09/2021.
    //

import UIKit
import TransitionButton
import FirebaseCrashlytics
import Martin

class CreateGroupController: BaseController,UITextFieldDelegate, UITextViewDelegate {

        // MARK: - Outlets
    @IBOutlet weak var btnCreate: TransitionButton!
    @IBOutlet weak var imgGroupPhoto: UIImageView!
    @IBOutlet weak var selectParticipantsButton: UIButton!{
        didSet
        {
        selectParticipantsButton.layer.cornerRadius =  17.5
        selectParticipantsButton.backgroundColor = UIColor.init(hexString: "#EBF8EF")
        }
    }

    @IBOutlet weak var characterCountLabel: UILabel!

    @IBOutlet weak var descriptionCharacterCountLabel: UILabel!
    @IBOutlet weak var txtTitle: UITextField! {
        didSet {
            let placeholderText = NSAttributedString(string: "Enter name...",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "4B4D53")])
            txtTitle.setRightPaddingPoints(30)

            txtTitle.attributedPlaceholder = placeholderText
        }
    }

    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var imgCheckPublic: UIImageView!
    @IBOutlet weak var imgCheckPrivate: UIImageView!
    @IBOutlet weak var viewContainerDescription: UIView!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var lblTotalParticipants: UILabel!
    @IBOutlet weak var stackViewParticipantsImages: UIStackView!
    @IBOutlet weak var imgUserOne: UIImageView!
    @IBOutlet weak var imageUserTwo: UIImageView!
    @IBOutlet weak var imageUserThree: UIImageView!
    @IBOutlet weak var imageUserFour: UIImageView!
    @IBOutlet weak var imgUserFive: UIImageView!
    @IBOutlet weak var groupImgContainerView: UIView!


        // MARK: - Properties
    enum GroupType: String {
        case `public` = "public"
        case `private` = "private"
    }

    var groupType: GroupType = .public
    var groupPhoto: UIImage?
    var selectedFriends = [User]()


        // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        txtDescription.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        lblTotalParticipants.text = ""
        stackViewParticipantsImages.isHidden = true
        groupImgContainerView.setShadow()
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

    // MARK: Actions
extension CreateGroupController {
    @IBAction func didTapInviteParticipantsButton(_ sender: UIButton) {
        let controller = SelectFriendsController(title: "Add Participants", excluding: []) { friends in
            self.selectedFriends = friends


            if (self.selectedFriends.count > 0) {
                self.selectParticipantsButton.backgroundColor = .clear
                self.selectParticipantsButton.setTitle("", for: UIControl.State.normal)
                self.lblTotalParticipants.text = self.selectedFriends.count.description
                self.stackViewParticipantsImages.isHidden = false

                if (self.selectedFriends.count == 1) {
                    self.imgUserOne.setImage(url: self.selectedFriends[0].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserTwo.isHidden = true
                    self.imageUserThree.isHidden = true
                    self.imageUserFour.isHidden = true
                    self.imgUserFive.isHidden = true
                } else if (self.selectedFriends.count == 2) {
                    self.imgUserOne.setImage(url: self.selectedFriends[0].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserTwo.setImage(url: self.selectedFriends[1].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserThree.isHidden = true
                    self.imageUserFour.isHidden = true
                    self.imgUserFive.isHidden = true
                } else if (self.selectedFriends.count == 3) {
                    self.imgUserOne.setImage(url: self.selectedFriends[0].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserTwo.setImage(url: self.selectedFriends[1].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserThree.setImage(url: self.selectedFriends[2].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserFour.isHidden = true
                    self.imgUserFive.isHidden = true
                } else if (self.selectedFriends.count == 4) {
                    self.imgUserOne.setImage(url: self.selectedFriends[0].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserTwo.setImage(url: self.selectedFriends[1].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserThree.setImage(url: self.selectedFriends[2].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserFour.setImage(url: self.selectedFriends[3].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imgUserFive.isHidden = true
                } else if (self.selectedFriends.count >= 5) {
                    self.imgUserOne.setImage(url: self.selectedFriends[0].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserTwo.setImage(url: self.selectedFriends[1].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserThree.setImage(url: self.selectedFriends[2].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imageUserFour.setImage(url: self.selectedFriends[3].profileImage, placeholder: R.image.profile_image_dummy())
                    self.imgUserFive.setImage(url: self.selectedFriends[3].profileImage, placeholder: R.image.profile_image_dummy())
                }
            }
            else
            {
            self.selectParticipantsButton.backgroundColor = UIColor.init(hexString: "#EBF8EF")
            self.selectParticipantsButton.setTitle("Select Participants", for: UIControl.State.normal)
            self.lblTotalParticipants.text = ""
            }
        }
        if (self.selectedFriends.count > 0) {
            controller.selectedFriends = self.selectedFriends
        }
        self.present(controller, animated: true, completion: nil)
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapCreateButton(_ sender: UIButton) {
        let validated = validate()
        if validated {
            if valdiateLength() {
                createGroup()
            }
        } else {
            sender.shake()
        }
    }

    @IBAction func didTapGroupPhotoButton(_ sender: UIButton) {
        ImagePicker.shared.openGalleryWithType(from: self, mediaType: Constants.imageMediaType) {[weak self] data in
            self?.groupPhoto = data.image
            self?.imgGroupPhoto.image = data.image
        }
    }

    @IBAction func didTapPublicButton(_ sender: UIButton) {
        groupType = .public
        imgCheckPublic.image = UIImage(named: "GroupSelected")
        imgCheckPrivate.image = UIImage(named: "GroupUnSelected")
    }

    @IBAction func didTapPrivateButton(_ sender: UIButton) {
        groupType = .private
        imgCheckPublic.image = UIImage(named: "GroupUnSelected")
        imgCheckPrivate.image = UIImage(named: "GroupSelected")
    }
}

    // MARK: Utility Methods
extension CreateGroupController {
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

    // MARK: Web APIs
extension CreateGroupController {
    func createGroup() {
        let participants = selectedFriends.map { $0.userID! }
        let parameters: [String: Any] = [
            "group_name": txtTitle.text ?? "",
            "description": txtDescription.text ?? "",
            "privacy": groupType.rawValue,
            "group_members": participants
        ]

        var media = [Media]()
        if let img = groupPhoto, let m = Media(withImage: img, key: "group_icon") {
            media.append(m)
        }

        viewProgressBar.isHidden = groupPhoto == nil
        btnCreate.startAnimation()
        self.view.isUserInteractionEnabled = false

        APIManager.social.createGroup(parameters: parameters, media: media) { [weak self] progress in
            Crashlytics.crashlytics().log("Create Group Crash \(progress)")
                //self?.progressBar.progress = Double(progress)
            let prog = Double(progress)
            if prog > 0{
                self?.progressBar.progress = prog
            }
        } completion: { [weak self] response, error in
            guard let self = self else { return }
            if error == nil {
                DispatchQueue.main.async {
                    self.btnCreate.stopAnimation()
                    self.view.isUserInteractionEnabled = true
                    self.viewProgressBar.isHidden = true
                    let showMyGroups:[String: Bool] = ["shouldShowMyGroups": true]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadApiAfterGroupCreation"), object: nil, userInfo: showMyGroups)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.btnCreate.stopAnimation()
                    self.view.isUserInteractionEnabled = true
                    self.viewProgressBar.isHidden = true
                    self.showErrorWith(message: error!.message)
                }
            }
        }
    }
}

    // MARK: Textfield Delegates
extension CreateGroupController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 40
    }
}

    // MARK: - TextView Delegates
extension CreateGroupController {

    func textViewDidChange(_ textView: UITextView) {

        descriptionCharacterCountLabel.text = String(format: "%d", (150 -  (txtDescription.text?.count ?? 0)))

        if descriptionCharacterCountLabel.text == "0" {
            descriptionCharacterCountLabel.textColor = .red
        } else {
            descriptionCharacterCountLabel.textColor = UIColor.init(hexString: "C4C4C4")
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 150   // 10 Limit Value
    }
}
