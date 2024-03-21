//
//  SelectPhotoController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import TransitionButton

class SelectPhotoController: BaseController {
    
    // MARK: - Outlets
    @IBOutlet weak var imgProfile: UIImageView!
    var media: Media?
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var btnNext: TransitionButton!
    
    @IBOutlet weak var addEditProfileImageButton: UIImageView!
    
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
  
}

// MARK: - Actions
extension SelectPhotoController {
    @IBAction func didTapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapSkipButton(_ sender: Any) {
        
        Application.shared.switchToHome()
       // let controller = EducationalInfoController(university: university)
       // navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func didTapAddButton(_ sender: Any) {
        ImagePicker.shared.open(self, title: "Profile Photo", message: nil) {[weak self] data in
            guard let image = data.image , let self = self else { return }
            
            self.imgProfile.image = image
            self.media = Media(withImage: image, key: "file")
            self.addEditProfileImageButton.image = UIImage(named: "editProfilePhotoIcon")
            
            //TODO: For later use
//            DispatchQueue.main.async {
//                let controller = EditProfilePhoto(photo: "",image: self.imgProfile.image ?? UIImage())
//                controller.modalPresentationStyle = .fullScreen
//                self.present(controller, animated: true, completion: nil)
//            }
          
     
        }
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        guard let m = media else {
            self.showErrorWith(message: "Select profile photo")
            return
        }
        uploadImage(media: m)
        
    }
}




// MARK: - Web APIs
extension SelectPhotoController {
    
    func uploadImage(media: Media) {
        
        viewProgressBar.isHidden = false
        self.view.isUserInteractionEnabled = false
        btnNext.startAnimation()
        
        APIManager.fileUploader.uploadProfileImage(media: media) { [weak self] progress in
            guard let self = self else { return }
//            print("progress: \(progress)")
            let prog = Double(progress)
            if prog > 0{
                self.progressBar.progress = prog
            }
        } completion: { [weak self] response, error in
            guard let self = self else { return }
            self.btnNext.stopAnimation()
            self.view.isUserInteractionEnabled = true
            self.viewProgressBar.isHidden = true
            
            if error == nil {
                
                Application.shared.switchToHome()
               // let controller = EducationalInfoController(university: self.university)
               // self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.showErrorWith(message: error!.message)
            }
            
        }
        
    }
    
}
