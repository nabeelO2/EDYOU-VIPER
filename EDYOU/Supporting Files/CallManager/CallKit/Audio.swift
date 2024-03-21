

import AVFoundation
import Foundation
import WebRTC

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        if (portType == AVAudioSession.Port.headphones || portType == AVAudioSession.Port.builtInReceiver){
            return true
        }
        return false
    }
}

let audioSessionQueue = DispatchQueue(label: "audio")

extension AVAudioSession {
    
    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }

    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
    
    var bluetoothDeviceConnected: Bool {
        return !AVAudioSession.sharedInstance().availableInputs!.compactMap {
            ($0.portType == .bluetoothA2DP ||
            $0.portType == .bluetoothHFP ||
            $0.portType == .bluetoothLE) ? true : nil
        }.isEmpty
         
    }
    func setPort(_ port: AVAudioSession.PortOverride) {
//        let port = self.isHeadphonesConnected == true ? .none : port
//        do {
//            try self.setCategory(.playAndRecord, options: .duckOthers)
//            try self.setMode(.default)
//            try self.overrideOutputAudioPort(port)
//            try self.setActive(true)
//        } catch let error {
//            print("Couldn't override output audio port \(error)")
//        }
    }
    func setPlayAndRecordCategory() {
//        do {
//            let isDefaultToSpeaker = self.currentRoute.outputs.first?.portType == AVAudioSession.Port.builtInSpeaker
////            try self.setCategory(AVAudioSession.Category.playAndRecord)
//            try self.setCategory(.playAndRecord, options:  .duckOthers)
//            try self.setMode(.default)
//            try self.overrideOutputAudioPort(isDefaultToSpeaker == true ? .speaker : .none)
//            try self.setActive(true)
//        } catch {
//            print("Couldn't override output audio port")
//        }
    }
}

extension RTCAudioSession {
  
    private func rollBackToAudioSessionCategory() {
       do {
           try self.session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [AVAudioSession.CategoryOptions.allowBluetoothA2DP,AVAudioSession.CategoryOptions.duckOthers,
           AVAudioSession.CategoryOptions.allowBluetooth])
           try self.session.setActive(true)
       }catch let error {
           print(error)
       }
   }
   func setPlayAndRecordCategory() {
       
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [AVAudioSession.CategoryOptions.allowBluetoothA2DP,AVAudioSession.CategoryOptions.duckOthers,
//            AVAudioSession.CategoryOptions.allowBluetooth])
//
//            try AVAudioSession.sharedInstance().setMode(.voiceChat)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//        }catch let error {
//            print(error)
//        }
       
       audioSessionQueue.async { [weak self] in
           guard let self = self else {
               return
           }
           
           self.lockForConfiguration()
           do {
               try self.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [AVAudioSession.CategoryOptions.allowBluetoothA2DP,AVAudioSession.CategoryOptions.duckOthers,
                           AVAudioSession.CategoryOptions.allowBluetooth])
//                try self.setMode(AVAudioSession.Mode.voiceChat.rawValue)
               try self.setActive(true)
           } catch let error {
               debugPrint("Error setting AVAudioSession category: \(error)")
           }
           self.unlockForConfiguration()
       }
       
   }
   func setPort(_ port: AVAudioSession.PortOverride, isVideoChatEnabled: Bool) throws {
       
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [AVAudioSession.CategoryOptions.allowBluetoothA2DP,AVAudioSession.CategoryOptions.duckOthers,
//            AVAudioSession.CategoryOptions.allowBluetooth])
//
//            let mode = isVideoChatEnabled == true ? AVAudioSession.Mode.videoChat : AVAudioSession.Mode.voiceChat
//            try AVAudioSession.sharedInstance().setMode(mode)
//
//            if (mode == .voiceChat) {
//                try AVAudioSession.sharedInstance().overrideOutputAudioPort(port)
//            }
//
//        }catch let error {
//            print(error)
//        }
       audioSessionQueue.async { [weak self] in
           guard let self = self else {
               return
           }
           
           self.lockForConfiguration()
           do {
               try self.setCategory(AVAudioSession.Category.playAndRecord.rawValue, with: [AVAudioSession.CategoryOptions.allowBluetoothA2DP,.allowAirPlay,AVAudioSession.CategoryOptions.duckOthers,
               AVAudioSession.CategoryOptions.allowBluetooth])
               
               let mode = isVideoChatEnabled == true ? AVAudioSession.Mode.videoChat : AVAudioSession.Mode.default
               try self.setMode(mode.rawValue)

               if (mode == .default) {
                   try self.overrideOutputAudioPort(port)
               }
//                try self.setActive(true)
           } catch let error {
               debugPrint("Error setting AVAudioSession category: \(error)")
           }
           self.unlockForConfiguration()
       }
   }
}

func configureAudioSession() {
  print("Configuring audio session")
  let session = AVAudioSession.sharedInstance()
  do {
      
      try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
  
    try session.overrideOutputAudioPort(.none)
    try session.setActive(true)
  } catch (let error) {
    print("Error while configuring audio session: \(error)")
  }
    
    try? RTCAudioSession.sharedInstance().setPort(.none, isVideoChatEnabled: false)
}

func speaker(on: Bool) {
    let session = AVAudioSession.sharedInstance()
    do {
        // not sure I need this ...
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
        if on {
            // does this trigger a change to the audio route?
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } else {
            // is this how to switch back to the phone speaker?
            try session.overrideOutputAudioPort(.none)
            try session.setActive(true)
        }
    } catch {
        // Audio session change failure
        print("failed to change speaker phone")
    }
}
func startAudio() {
  print("Starting audio")
}

func stopAudio() {
  print("Stopping audio")
}
