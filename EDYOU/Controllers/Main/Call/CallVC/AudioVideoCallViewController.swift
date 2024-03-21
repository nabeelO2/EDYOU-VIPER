//
//  AudioVideoCallViewController.swift
//  EDYOU
//
//  Created by Muhammad Ali  Pasha on 7/31/22.
//

import UIKit
import LiveKit
import Martin
import AVFoundation

class AudioVideoCallViewController: BaseController, RoomDelegate {
   
    let audioQueue = DispatchQueue(label: "audio")
    // One to One Call
    
    @IBOutlet weak var onetooneVideoCallView: UIView!
    @IBOutlet weak var onetoOneAudioCallView: UIView!
    
    @IBOutlet weak var myCameraView: UIView!
    @IBOutlet weak var otherPersonCameraView: UIView!
    
    @IBOutlet weak var localParticipantProfileImage: UIImageView!
   
    
    @IBOutlet weak var remoteParticipantProfileImageView: UIImageView!
    @IBOutlet weak var remoteParticipantbgProfileImageView: UIImageView!
    
    @IBOutlet weak var groupCallView: UIView!
    @IBOutlet weak var groupCallCollectionView: UICollectionView!
    
  
    
    // Unlimited Persons Group Call
    
    @IBOutlet weak var unlimitedPersonsCallView: UIView!
    
    @IBOutlet weak var callParticipantsCollectionView: UICollectionView!
    
    
    
    
    
  
    
    @IBOutlet weak var usernamesLabel: UILabel!
    @IBOutlet weak var callTimerLabel: UILabel!
   
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
   
    
  
    
//    lazy var room = Room(delegate: self)
    var chatRoom : Conversation?
    var chatRoomID : String  = ""
    var videoView: VideoView = VideoView()
    var OthervideoView: VideoView = VideoView()
     var token : String = ""
    var isMicroPhoneEnabled : Bool = true
    var isSpeakerPhoneEnabled : Bool = false
    var isSpeakerEnabled : Bool = false
    var callType: CallType = .audio
    var remoteUserName :  String = ""
    var panGesture       = UIPanGestureRecognizer()

    var counter = 0
    var timer = Timer()
    
  
    var isCalling : Bool? = false
    var adapter: AudioVideoCallAdapter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CallManager.shared.callType = callType
      
        CallManager.shared.delegate = self
        self.adapter = AudioVideoCallAdapter(collectionView: self.groupCallCollectionView)
        if self.chatRoom == nil {
            self.chatRoom = DBChatStore.getRoomInfoFrom(jid: BareJID(chatRoomID),isRoom: chatRoomID.contains("@conference.ejabberd.edyou.io"))
        }
        self.setupUI()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            myCameraView.isUserInteractionEnabled = true
        myCameraView.addGestureRecognizer(panGesture)
    }
    
    
   //MARK: - Setup UI
    
    fileprivate func setupUI() {
        isSpeakerPhoneEnabled = callType == .video
        audioQueue.async {
            speaker(on: self.isSpeakerPhoneEnabled)
        }

        DispatchQueue.main.async { [self] in
            var call = CallManager.shared.getOngoingCall()
                // Check if user is
            if CallManager.shared.getOngoingCall().outgoing {
                if self.chatRoom is XMPPRoom {
                    onetooneVideoCallView.isHidden = true
                    onetoOneAudioCallView.isHidden = true
                    groupCallView.isHidden = false
                    self.adapter.chatRoom = self.chatRoom
                    self.adapter.collectionView.reloadData()
                } else {
                    callTimerLabel.text = "Calling"
                    let path = Bundle.main.path(forResource: "dialTune", ofType: "mp3")
                    if AudioPlayerManager.player.isCallAlertPlaying ?? false == false {
                        AudioPlayerManager.player.playCallAlert(URL(fileURLWithPath: path ?? ""))
                    }
                    if let user = Cache.shared.getOtherUser(jid: chatRoomID) {
                        usernamesLabel.text =  user.0 ?? ""
                        remoteParticipantProfileImageView.setImage(url:user.1 ?? "", placeholder: nil,intials:user.0?.intials ?? "")
                        remoteParticipantbgProfileImageView.setImage(url:user.1 ?? "", placeholder: nil,intials: user.0?.intials ?? "")
                    } else {
                        usernamesLabel.text =  CallManager.shared.getCallerName()
                        remoteParticipantbgProfileImageView.setImage(url:nil, placeholder: nil,intials: CallManager.shared.getCallerName().intials)
                        remoteParticipantProfileImageView.setImage(url:nil, placeholder: nil,intials: CallManager.shared.getCallerName().intials)
                    }
                }
            } else if let user = Cache.shared.getOtherUser(jid: chatRoom?.jid.stringValue ?? "")  {
                callTimerLabel.text = "Connecting"
                usernamesLabel.text =  CallManager.shared.getCallerName()
                remoteParticipantProfileImageView.setImage(url:user.1, placeholder:  R.image.dm_profile_holder(),intials: user.0?.intials ?? "")
                remoteParticipantbgProfileImageView.setImage(url:user.1, placeholder:  R.image.userName(),intials: user.0?.intials ?? "")

            } else {
                callTimerLabel.text = "Connecting"
                usernamesLabel.text =  CallManager.shared.getCallerName()
                remoteParticipantbgProfileImageView.setImage(url:nil, placeholder: nil,intials: CallManager.shared.getCallerName().intials)
                remoteParticipantProfileImageView.setImage(url:nil, placeholder: nil,intials: CallManager.shared.getCallerName().intials)
            }
            
            if let room = self.chatRoom as? XMPPRoom {
                onetooneVideoCallView.isHidden = true
                onetoOneAudioCallView.isHidden = true
                groupCallView.isHidden = false
                self.adapter.chatRoom = room
                self.adapter.collectionView.reloadData()
            } else {
                localParticipantProfileImage.setImage(url: Cache.shared.user?.profileImage, placeholderColor: R.color.image_placeholder())
                videoView = VideoView(frame: CGRect(x: 0, y: 0, width: self.myCameraView.frame.size.width, height:  self.myCameraView.frame.size.height))
                OthervideoView = VideoView(frame: CGRect(x: 0, y: 0, width: self.otherPersonCameraView.frame.size.width, height:  self.otherPersonCameraView.frame.size.height))

                self.myCameraView.addSubview(videoView)
                self.otherPersonCameraView.addSubview(OthervideoView)

                remoteParticipantProfileImageView.layer.cornerRadius = 40

                localParticipantProfileImage.layer.cornerRadius = 25

                if callType == .audio {
                    onetooneVideoCallView.isHidden = true
                    onetoOneAudioCallView.isHidden = false
                } else {
                    onetooneVideoCallView.isHidden = false
                    onetoOneAudioCallView.isHidden = true
                }
            }

            updateVideoButton()
        }
    }

    //MARK: - update UI after Participatns joins
    fileprivate func updateUI() {
        if chatRoom is XMPPRoom {
            self.adapter.configure()
            self.adapter.remoteParticipants = CallManager.shared.remoteParticipants
            self.adapter.collectionView.reloadData()
        }
    }
    fileprivate func updateUI(isAudio: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    
        if self.chatRoom is Chat {
            if isAudio {
                onetoOneAudioCallView.isHidden = false
                onetooneVideoCallView.isHidden = true
                self.isSpeakerPhoneEnabled = false
                audioQueue.async {
                    speaker(on: self.isSpeakerPhoneEnabled)
                }
            } else {
                onetoOneAudioCallView.isHidden = true
                onetooneVideoCallView.isHidden = false
                setupOnetoOnecallVideo()
            }
        } else {
            self.adapter.configure()
            self.adapter.remoteParticipants = CallManager.shared.remoteParticipants
            self.adapter.collectionView.reloadData()
        }
        
    }
    
    
    //MARK: -  Set video Tracks
    fileprivate func setupOnetoOnecallVideo() {
        AudioPlayerManager.player.stop()
        self.videoView.track = CallManager.shared.localVideoTrack
        self.OthervideoView.track = CallManager.shared.remoteVideoTrack
    }

    
    // Local Participant Video View Drad
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(myCameraView)
        let translation = sender.translation(in: self.view)
        myCameraView.center = CGPoint(x: myCameraView.center.x + translation.x, y: myCameraView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
  

    //MARK: - Selector Methods

    //MARK: Call Controls
    
    
    @IBAction func disconnectButtonTouched(_ sender: Any) {
        CallManager.shared.endCall { success in
            DispatchQueue.main.async {
                AudioPlayerManager.player.stop()
                self.dismiss(animated: true)
            }
        }       
    }
    @IBAction func backButtonTouched(_ sender: Any) {
        CallManager.shared.minimzedCallPopup()
        self.dismiss(animated: false)
        
    }
    
    @IBAction func showHideVideoButtonTouched(_ sender: Any) {
      
            if self.callType == .audio
        {
            self.callType = .video
            CallManager.shared.updateRoomOptions(videoEnable: false)
            self.updateUI(isAudio: true)
          
        }
        else
        {
            self.callType = .audio
            CallManager.shared.updateRoomOptions(videoEnable: true)
            self.updateUI(isAudio: false)
        }
        
        updateVideoButton()
        
        
    }
    @IBAction func chatButtonTouched(_ sender: Any) {
        CallManager.shared.minimzedCallPopup()
        self.dismiss(animated: false)
    }
    
    @IBAction func muteUnmuteSpeakerButtonTouched(_ sender: Any) {
       if isSpeakerPhoneEnabled {
            isSpeakerPhoneEnabled = false
            speakerButton.setImage(UIImage(named: "speakerButtonIcon"), for: UIControl.State.normal)
        } else {
            isSpeakerPhoneEnabled = true
            speakerButton.setImage(UIImage(named: "speakerOnIcon"), for: UIControl.State.normal)
        }
        audioQueue.async {
            speaker(on: self.isSpeakerPhoneEnabled)
        }

    }
    @IBAction func muteUnmuteMicButtonTouched(_ sender: Any) {
        
        
        if isMicroPhoneEnabled {
            isMicroPhoneEnabled = false
            CallManager.shared.iamMute(flag: true)
        }
        else
        {
            CallManager.shared.iamMute(flag: false)
            isMicroPhoneEnabled = true
        }
        
        updateMicButton()
    }
    
    
    // One to One Call
    
    
    @IBAction func fullScreenLocalParticipantButtonTouched(_ sender: Any) {
    }
    
    
    // Three Persons Group Call
    
    @IBAction func remoteParticipantOneFullScreenButtonTouched(_ sender: Any) {
    }
    
    @IBAction func localParticipantOneFullScreenButtonTouched(_ sender: Any) {
    }
    
    @IBAction func remoteParticipantTwoFullScreenButtonTouched(_ sender: Any) {
    }
    
    
    // Unlimited Persons Group Call
    

}

//MARK: -  API Calls
extension AudioVideoCallViewController {

    func disconnectCall() {
        guard let roomId = Cache.shared.user?.userID else { return }
        APIManager.social.EndCallChatRoom(roomId: roomId) { chatCall, error in
            DispatchQueue.main.async {
                if error == nil {
                    AudioPlayerManager.player.stop()
                    self.dismiss(animated: true)
                }
                else {
                    AudioPlayerManager.player.stop()
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

//MARK: - Call Manager Delegate

extension AudioVideoCallViewController: CallManagerDelegate {
    func noAnswerDisconnection() {
        AudioPlayerManager.player.stop()
        self.callTimerLabel.text = "No Answer"
        let path = Bundle.main.path(forResource: "busyTune", ofType: "mp3")
        AudioPlayerManager.player.play(URL(fileURLWithPath: path ?? ""))
        guard let roomId = self.chatRoom?.jid.stringValue else { return }
        CallManager.shared.endCall { success in
            DispatchQueue.main.async {
                AudioPlayerManager.player.stop()
                self.dismiss(animated: true)
            }
        }
    }
    
    func roomDisconnected() {
        if self.chatRoom is Chat {
            self.disconnectCall()
        } else {
            if let modirator = (chatRoom as? XMPPRoom)?.occupants.filter({$0.role == .moderator }),modirator.map({$0.jid?.bareJid}).contains(AccountManager.getAccounts().first) {
                disconnectCall()
            } else {
                CallManager.shared.connectedRoom.disconnect()
                AudioPlayerManager.player.stop()
                self.dismiss(animated: true)
            }
        }
    }

    func participantLeftCall() {
        DispatchQueue.main.async {
            if self.chatRoom is Chat {
                CallManager.shared.endCall { success in
                    AudioPlayerManager.player.stop()
                    self.dismiss(animated: true)
                }
            } else {
                self.updateUI(isAudio: false)
            }
        }
    }
    
    func updateUIForLocal(views: AudioTrack?) {
        self.updateUI(isAudio: true)
        
    }
    
    func updateUIForRemote(views: AudioTrack?) {
        self.updateUI(isAudio: true)
    }
    
    func updateTime() {
        self.callTimerLabel.text  = CallManager.shared.callTime
    }
    
    func updateUIForRemote(views: VideoTrack?) {
        self.updateUI(isAudio: false)
    }
    
    func updateUIForLocal(views: VideoTrack?) {
        DispatchQueue.main.async {
            self.updateUI(isAudio: false)
        }
    }
    
    func updateUIForRemote() {
        DispatchQueue.main.async {
            AudioPlayerManager.player.stop()
            self.updateUI()
        }
    }
}

// MARK: - Controls UI Updates
extension AudioVideoCallViewController
{
    func updateMicButton()
    {
        if isMicroPhoneEnabled
        {
            micButton.setImage(UIImage(named: "CallMicUnMuteIcon"), for: UIControl.State.normal)
        }
        else
        {
            micButton.setImage(UIImage(named: "CallMicMuteIcon"), for: UIControl.State.normal)
        }
    }
    func updateVideoButton()
    {
        if callType == .audio
        {
            videoButton.setImage(UIImage(named: "disabledVideoIcon"), for: UIControl.State.normal)
        }
        else
        {
            videoButton.setImage(UIImage(named: "enabledVideoIcon"), for: UIControl.State.normal)
        }
    }

    static func checkAudioVideoPermissions(parent:UIViewController,completion: @escaping (Bool) -> Void) {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch videoStatus {
            case .authorized:
                print("Video permission authorized")
                completion(true)
            case .denied, .restricted:
                let alert = EDPermissionDeniedPopup.buildGoToSettingsAlert(cancelBlock: {
                    completion(false)
                })
                parent.present(alert, animated: true, completion: nil)
                print("Video permission denied or restricted")
                completion(false)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        print("Video permission granted")
                        completion(true)
                    } else {
                        let alert = EDPermissionDeniedPopup.buildGoToSettingsAlert(cancelBlock: {
                            completion(false)
                        })
                        parent.present(alert, animated: true, completion: nil)
                    }
                }
            @unknown default:
                let alert = EDPermissionDeniedPopup.buildGoToSettingsAlert(cancelBlock: {
                    completion(false)
                })
                parent.present(alert, animated: true, completion: nil)
                break
        }
    }
}
