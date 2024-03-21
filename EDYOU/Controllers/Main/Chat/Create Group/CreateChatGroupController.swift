//
//  CreateChatGroupController.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 15/06/2022.
//

import UIKit
import TransitionButton

class CreateChatGroupController: BaseController {
    
    @IBOutlet weak var btnCreate: TransitionButton!
    @IBOutlet weak var imgGroupPhoto: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var viewRadioPublic: UIView!
    @IBOutlet weak var viewRadioPrivate: UIView!
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var imgParticipant1: UIImageView!
    @IBOutlet weak var imgParticipant2: UIImageView!
    @IBOutlet weak var imgParticipant3: UIImageView!
    @IBOutlet weak var viewMoreParticipants: UIView!
    @IBOutlet weak var lblMoreParticipants: UILabel!
    @IBOutlet weak var lblPlaceholderDescription: UILabel!
    
    
    var groupPhoto: UIImage?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
}

// MARK: - Actions
extension CreateChatGroupController {
    
    @IBAction func didTapPublicButton(_ sender: UIButton) {
        viewRadioPublic.isHidden = false
        viewRadioPrivate.isHidden = true
    }
    @IBAction func didTapPrivateButton(_ sender: UIButton) {
        viewRadioPublic.isHidden = true
        viewRadioPrivate.isHidden = false
    }
    @IBAction func didTapGroupPhotoButton(_ sender: UIButton) {
        ImagePicker.shared.openGalleryWithType(from: self, mediaType: Constants.imageMediaType) { [weak self] data in
            self?.groupPhoto = data.image
            self?.imgGroupPhoto.image = data.image
        }
    }
    @IBAction func didTapCreateButton(_ sender: UIButton) {
        if (txtTitle.text?.trimmed.count ?? 0) > 0 {
            createGroup()
        } else {
            self.showErrorWith(message: "Please enter title")
        }
    }
    
}

// MARK: - Utility Methods
extension CreateChatGroupController {
    func setData() {
        lblParticipants.text = "\(users.count)"
        imgParticipant1.setImage(url: users.object(at: 0)?.profileImage, placeholderColor: R.color.image_placeholder())
        imgParticipant2.setImage(url: users.object(at: 1)?.profileImage, placeholderColor: R.color.image_placeholder())
        imgParticipant3.setImage(url: users.object(at: 2)?.profileImage, placeholderColor: R.color.image_placeholder())
        lblMoreParticipants.text = "+\(users.count - 3)"
        viewMoreParticipants.isHidden = users.count < 3
        lblMoreParticipants.isHidden = users.count <= 3
        imgParticipant2.isHidden = users.count < 2
    }
}

// MARK: - Utility Methods
extension CreateChatGroupController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        lblPlaceholderDescription.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceholderDescription.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0
        {
        lblPlaceholderDescription.isHidden = false
        }
    }
}

// MARK: - Web APIs
extension CreateChatGroupController {
    
    func createGroup() {
        if users.count > 0 {
            viewProgressBar.isHidden = true
            btnCreate.startAnimation()
            self.view.isUserInteractionEnabled = false
            DBChatStore.instance.createXMPGroup(groupID: UUID().getCleanString, roomName: txtTitle.text ?? "", description: txtDescription.text ?? "Detail of group", groupMembers: users) { [weak self] result in
                print(result)
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.btnCreate.stopAnimation()
                    self.view.isUserInteractionEnabled = true
                    self.viewProgressBar.isHidden = true
                    switch result {
                        case .success(let room):
                            self.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: NSNotification.Name(kNotificationDidCreateChatGroup), object: nil, userInfo: ["message": ""])
                                    let chatController = UIStoryboard(name: "Groupchat", bundle: nil).instantiateViewController(withIdentifier: "MucChatViewController") as! MucChatViewController
                                    chatController.hidesBottomBarWhenPushed = true;
                                    chatController.conversation = room;
                                    if let nv = UIApplication.topViewController()?.navigationController {
                                        nv.pushViewController(chatController, animated: true)
                                    }
                            })
                        case .failure(let error):
                            self.showErrorWith(message: error.localizedDescription)
                    }
                }
            }
        } else {
            self.showErrorWith(message: "Select members")
        }
    }
}
