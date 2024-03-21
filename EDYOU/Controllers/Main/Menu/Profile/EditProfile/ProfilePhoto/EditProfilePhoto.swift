//
//  EditProfilePhoto.swift
//  EDYOU
//
//  Created by Admin on 21/06/2022.
//  Copyright © 2022 O2Geeks. All rights reserved.
//

import UIKit
import TransitionButton
class EditProfilePhoto: BaseController {

    var profilePhoto:String
    var selectedPhoto : UIImage
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var cropStack: UIStackView!
    @IBOutlet weak var btnSave: TransitionButton!
    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var viewProgressBar: UIView!
    var media: Media?
    
    init(photo:String, image: UIImage){
        self.profilePhoto = photo
        self.selectedPhoto = image
        super.init(nibName: EditProfilePhoto.name, bundle: nil)
    }
    
  
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSave.isHidden = true
        camView.isHidden = true
        cropStack.isHidden = true
//        btnEdit.isHidden = true
        if profilePhoto.count > 0
        {
            imgProfile.setImage(url: profilePhoto, placeholder: R.image.dm_profile_holder()!)
        }
        else
        {
            imgProfile.image = selectedPhoto
            camView.isHidden = true
            cropStack.isHidden = true
            moreView.isHidden = true
            btnSave.isHidden = false
            btnSave.setTitle("Done", for: .normal)
        }
    }


    @IBAction func didTapBack(_ sender: Any) {
        goBack()
    }
    @IBAction func didTapCamera(_ sender: UIButton) {
        ImagePicker.shared.open(self, title: "Profile Photo", message: nil) {[weak self] data in
            guard let image = data.image else { return }
            self?.imgProfile.image = image
            self?.media = Media(withImage: image, key: "file")
        }
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        btnSave.isHidden = false
        camView.isHidden = false
        //enable when options are available
//        cropStack.isHidden = false
        btnEdit.isHidden = true
        moreView.isHidden = true
        
    }
    @IBAction func didTapMore(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: Device.isPad ? .alert : .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Remove Profile Photo", style: .destructive, handler: { _ in
            let image = R.image.dm_profile_holder()
            self.imgProfile.image = image
            self.media = Media(withImage: image!, key: "file")
            self.moreView.isHidden = true
            self.btnSave.isHidden = false

        }))
        actionSheet.addAction(UIAlertAction(title: "Save Photo", style: .default, handler: { _ in
            ImagePicker.shared.saveImage(selectedImage: self.imgProfile.image ?? UIImage() )
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    @IBAction func didTapCrop(_ sender: UIButton) {
    }
    @IBAction func didTapFilter(_ sender: UIButton) {
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        
            guard let m = media else {
                self.showErrorWith(message: "Select new profile photo")
                return
            }
            uploadImage(media: m)
       
    }
 
//    func uploadCoverImage(media: Media, animateButton: Bool = true) {
//
//        viewCoverProgressBar.isHidden = false
//        self.view.isUserInteractionEnabled = false
//
//        if animateButton {
//            btnSave.startAnimation()
//        }
//
//
//        APIManager.fileUploader.uploadCoverImage(media: media) { [weak self] progress in
//            guard let self = self else { return }
//            self.view.isUserInteractionEnabled = true
//            print("progress: \(progress)")
//            self.coverProgressBar.progress = Double(progress)
//        } completion: { [weak self] response, error in
//            guard let self = self else { return }
//
//            self.viewCoverProgressBar.isHidden = true
//
//            if error != nil {
//                self.btnSave.stopAnimation()
//                self.showErrorWith(message: error!.message)
//            } else {
//
//                self.updateInfo(animateButton: false)
//
//            }
//
//        }
//    }
}
// MARK: - Web APIs
extension EditProfilePhoto {
    
    func uploadImage(media: Media) {
        
        viewProgressBar.isHidden = false
        self.view.isUserInteractionEnabled = false
        btnSave.startAnimation()
        
        APIManager.fileUploader.uploadProfileImage(media: media) { [weak self] progress in
            guard let self = self else { return }
            print("progress: \(progress)")
            let prog = Double(progress)
            if prog > 0{
                self.progressBar.progress = prog
            }
        } completion: { [weak self] response, error in
            guard let self = self else { return }
            self.btnSave.stopAnimation()
            self.view.isUserInteractionEnabled = true
            self.viewProgressBar.isHidden = true
            
            if error == nil {
                
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
        
    }
    
}
