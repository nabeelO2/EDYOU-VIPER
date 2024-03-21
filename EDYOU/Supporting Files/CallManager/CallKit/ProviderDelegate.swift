/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import AVFoundation
import CallKit
import WebRTC

class ProviderDelegate: NSObject {
 
   let provider: CXProvider
  
    init(provider: CXProvider) {
 
    self.provider = provider
    
    super.init()

    provider.setDelegate(self, queue: nil)
  }
  
  static var providerConfiguration: CXProviderConfiguration = {
    let providerConfiguration = CXProviderConfiguration(localizedName: "EdYou")
      providerConfiguration.iconTemplateImageData = UIImage(named: "edyou_logo_2")?.pngData()
    providerConfiguration.supportsVideo = true
    providerConfiguration.maximumCallsPerCallGroup = 1
      providerConfiguration.supportedHandleTypes = [ .generic ]
    
    return providerConfiguration
  }()
  
    
    func reportIncomingCall(call: EdYouCall, completion: @escaping () -> Void ) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.fullName)

        update.hasVideo = call.callType == .video

        provider.reportNewIncomingCall(with: call.uuid, update: update) { error in
            print("------ Call Reported -----------\(error)")
            if error == nil {
                speaker(on: false)
                CallManager.shared.addCall(call: call)

            }
            completion()
        }
    }
}

// MARK: - CXProviderDelegate
extension ProviderDelegate: CXProviderDelegate {
  func providerDidReset(_ provider: CXProvider) {
    stopAudio()
    
      for call in  CallManager.shared.callKitHandler.calls {
      call.end()
    }
    
      CallManager.shared.callKitHandler.removeAllCalls()
  }
  
  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
      guard let call =  CallManager.shared.getCall(by:action.callUUID) else {
      action.fail()
      return
    }
    
    configureAudioSession()
   
    CallManager.shared.setOngoingCall(call: call)
    CallManager.shared.connectRoom()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          CallManager.shared.navigateToCallController()
          call.answer()
      }

   
    action.fulfill()
  }
  
  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
       startAudio()
  }


  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
      guard let call =  CallManager.shared.getCall(by: action.callUUID) else {
      action.fail()
      return
    }
    

      CallManager.shared.endOngoingCall(call: call)
      call.end()
      action.fulfill()
      
  }
    
  
  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
      guard let call =  CallManager.shared.getCall(by: action.callUUID) else {
      action.fail()
      return
    }
    
    call.state = action.isOnHold ? .held : .active
    
    if call.state == .held {
      stopAudio()
    } else {
      startAudio()
    }
    
    action.fulfill()
  }
  
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {

        let call = CallManager.shared.getCall(by: action.callUUID)

        call?.connectedStateChanged = { [weak self, weak call] in
            guard let self = self, let call = call else { return }
            if call.connectedState == .pending {
                self.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if call.connectedState == .complete {
                self.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }

        call?.start { [weak self, weak call] success in
            guard let self = self, let call = call else { return }

            if success {

                CallManager.shared.setOngoingCall(call: call)
                CallManager.shared.connectRoom()

                action.fulfill()
            } else {
                action.fail()
            }
        }
    }
}
