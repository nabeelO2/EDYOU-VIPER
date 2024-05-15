//
//  SelectPhotoPresenter.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//

import Foundation
import UIKit

protocol SelectPhotoPresenterProtocol: AnyObject {//Input
    func viewDidLoad()
    func setupUI()
    func navigateToHome()
    func back()
    func addPhoto()
    func uploadPhoto()
}

class SelectPhotoPresenter {
    weak var view: SelectPhotoViewProtocol?
    private let interactor: SelectPhotoInteractorProtocol
    private let router: SelectPhotoRouter
    private var media : Media?
    
    init(view: SelectPhotoViewProtocol, router: SelectPhotoRouter, interactor : SelectPhotoInteractorProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}


extension SelectPhotoPresenter: SelectPhotoPresenterProtocol {
        
    func setupUI() {
        
    }
    
    
    func viewDidLoad() {
        view?.prepareUI()
    }
    
    func navigateToHome(){
        router.navigateToHomeVC()
    }
    func back() {
        router.back()
    }
    func addPhoto() {
        if let view = view, ((view as? UIViewController) != nil){
            ImagePicker.shared.open(view as! UIViewController, title: "Profile Photo", message: nil) {[weak self] data in
                guard let image = data.image , let self = self else { return }
                view.setImage(image)
            }
        }
        else{
            print("add picker")
        }
    }
    func uploadPhoto() {
        guard let m = media else {
            view?.showError("Select profile photo")
            return
        }
        view?.setInteraction(false)
        view?.startAnimating()
        interactor.uploadPhoto(m)
    }
    
}

extension SelectPhotoPresenter : SelectPhotoInteractorOutput{
    
    
    func error(error message: String) {
        view?.stopAnimating()
        view?.setInteraction(true)
        view?.showError(message)
    }
    
    func successResponse() {
        
        //get user detail
        view?.stopAnimating()
        view?.setInteraction(true)
        router.navigateToHomeVC()
        
    }
    func updateProgress(_ progress: Double) {
        view?.updateProgress(progress)
    }
    

}


protocol SelectPhotoViewProtocol: AnyObject {//Output
    func prepareUI()
    func setImage(_ image : UIImage)
    func showError(_ error : String)
    func stopAnimating()
    func startAnimating()
    func setInteraction(_ result : Bool)
    func updateProgress(_ progress: Double)
}




