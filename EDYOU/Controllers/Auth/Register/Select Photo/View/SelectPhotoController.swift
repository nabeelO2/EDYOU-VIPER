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
    @IBOutlet weak var progressBar: KDCircularProgress!
    @IBOutlet weak var viewProgressBar: UIView!
    @IBOutlet weak var btnNext: TransitionButton!
    
    @IBOutlet weak var addEditProfileImageButton: UIImageView!
    
    var presenter : SelectPhotoPresenterProtocol!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
  
}

// MARK: - Actions
extension SelectPhotoController {
    @IBAction func didTapBackButton(_ sender: Any) {
        presenter.back()
        
    }
    @IBAction func didTapSkipButton(_ sender: Any) {
        presenter.navigateToHome()

    }
    @IBAction func didTapAddButton(_ sender: Any) {
        
        presenter.addPhoto()
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        presenter.addPhoto()
        
    }
}


extension SelectPhotoController : SelectPhotoViewProtocol{
    func prepareUI() {
        
    }
    
    func setImage(_ image: UIImage) {
        self.imgProfile.image = image
        self.addEditProfileImageButton.image = UIImage(named: "editProfilePhotoIcon")
    }
    
    func startAnimating() {
        self.btnNext.startAnimation()
    }
    
    func stopAnimating() {
        self.btnNext.stopAnimation()
        self.viewProgressBar.isHidden = true
    }
    func setInteraction(_ result: Bool) {
        self.view.isUserInteractionEnabled = result
    }
    func showError(_ error: String) {
        self.showErrorWith(message: error)
    }
    func updateProgress(_ progress: Double) {
        progressBar.progress = progress
    }
}
