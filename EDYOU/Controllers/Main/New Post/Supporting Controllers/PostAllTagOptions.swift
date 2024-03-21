//
//  PostAllTagOptions.swift
//  EDYOU
//
//  Created by Aksa on 26/08/2022.
//

import UIKit

protocol PostSelectedTagDelegate: AnyObject {
    func openSelectedTag(option: String)
}

class PostAllTagOptions: BaseController {
    weak var delegate : PostSelectedTagDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //photo
    @IBAction func myPhotosTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "photo")
        }
    }
    
    //video
    @IBAction func myVideosTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "video")
        }
    }
    
    //file
    @IBAction func documentsTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "file")
        }
    }
    
    //feeling
    @IBAction func feelingsTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "feeling")
        }
    }
    
    //place
    @IBAction func placeTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "place")
        }
    }
    //event
    @IBAction func eventsTapped(_ sender : UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openSelectedTag(option: "event")
        }
    }
    
    // dismiss self
    @IBAction func cancelTapped(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
