//
//  AudioPlayerManager.swift
//  EDYOU
//
//  Created by Ali Pasha on 13/08/2022.
//

import Foundation
import AVFoundation
import MediaToolbox
import MediaPlayer


protocol AudioPlayerManagerDelegate: class {


    func stopTimer()
    

}
class AudioPlayerManager: NSObject, AVAudioPlayerDelegate{

    static let player = AudioPlayerManager()
    weak var delegate: AudioPlayerManagerDelegate?
    //this is global variable
    var player : AVAudioPlayer?
    var playerItem:AVPlayerItem?
    var timer: Timer?
    var isCallAlertPlaying : Bool?
    

    func initPlayer(){
        do {
//            UIApplication.shared.beginReceivingRemoteControlEvents()
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)

                print("AVAudioSession is Active")

            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
}
    func play(_ url: URL?) {
        guard  let  url1 =  url else{
            //URL shouldn't be nil
            return
        }
        if delegate != nil
        {
            delegate?.stopTimer()
        }
        do{
            player =  try AVAudioPlayer(contentsOf: url1)
            player?.volume = 1.0
            player?.rate = 1.0
            player?.delegate = self
            player?.play()
        }
        catch{
            
        }
           

        
    }
    
    func playCallAlert(_ url: URL?) {
  
        if delegate != nil
        {
            delegate?.stopTimer()
        }
            isCallAlertPlaying = true
            player =  try! AVAudioPlayer(contentsOf: url!)
            player?.volume = 1.0
            player?.numberOfLoops = -1
            player?.rate = 1.0
            player?.delegate = self
            player?.play()

        
        
    }
    
    func resume()
    {
        player?.play()
    }
    func pause()
    {
        player?.pause()
    }
    
    func stop()
    {
        isCallAlertPlaying = false
        player?.stop()
    }
    
    
    func getDuration() -> Double
    {
        return player?.duration ?? 0
    }
    
    func getCurrentTime() -> Double
    {
        return player?.currentTime ?? 0
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
            if delegate != nil
            {
                delegate?.stopTimer()
            }
       }
}
