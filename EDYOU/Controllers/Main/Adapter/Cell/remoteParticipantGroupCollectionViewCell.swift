//
//  remoteParticipantCollectionViewCell.swift
//  EDYOU
//
//  Created by Ali Pasha on 27/08/2022.
//

import UIKit
import LiveKit

class remoteParticipantGroupCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var callingLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var participantProfileImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var participantNameView: UIView!

  
    var remoteParticipant: VideoView?
    
    var isMicEnabled: Bool = false
  
    func setupUI(participant: (String?,String?)?)
    {
        remoteParticipant = VideoView(frame: CGRect(x: 0, y: 0, width: self.videoView.frame.size.width, height:  self.videoView.frame.size.height))
        remoteParticipant?.track = nil
        remoteParticipant?.layoutMode = .fill 
        remoteParticipant?.backgroundColor = UIColor.red
        self.videoView.addSubview(remoteParticipant!)
        
        callingLabel.isHidden = false
        muteButton.isHidden = true
        switchCameraButton.isHidden = true
    participantProfileImageView.setImage(url:participant?.1 ?? "", placeholderColor: R.color.image_placeholder())
        participantNameLabel.text = participant?.0 ?? ""
        self.videoView.isHidden = true
    }
    
    func updateUI(participant: RemoteParticipant?)
    {
        
        if participant?.isMicrophoneEnabled() ?? false
        {
            muteButton.isHidden = true
        }
        else
        {
            muteButton.isHidden = false
        }
      
        guard let track = participant?.videoTracks.first else {
            callingLabel.isHidden = true
            self.videoView.isHidden = true
            return
        }
        callingLabel.isHidden = true
        self.videoView.isHidden = false
       
        remoteParticipant?.layoutMode = .fill
        remoteParticipant?.layer.cornerRadius = 7
        remoteParticipant?.track = participant?.videoTracks.first?.track as? VideoTrack
        remoteParticipant?.layoutSubviews()
        remoteParticipant?.layoutIfNeeded()
        self.videoView.layoutSubviews()
        self.videoView.layoutIfNeeded(true)
        self.videoView.layoutSubviews()
        remoteParticipant?.layoutIfNeeded(true)
        
    
        

    }
    
    func updateUI(participant: LocalParticipant?)
    {
        callingLabel.isHidden = true
        if participant?.isMicrophoneEnabled() ?? false
        {
            muteButton.isHidden = true
        }
        else
        {
            muteButton.isHidden = false
        }
        guard let track = participant?.videoTracks.first else {
            self.videoView.isHidden = true
            return
        }
        self.videoView.isHidden = false
     //   let remoteParticipant: VideoView = VideoView(frame: CGRect(x: 0, y: 0, width: self.videoView.frame.size.width, height:  self.videoView.frame.size.height))
        remoteParticipant?.layer.cornerRadius = 7
       // remoteParticipant?.layoutMode = .fit
      //  self.videoView.addSubview(remoteParticipant)
        remoteParticipant?.layoutMode = .fill
        remoteParticipant?.track = participant?.videoTracks.first?.track as? VideoTrack
        remoteParticipant?.layoutSubviews()
        remoteParticipant?.layoutIfNeeded()
        self.videoView.layoutSubviews()
        self.videoView.layoutIfNeeded(true)
        self.videoView.layoutSubviews()
        remoteParticipant?.layoutIfNeeded(true)
       
    
        

    }
    func hideVideoView()
    {
        self.videoView.isHidden = true
    }
    
   
    @IBAction func switchCameraButtonTouched(_ sender: Any) {
        
    }
    
    
}
