//
//  CallManager.swift
//  EDYOU
//
//  Created by Ali Pasha on 13/08/2022.
//

import Foundation
import LiveKit
import UIKit
import RealmSwift
//import Realm
import AVFoundation
import CallKit
import EventKit
import PushKit
import Martin
import Combine

protocol CallManagerDelegate: class {


    func updateUIForLocal(views: VideoTrack?)
    func updateUIForLocal(views: AudioTrack?)
    func updateUIForRemote(views: VideoTrack?)
    func updateUIForRemote(views: AudioTrack?)
    func updateUIForRemote()
    func updateTime()
    func participantLeftCall()
    func roomDisconnected()
    func noAnswerDisconnection()


}


class CallManager: NSObject, RoomDelegate {
        //TODO: Create a Call Meta Object
    static var shared = CallManager()
    weak var delegate: CallManagerDelegate?
    lazy var room = Room(delegate: self)

    var isVideoEnabled :  Bool = false
    var isMicroPhoneEnabled : Bool = true
    var isSpeakerEnabled : Bool = false

    var counter = 0
    var timer = Timer()

    var callTime : String?

    var profileImage: String = ""

    var roomID: String = ""
    var callToken = ""

    var firstname: String = ""
    var lastname: String = ""
    var fullName: String = ""
    var callType: CallType = .audio
    var callerView: OngoingCallPopup?
    var chatRoom: Conversation?
    var callData = ""
    var remoteParticipants = [RemoteParticipant]()
    var cancellable:Set<AnyCancellable> = []
    var localVideoTrack : VideoTrack?
    var remoteVideoTrack : VideoTrack?

    var localAudioTrack : AudioTrack?
    var remoteAudioTrack : AudioTrack?
    var connectedRoom: Room = Room()
    var noAnswertimer = Timer()
    var controllerPresentingDelay : Double = 0
    lazy var callKitHandler: CallKitHandler = CallKitHandler()
    override init() {
        super.init()

    }
        //MARK: - WebRTC LiveKit Connection

    func connectRoom() {

    let roomOptions = RoomOptions( adaptiveStream: true,
                                   dynacast: true,
                                   stopLocalTrackOnUnpublish: true,
                                   suspendLocalVideoTracksInBackground: false,
                                   reportStats:true
    )
    noAnswertimer.invalidate()
        //for prod : "wss://livekit.dev.edyou.io"
        //http://livekit.chat.edyou.io/
    let url: String = "wss://livekit.chat.edyou.io"
        //Constants.livekitUrl//"http://livekit.server.edyou.io"
    self.timer.invalidate()
    self.counter = 0

    room.connect(url, self.callKitHandler.onGoingCall!.callToken, roomOptions: roomOptions).then { room in
        self.connectedRoom = room
        self.connectedRoom.add(delegate: self)
        self.iamMute(flag: false)
        room.localParticipant?.setCamera(enabled: self.callKitHandler.onGoingCall!.callType == .video)
        self.noAnswertimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.noAnswerDisconnectAction), userInfo: nil, repeats: true)
    }.catch { error in }
    }


        //MARK: - Room Options
    func updateRoomOptions(videoEnable: Bool)
    {
    let _ = self.connectedRoom.localParticipant?.setCamera(enabled: videoEnable)
    }

    func iamMute(flag : Bool)    //Name Ref : Gaurdian of Galaxy - I AM GROOT
    {

    let _ = self.connectedRoom.localParticipant?.setMicrophone(enabled: !flag)



    }
    func switchCamera()
    {
        // self.connectedRoom.localParticipant.came
    }


        //MARK: Disconnect Timer
    @objc func noAnswerDisconnectAction() {

        noAnswertimer.invalidate()
        if remoteParticipants.count == 0
        {
        delegate?.noAnswerDisconnection()

        }

    }

        //MARK: Call Timer
    @objc func timerAction() {
        counter += 1

        let hours = Int(counter) / 3600
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60

        if hours < 1 {
            callTime = String(format:"%02i:%02i", minutes, seconds)
        } else {
            callTime =  String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
        if callerView != nil  { self.callerView?.timerLabel.text = callTime }
        delegate?.updateTime()

    }

}

//MARK: - Call LIVEKIT Room Delegate
extension CallManager {

    func room(_ room: Room, didConnect isReconnect: Bool) {

    }

    func room(_ room: Room, didFailToConnect error: Error) {


    }

    func room(_ room: Room, didDisconnect error: Error?) {

    }

    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {


        DispatchQueue.main.async {
            if case .disconnected = connectionState {
                self.remoteParticipants = []
                self.endCall{ success in }
                self.delegate?.roomDisconnected()

            }

        }
    }

    func room(_ room: Room, participantDidJoin participant: RemoteParticipant) {
        print("participant did join")
        self.remoteParticipants.append(participant)
        // start Timer
        DispatchQueue.main.async {

            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)

        }
       self.delegate?.updateUIForRemote()

    }

    func room(_ room: Room, participantDidLeave participant: RemoteParticipant) {
        print("participant did leave")
        self.remoteParticipants.removeAll(where: { $0.identity == participant.identity})
        self.delegate?.updateUIForRemote()
        self.delegate?.participantLeftCall()
    }

    func room(_ room: Room, didUpdate speakers: [Participant]) {

    }

    func room(_ room: Room, didUpdate metadata: String?) {

    }

    func room(_ room: Room, participant: Participant, didUpdate metadata: String?) {

    }

    func room(_ room: Room, participant: Participant, didUpdate connectionQuality: ConnectionQuality) {

    }

    func room(_ room: Room, participant: Participant, didUpdate publication: TrackPublication, muted: Bool) {

    }

    func room(_ room: Room, participant: Participant, didUpdate permissions: ParticipantPermissions) {

    }

    func room(_ room: Room, participant: RemoteParticipant, didUpdate publication: RemoteTrackPublication, streamState: StreamState) {

    }

    func room(_ room: Room, participant: RemoteParticipant, didPublish publication: RemoteTrackPublication) {



    }

    func room(_ room: Room, participant: RemoteParticipant, didUnpublish publication: RemoteTrackPublication) {

    }

    func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {

        self.remoteParticipants.append(participant)
        guard let track = track as? VideoTrack else {

            guard let audioTrack = publication.track as? AudioTrack else {

                return
            }
            DispatchQueue.main.async {
                if !(self.timer.isValid)
                {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                }
                self.remoteAudioTrack = audioTrack
                self.delegate?.updateUIForRemote(views: audioTrack)
            }
            return
        }
        DispatchQueue.main.async {
            if !(self.timer.isValid) {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            }
            self.remoteVideoTrack = track
            self.delegate?.updateUIForRemote(views: track)
        }

    }

    func room(_ room: Room, participant: RemoteParticipant, didFailToSubscribe trackSid: String, error: Error) {

    }

    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribe publication: RemoteTrackPublication, track: Track) {

    }

    func room(_ room: Room, participant: RemoteParticipant?, didReceive data: Data) {

    }

    func room(_ room: Room, localParticipant: LocalParticipant, didPublish publication: LocalTrackPublication) {


        guard let track = publication.track as? VideoTrack else {
            guard let audioTrack = publication.track as? AudioTrack else {
                return
            }
            DispatchQueue.main.async {
                self.localAudioTrack = audioTrack
                self.delegate?.updateUIForLocal(views: audioTrack)
            }
            return
        }
             DispatchQueue.main.async {

                 self.localVideoTrack = track
                 self.delegate?.updateUIForLocal(views: track)
             }
    }

    func room(_ room: Room, localParticipant: LocalParticipant, didUnpublish publication: LocalTrackPublication) {

    }

    func room(_ room: Room, participant: RemoteParticipant, didUpdate publication: RemoteTrackPublication, permission allowed: Bool) {

    }
}


//MARK: - Ongoing Call Popup
extension CallManager
{


}
//MARK: - Incoming Call Popup

extension CallManager:  UIGestureRecognizerDelegate
{
    func navigateToCallController() {
        self.controllerPresentingDelay = 0
        let controller = AudioVideoCallViewController(nibName: "VideoCall", bundle: nil)
        controller.callType = self.getOngoingCall().callType
        controller.chatRoom = self.getOngoingCall().chatRoom
        controller.chatRoomID = self.getOngoingCall().roomID
        controller.isCalling = self.getOngoingCall().outgoing
        controller.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(controller, animated: true)
    }

    func endCall(_ onSuccess: @escaping(Any) -> Void) {
        self.timer.invalidate()
        self.removeOngoingCallPopUP()
        if let onGoingCall = self.callKitHandler.onGoingCall {
            self.callKitHandler.end(call: onGoingCall) { success in }
            onSuccess(true)
        }
        onSuccess(false)
    }

    func removeOngoingCallPopUP() {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }
        
        for view in window.subviews as [UIView] where view == self.callerView {
            view.removeFromSuperview()
            break
        }
        
    }

    @objc func maximizedCallPopup(gestureRecognizer: UIPanGestureRecognizer) {
        self.removeOngoingCallPopUP()
        self.controllerPresentingDelay = 0
        let controller = AudioVideoCallViewController(nibName: "VideoCall", bundle: nil)
        controller.callType = self.getOngoingCall().callType
        controller.chatRoom = self.getOngoingCall().chatRoom
        controller.chatRoomID = self.getOngoingCall().roomID
        controller.isCalling = self.getOngoingCall().outgoing
        controller.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(controller, animated: true)
    }
    func minimzedCallPopup() {
        DispatchQueue.main.async {
            guard self != nil else {return}
            let window = UIApplication.shared.keyWindow
            self.callerView = Bundle.main.loadNibNamed("OngoingCallPopUP", owner: self, options: nil)?.first as? OngoingCallPopup
            self.callerView?.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height: 90)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn] , animations: {
                self.callerView?.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 90)
            })
            {(BOOL) in}
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.navViewDragged(gestureRecognizer:)))
            self.callerView?.addGestureRecognizer(gesture)
            self.callerView?.mainBorderView.layer.shadowColor = UIColor.black.cgColor
            self.callerView?.mainBorderView.layer.shadowOpacity = 0.2
            self.callerView?.mainBorderView.layer.shadowOffset = .zero
            self.callerView?.mainBorderView.layer.shadowRadius = 15

            self.callerView?.profileImageView.layer.cornerRadius = 20
            if self.getOngoingCall().outgoing {
                self.callerView?.timerLabel.text = "Calling"
            } else {
                self.callerView?.timerLabel.text = "Connecting"
            }
            if  let chatRoom = self.getOngoingCall().chatRoom, let callerView = self.callerView {
                callerView.profileImageView.image = R.image.profile_image_dummy()
                var url:String? = nil
                var callerName = self.getCallerName()
                if  callerName.contains("@") && !chatRoom.displayName.contains("@") {
                    callerName = chatRoom.displayName
                } else if let user  = Cache.shared.getOtherUser(jid: callerName) {
                    callerName = user.0 ?? ""
                    callerView.profileImageView.setImage(url: user.1 ?? "", placeholder: nil, intials: callerName)
                    url = user.1 ?? ""
                }

                callerView.profileImageView.setImage(url: url, placeholder: nil, intials: callerName.intials)
                callerView.usernamesLabel.text = callerName
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.maximizedCallPopup(gestureRecognizer:)))
            self.callerView?.mainBorderView.addGestureRecognizer(tapGesture)
            self.callerView?.speakerButton.addTarget(self, action: #selector(self.toggleSpeaker(sender:)), for: .touchUpInside)

            self.callerView?.rejectButton.addTarget(self, action: #selector(self.cancelCall(sender:)), for: .touchUpInside)
            gesture.delegate = self

            window?.addSubview(self.callerView!)
        }
    }

    @objc func toggleSpeaker(sender:UIButton) {
        let audioQueue = DispatchQueue(label: "audio")
        if self.callerView?.isSpeakerPhoneEnabled ?? false {
            self.callerView?.isSpeakerPhoneEnabled = false
            self.callerView?.speakerButton.setImage(UIImage(named: "speakerButtonIcon"), for: UIControl.State.normal)
        } else {
            self.callerView?.isSpeakerPhoneEnabled = true
            self.callerView?.speakerButton.setImage(UIImage(named: "speakerOnIcon"), for: UIControl.State.normal)
        }

        audioQueue.async {
            speaker(on:  self.callerView?.isSpeakerPhoneEnabled  ?? false)
        }
    }

    @objc func cancelCall(sender:UIButton) {
        removeOngoingCallPopUP()
        AudioPlayerManager.player.stop()
        self.endCall { success in

        }
    }

    func showCallPopup(data: String) {
        self.controllerPresentingDelay = 0
        noAnswertimer.invalidate()
        callData = data
        var by : NSDictionary = NSDictionary()
        var responseData :  NSDictionary = NSDictionary()
        var name : NSDictionary = NSDictionary()


            // Extract Data From Dictionary

            //TODO: Feed dictionary to Call Object and write method inside model Class

        if let dict = data.dictionary {
            responseData  = dict["data"] as? NSDictionary ?? NSDictionary()
            by = responseData["by_user"] as? NSDictionary ?? NSDictionary()
            name  = by["name"] as? NSDictionary ?? NSDictionary()
            let fullName = (name["first_name"] as! String)
            let edYouCall: EdYouCall = EdYouCall(uuid: UUID(), handle: fullName)
            edYouCall.callToken = responseData["content"] as! String

            by = responseData["by_user"] as? NSDictionary ?? NSDictionary()


            edYouCall.profileImage = by["profile_image"] as? String ?? ""
            edYouCall.fullName = fullName
            edYouCall.roomID = responseData["room_id"] as! String

           
            if let account = AccountManager.getAccounts().first,let clent =  XmppService.instance.getClient(for: account) {
                if let chat = DBChatStore.instance.chat(for: clent, with: BareJID("\(edYouCall.roomID)@ejabberd.edyou.io")) {
                    edYouCall.chatRoom = chat
                } else if let group = DBChatStore.instance.room(for: clent, with: BareJID("\(edYouCall.roomID)@ejabberd.edyou.io")) {
                    edYouCall.chatRoom = group
                } else if let channel = DBChatStore.instance.channel(for: clent, with: BareJID("\(edYouCall.roomID)@conference.ejabberd.edyou.io")) {
                    edYouCall.chatRoom = channel
                }
            }


            let callInfo = responseData["type"] as! String

            if callInfo == "video" {
                edYouCall.callType = .video
            } else {
                edYouCall.callType = .audio
            }


            DispatchQueue.main.async {
                self.noAnswertimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(self.disconnectTimerAction), userInfo: nil, repeats: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.callKitHandler.displayIncomingCall(call: edYouCall){}
                }
            }
        }
    }
    //new voip
    func showCallPopupFromVoip(data: PKPushPayload, completion: @escaping () -> Void) {
            //TODO: - Feed dictionary to Call Object and write method inside model Class
            // Extract Data From Dictionary
        let new = data.dictionaryPayload
        if let dataDict = new ["aps"] as? NSDictionary {
            let alert = dataDict["alert"] as? String ?? ""
            let custom = dataDict["custom"] as? NSDictionary ?? NSDictionary()
            let name = custom["caller_name"] as? String ??  ""
            let caller_user_id = custom["caller_user_id"] as? String ??  ""
            noAnswertimer.invalidate()
            let call: EdYouCall = EdYouCall(uuid: UUID(), handle: name)
            call.fullName = name
            call.callToken = custom["call_token"] as? String ?? ""
            let roomJID = custom["room_jis"] as? String ??  ""
            if roomJID.contains("@conference.ejabberd.edyou.io") {
                call.chatRoom = DBChatStore.getRoomInfoFrom(jid: BareJID(roomJID),isRoom: true)
                call.fullName = "\(name) in \(call.chatRoom?.displayName)"
                call.roomID = roomJID
            } else if roomJID.contains("@ejabberd.edyou.io") {
                let newRoomID =  "\(caller_user_id)@ejabberd.edyou.io"
                call.roomID = newRoomID
                call.chatRoom = DBChatStore.getRoomInfoFrom(jid: BareJID(newRoomID),isRoom: false)
            }


            let callInfo = custom["call_type"] as? String ?? ""
            if callInfo == "video" {
                call.callType = .video
            } else {
                call.callType = .audio
            }
            self.callKitHandler.displayIncomingCall(call: call, completion: completion)
            self.noAnswertimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(self.disconnectTimerAction), userInfo: nil, repeats: true)
        }
    }



    @objc func viewTapped(gestureRecognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow) else { return }
            for view in window.subviews as [UIView] where view == self.callerView {
               view.removeFromSuperview()
               break
           }
        let fullScreenCallVC = FullScreenCallPopupViewController(nibName: "FullScreenCallPopup", bundle: nil)
        fullScreenCallVC.modalPresentationStyle = .custom
        fullScreenCallVC.modalTransitionStyle = .coverVertical
        fullScreenCallVC.callData = callData
        fullScreenCallVC.token = self.callToken
        fullScreenCallVC.name = self.firstname + " " + self.lastname
        fullScreenCallVC.callType = self.callType
        fullScreenCallVC.callerImage = self.profileImage
        fullScreenCallVC.roomID = self.roomID
        var top = UIApplication.shared.keyWindow?.rootViewController
        top?.present(fullScreenCallVC, animated: false)
    }

    @objc func navViewDragged(gestureRecognizer: UIPanGestureRecognizer){
        var window = UIApplication.shared.keyWindow

        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {

            let translation = gestureRecognizer.translation(in: window)
            print(gestureRecognizer.view!.center.y)

            if( gestureRecognizer.view!.center.y < (window?.bounds.height ?? 555) - 100) {

                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)

            }else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: (window?.bounds.height ?? 555) - 100)
            }
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: window)
        }
    }

    //MARK: Disconnect Timer
    @objc func disconnectTimerAction() {
        if room.connectionState.isDisconnected {
            var call =  getOngoingCall()
            callKitHandler.end(call: call) { success in }
        }
    }
}

extension CallManager {
    func disconnectCall( _ onSuccess: @escaping(Any) -> Void) {
        guard let roomId = chatRoom?.jid else { return }
        if let topcvc = UIApplication.topViewController() as? AudioVideoCallViewController  {
            topcvc.dismiss(animated: true)
        }

    }

    func startCall(room: Conversation ,callType: CallType, token: String) {
        let roomName =  room.displayName
        let call: EdYouCall = EdYouCall(uuid: UUID(),outgoing: true, handle: roomName)
        call.chatRoom = room
        call.roomID = "\(room.jid.stringValue)"
        call.callToken = token
        call.fullName = roomName
        call.profileImage = roomName
        CallManager.shared.callKitHandler.startCall(call: call)
        navigateToCallController()
    }

}


extension CallManager {
    func getCallerName() -> String {
        return self.callKitHandler.onGoingCall?.fullName ?? ""
    }

    func getCall(by uuid: UUID) -> EdYouCall? {
        return self.callKitHandler.calls.first(where: { $0.uuid == uuid})
    }
    func addCall(call: EdYouCall) {
        self.callKitHandler.add(call: call)
    }
    func removeCall(call: EdYouCall) {
        self.callKitHandler.remove(call: call)
    }

    func endOngoingCall(call: EdYouCall) {
        self.callKitHandler.end(call: call) { success in
            self.callKitHandler.remove(call: call)
            self.endCall({_ in })
        }
    }

    func getOngoingCall() -> EdYouCall {
        return self.callKitHandler.onGoingCall ?? EdYouCall(uuid: UUID(), outgoing: false, handle: "EdYou")
    }
    
    func setOngoingCall(call: EdYouCall) {
        self.callKitHandler.onGoingCall = call
    }
}


