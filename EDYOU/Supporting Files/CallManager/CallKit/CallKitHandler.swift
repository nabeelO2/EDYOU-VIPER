//
//  CallKitHandler.swift
//  EDYOU
//
//  Created by Ali Pasha on 13/09/2022.
//

import Foundation
import CallKit

class CallKitHandler: NSObject
{
    private let callController = CXCallController()
    var fullName: String = ""
    var callUUID : UUID?
    var providerDelegate: ProviderDelegate!
    var onGoingCall : EdYouCall?
    
    override init() {
        super.init()
        callUUID = UUID()
        providerDelegate = ProviderDelegate(provider: CXProvider(configuration: ProviderDelegate.providerConfiguration))
        
        
    }
    
    // MARK: - Call Kit Methods
    
    var callsChangedHandler: (() -> Void)?
  
    var calls: [EdYouCall] = []

    func callWithUUID(uuid: UUID) -> EdYouCall? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else {
        return nil
      }
      return calls[index]
    }
    
    func add(call: EdYouCall) {
        calls.append(call)
        call.stateChanged = { [weak self] in
        guard let self = self else { return }
        self.callsChangedHandler?()
      }
      callsChangedHandler?()
    }
    
    func remove(call: EdYouCall) {
        guard let index = calls.firstIndex(where: { $0 === call }) else { return }
      calls.remove(at: index)
      callsChangedHandler?()
    }
    
    func removeAllCalls() {
      calls.removeAll()
      callsChangedHandler?()
    }
    
    
    func end(call: EdYouCall,  _ onSuccess: @escaping(Any) -> Void) {
        
        if CallManager.shared.room.connectionState.isDisconnected {
            self.providerDelegate?.provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
           
        } else {
            if CallManager.shared.chatRoom is Chat {
                if CallManager.shared.chatRoom?.account.localPart == Cache.shared.user?.userID {
                    CallManager.shared.disconnectCall { success in
                        onSuccess(true)
                    }
                    let endCallAction = CXEndCallAction(call: call.uuid)
                    let transaction = CXTransaction(action: endCallAction)
                    requestTransaction(transaction)
                } else {
                    CallManager.shared.disconnectCall { success in
                        onSuccess(true)
                    }
                    self.providerDelegate?.provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
                    onSuccess(true)
                }
            } else {
                if let XroomChat  = (CallManager.shared.chatRoom as? XMPPRoom), XroomChat.occupants.first(where: {$0.role == .moderator })?.jid?.localPart == Cache.shared.user?.userID {
                    CallManager.shared.disconnectCall { success in
                    self.providerDelegate?.provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
                        onSuccess(true)
                    }
                } else {
                    CallManager.shared.connectedRoom.disconnect()
                    self.providerDelegate?.provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
                    onSuccess(true)
                }
            }
        }
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
      callController.request(transaction) { error in
        if let error = error {
          print("Error requesting transaction: \(error)")
        } else {
            print("Requested transaction successfully")
        }
      }
    }

    func setHeld(call: EdYouCall, onHold: Bool) {
      let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
      let transaction = CXTransaction()
      transaction.addAction(setHeldCallAction)
      requestTransaction(transaction)
    }
    
    func startCall(callType: CallType, token: String,handle: String) {
       // CallManager.shared.getRoom(roomId: CallManager.shared.roomID)
 
        
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: callUUID!, handle: handle)
        startCallAction.isVideo = callType == .video
       
        
      
      let transaction = CXTransaction(action: startCallAction)
      
      requestTransaction(transaction)
    }
    
    func startCall(call: EdYouCall) {
        let handle = CXHandle(type: .generic, value: call.fullName)
        let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)
        startCallAction.isVideo = call.callType == .video
        let transaction = CXTransaction(action: startCallAction)
        self.add(call: call)
        self.onGoingCall = call
        requestTransaction(transaction)
    }

    
    func displayIncomingCall(
      call: EdYouCall,
      completion: @escaping () -> Void
    ) {
      providerDelegate.reportIncomingCall(
        call: call,
        completion: completion)
    }
    
}
