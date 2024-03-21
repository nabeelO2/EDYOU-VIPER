//
//  UploadPostCell.swift
//  EDYOU
//
//  Created by imac3 on 20/02/2024.
//

import UIKit

class UploadPostCell: UITableViewCell {

    @IBOutlet weak var thumbnailImgV : UIImageView!
    @IBOutlet weak var progressV : UIProgressView!
    @IBOutlet weak var progressLbl : UILabel!
    @IBOutlet weak var crossBtn : UIButton!
    @IBOutlet weak var reloadBtn : UIButton!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func createPost(_ parameters : [String : Any], _ attachments : [Media], completion: @escaping (_ reloadData: Bool?) -> Void){
//        if let media = attachments.first{
//            if let data = media.data{//image
//                thumbnailImgV.image = UIImage(data: data)
//            }
//            else{
//                thumbnailImgV.image = nil
//            }
//            
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            
//            APIManager.fileUploader.createPost(parameters: parameters, media: attachments) { progress in
//                print("progress : \(progress)")
//                self.progressV.progress = progress
//            } completion: { response, error in
//                print("progress : 100%")
//                if error == nil {
//                    self.progressLbl.text = "Done"
//                    self.removeFileFromDirectory(filename: "pendingPost.json")
//                    UserDefaults.standard.setValue(nil, forKey: "pendingPostParam")
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                        completion(true)
//                    }
//                    
//                }else{
//                    self.progressLbl.text = "Something went wrong"
//                    self.crossBtn.isHidden = false
//                    self.reloadBtn.isHidden = false
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                        completion(false)
//                    }
//                }
//                
//            }
//        }
////        APIManager.fileUploader.createPost(parameters: parameters, media: attachments) { [weak self] progress in
//////            guard let self = self else { return }
////            print("progress : \(progress)")
//////            self.progressBar.progress = progress
////        } completion: { [weak self] response, error in
//////            guard let self = self else { return }
////            print("progress : 100%")
//////            self.progressBar.isHidden = true
//////            self.btnPost.stopAnimation()
//////            self.removeBlurView()
////
//////            self.view.isUserInteractionEnabled = true
//////            if error == nil {
//////                self.dismiss(animated: true, completion: nil)
//////                self.resetCreatePostView()
//////
//////                self.tabBarController?.selectedIndex = 0
//////            } else {
//////                self.showErrorWith(message: error!.message)
//////            }
////        }
//    }
    

}
