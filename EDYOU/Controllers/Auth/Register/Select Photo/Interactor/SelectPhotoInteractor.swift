//
//  SelectPhotoInteractor.swift
//  EDYOU
//
//  Created by imac3 on 06/05/2024.
//

import Foundation

protocol SelectPhotoInteractorProtocol: AnyObject {//Input
   
    func uploadPhoto(_ media : Media)
}

protocol SelectPhotoInteractorOutput: AnyObject {
    func error(error message : String)
    func successResponse()
    func updateProgress(_ progress : Double)
}

//Handle Api integration
class SelectPhotoInteractor {
    weak var output: SelectPhotoInteractorOutput?
}

extension SelectPhotoInteractor : SelectPhotoInteractorProtocol{

    func uploadPhoto(_ media: Media) {
        
        APIManager.fileUploader.uploadProfileImage(media: media) { [weak self] progress in
            guard let self = self else { return }
            let prog = Double(progress)
            if prog > 0{
                self.output?.updateProgress(prog)
                
            }
        } completion: { [weak self] response, error in
            guard let self = self else { return }
            
            if error == nil {
                self.output?.successResponse()
                
            } else {
                self.output?.error(error: error!.message)
            }
            
        }
    }
    
}


 

