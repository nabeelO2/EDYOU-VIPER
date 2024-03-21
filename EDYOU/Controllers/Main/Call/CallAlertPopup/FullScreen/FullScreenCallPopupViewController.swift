//
//  FullScreenCallPopupViewController.swift
//  EDYOU
//
//  Created by Ali Pasha on 23/08/2022.
//

import UIKit

class FullScreenCallPopupViewController: BaseController {
    @IBOutlet weak var bgProfileImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var callerNameLabel: UILabel!
    @IBOutlet weak var callTypeLabel: UILabel!
    
    var token : String = ""
    var name : String = ""
    var callerImage : String = ""
    var callerView: CallPopup?
    var callData: String = ""
    var roomID: String = ""
    var callType: CallType = .audio
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    

    func setupUI()
    {
        
        self.callerNameLabel.text = name
        self.bgProfileImageView.setImage(url:callerImage, placeholderColor: R.color.image_placeholder())
        self.profileImageView.setImage(url:callerImage, placeholderColor: R.color.image_placeholder())
        self.profileImageView.cornerRadius = 50
        
        if callType == .audio
        {
            callTypeLabel.text = "Audio Call"
        }
        else
        {
            callTypeLabel.text = "Video Call"
        }
       
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backButtonTouched(_ sender: Any) {
        CallManager.shared.showCallPopup(data: callData)
        self.dismiss(animated: false)
        
    }
    
    @IBAction func rejectCallButtonTouched(_ sender: Any) {
        
        AudioPlayerManager.player.stop()
        self.dismiss(animated: true)
    }
    
    @IBAction func chatButtonTouched(_ sender: Any) {
        
        
    }
    @IBAction func acceptCallButtonTouched(_ sender: Any) {
      
        AudioPlayerManager.player.stop()
        let callVC = AudioVideoCallViewController(nibName: "VideoCall", bundle: nil)
        callVC.modalPresentationStyle = .custom
        callVC.modalTransitionStyle = .coverVertical
        callVC.callType = callType
        callVC.chatRoomID = self.roomID
        callVC.token = CallManager.shared.callToken
        var top = UIApplication.shared.keyWindow?.rootViewController
         top?.present(callVC, animated: true)

    }
    
    
}
