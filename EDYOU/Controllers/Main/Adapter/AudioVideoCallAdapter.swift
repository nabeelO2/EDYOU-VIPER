//
//  AudioVideoCallAdapter.swift
//  EDYOU
//
//  Created by Ali Pasha on 02/08/2022.
//

import UIKit
import SafariServices
import TagListView
import SwiftUI
import Realm
import RealmSwift
import LiveKit

class AudioVideoCallAdapter: NSObject {
    
    // MARK: - Properties
    weak var collectionView: UICollectionView!
    
    var parent: AudioVideoCallViewController? {
        return collectionView.viewContainingController() as? AudioVideoCallViewController
    }
    
    var chatRoom: Conversation?

    var remoteParticipants : [RemoteParticipant]? = []
    
    // MARK: - Initializers
    init(collectionView: UICollectionView) {
        super.init()
        
        self.collectionView = collectionView
        configure()
    }
    func configure() {
        collectionView.register(remoteParticipantGroupCollectionViewCell.nib, forCellWithReuseIdentifier: remoteParticipantGroupCollectionViewCell.identifier)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}


extension AudioVideoCallAdapter: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: remoteParticipantGroupCollectionViewCell.identifier, for: indexPath) as! remoteParticipantGroupCollectionViewCell
    if let room = chatRoom as? XMPPRoom {
        var jid = room.members?[indexPath.row]
        if let user = Cache.shared.getOtherUser(jid: jid?.stringValue ?? "") {
//            var user : User = (self.chatRoom?.membersInfo.toArray(type: User.self).object(at: indexPath.row))!
            cell.setupUI(participant: (user))
            if CallManager.shared.room.localParticipant?.identity == jid?.localPart {
                cell.updateUI(participant: CallManager.shared.room.localParticipant)
            } else {

                for participant in self.remoteParticipants! {
                    if participant.identity == jid?.localPart {
                        cell.updateUI(participant: participant)
                    } else {
                        cell.hideVideoView()
                    }
                }
            }

        }
    }

    return cell
    }
    
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return (chatRoom as? XMPPRoom)?.members?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch (chatRoom as? XMPPRoom)?.members?.count ?? 0
        {
         case 2:
            let yourWidth = collectionView.bounds.width
            let yourHeight = collectionView.bounds.height
            return CGSize(width: yourWidth, height: yourHeight/2)
        case 3:
            if indexPath.row == 2
            {
                let yourWidth = collectionView.bounds.width
                let yourHeight = collectionView.bounds.height/2
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/2
                return CGSize(width: yourWidth, height: yourHeight)
            }
          
        case 4:
            let yourWidth = collectionView.bounds.width/2
            let yourHeight = collectionView.bounds.height/2
            return CGSize(width: yourWidth, height: yourHeight)
        case 5:
            if indexPath.row == 4
            {
                let yourWidth = collectionView.bounds.width
                let yourHeight = collectionView.bounds.height/3
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3
                return CGSize(width: yourWidth, height: yourHeight)
            }
         
        case 6:
            let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3
                return CGSize(width: yourWidth, height: yourHeight)
        case 7:
            if indexPath.row == 6
            {
                let yourWidth = collectionView.bounds.width
                let yourHeight = collectionView.bounds.height/4.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
        case 8:
            if indexPath.row == 7
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/4.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
        case 9:
            if indexPath.row == 8
            {
                let yourWidth = collectionView.bounds.width/3
                let yourHeight = collectionView.bounds.height/4.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
        case 10:
            if indexPath.row == 8
            {
                let yourWidth = collectionView.bounds.width/4
                let yourHeight = collectionView.bounds.height/4.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
            else
            {
                let yourWidth = collectionView.bounds.width/2
                let yourHeight = collectionView.bounds.height/3.5
                return CGSize(width: yourWidth, height: yourHeight)
            }
        default:
                let yourWidth = collectionView.bounds.width
                let yourHeight = collectionView.bounds.height
                return CGSize(width: yourWidth, height: yourHeight )
        }
      
    }
    
   

}
