//
//  OngoingCallPopup.swift
//  EDYOU
//
//  Created by Ali Pasha on 23/08/2022.
//

import Foundation
import UIKit
import LiveKit

class OngoingCallPopup: UIView, UIGestureRecognizerDelegate,RoomDelegate, CallManagerDelegate
{
    
    let audioQueue = DispatchQueue(label: "audio")
   
    @IBOutlet weak var mainBorderView: UIView!
    @IBOutlet weak var usernamesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    var chatRoom : Conversation?
    var isSpeakerPhoneEnabled : Bool = false
   
    override init(frame: CGRect) {
        
        // for using CustomView in code
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
      
        commonInit()
    }

    required init? (coder aDecoder: NSCoder) {// for using CustomView in IB
        super.init(coder: aDecoder)
        commonInit()
        setupUI()
    }
    
    func setupUI() {

      
    }
    
    private func commonInit() {
        CallManager.shared.delegate = self
        let call = CallManager.shared.getOngoingCall()
        self.chatRoom = call.chatRoom
    }
}


extension OngoingCallPopup
{
    func updateUIForLocal(views: VideoTrack?) {
        
    }
    
    func updateUIForLocal(views: AudioTrack?) {
        
    }
    
    func updateUIForRemote(views: VideoTrack?) {
        
    }
    
    func updateUIForRemote(views: AudioTrack?) {
        
    }
    
    func updateUIForRemote() {
        
    }
    
    func updateTime() {
        self.timerLabel.text  = CallManager.shared.callTime
    }
    
    func participantLeftCall() {
        
    }
    
    func roomDisconnected() {
        
    }
    
    func noAnswerDisconnection() {
       
        AudioPlayerManager.player.stop()
        self.timerLabel.text = "No Answer"
        let path = Bundle.main.path(forResource: "busyTune", ofType: "mp3")
        AudioPlayerManager.player.play(URL(fileURLWithPath: path ?? ""))
        guard let roomId = self.chatRoom?.jid.stringValue else { return }
        CallManager.shared.endCall { success in
          
            DispatchQueue.main.async {
                AudioPlayerManager.player.stop()
                CallManager.shared.removeOngoingCallPopUP()
            }
         
        }
      
    }
}
