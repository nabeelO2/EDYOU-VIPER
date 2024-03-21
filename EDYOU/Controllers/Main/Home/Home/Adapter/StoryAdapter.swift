//
//  StoryAdapter.swift
//  EDYOU
//
//  Created by Masroor Elahi on 10/11/2022.
//

import Foundation
import UIKit

class StoryAdapater: NSObject {
    var tableView: UITableView
    var isGetStories:Bool = true
    var parent: HomeController? {
        return tableView.viewContainingController() as? HomeController
    }
    private var stories = [Story]()
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.configure()
    }
    
    func configure() {
        
//        tableView.register(StoriesCell.nib, forCellReuseIdentifier: StoriesCell.identifier)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.rowHeight = 126.5
//        tableView.estimatedRowHeight = 145
//        self.tableView.reloadData()
    }
    
    func setStories(story: [Story]) {
        self.stories = story
        DispatchQueue.main.async{
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StoriesCell {
                cell.stories = story
                cell.collectionView.reloadData()
            }
        }
    }
     func getStories()->[Story]{
        return stories
    }
}

extension StoryAdapater: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StoriesCell.identifier, for: indexPath) as! StoriesCell
        
        cell.tabPersonalProfile = {
            self.didTapAddStoryButton()
        }
       // cell.btnAdd.addTarget(self, action: #selector(didTapAddStoryButton), for: .touchUpInside)
        cell.stories = stories
        cell.parent = parent
        cell.collectionView.reloadData()
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 125
    }
    
    @objc func didTapAddStoryButton() {
        
        EDYouPicker.shared.openPicker(from: parent!, didProcessingStart: { [weak self] isCompleted,elementCount in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isGetStories = false
                self.createDummyStory(count: elementCount)
            }
            
        }){ [weak self]  mediaFiles, addText in
            guard let self = self else { return }
            if let addText = addText{
                    //add text story
                print(addText)
                self.createTextStory(addText)
            }
            else if let media = mediaFiles{
                if let mediaHX = media as? [MediaHX]{
                    self.uploadingStatusDummyStoriesTo(localAssets: mediaHX)
                    let mediaFiles = self.convertToMedia(mediaHX)
                    self.createStory(mediaFiles)
                }
            }
        }
    }
    
    
    private func convertToMedia(_ medias : [MediaHX])->[Media]{
        var mediaFiles = [Media]()
        medias.forEach { mediaHX in
            let media = Media()
            media.data = mediaHX.data
            media.filename = mediaHX.filename
            media.image = mediaHX.image
            media.key = mediaHX.key
            media.mimeType = mediaHX.mimeType
            media.videoURL = mediaHX.videoURL
            
             mediaFiles.append(media)
            
            
        }
        return mediaFiles
    }
    
    
    
    func createTextStory(_ param : [String : Any]) {
        
       
    
        parent?.view.endEditing(true)
//        parent?.view.isUserInteractionEnabled = false
//            progressBar.isHidden = false
//            self.addBlurView(top: progressBar.bottom, bottom: 0, left: 0, right: 0, style: .dark)
            
            
            
            APIManager.fileUploader.createPost(parameters: param, media: []) { [weak self] progress in
                guard let self = self else { return }
//                self.progressBar.progress = progress
            } completion: { [weak self] response, error in
                guard let self = self else { return }
                
//                self.progressBar.isHidden = true
//                self.btnDone.stopAnimation()
//                self.removeBlurView()
//                parent?.popBack(<#T##nb: Int##Int#>)
                
                parent?.getStories()//refresh stories
//                parent?.view.isUserInteractionEnabled = true
                if error == nil {
                   // parent?.dismiss(animated: true, completion: nil)
                } else {
                    parent?.showErrorWith(message: error!.message)
                }
                
            }
        
    }
    
    func uploadingStatusDummyStoriesTo(localAssets: [MediaHX] = []) {
        if let userStories = self.stories.firstIndex(where: {$0.user.userID == Cache.shared.user?.userID}) {
            var index = 0
            for storyIndex in 0..<self.stories[userStories].stories.count {
                if self.stories[userStories].stories[storyIndex].processingStatus == .processing {
                    self.stories[userStories].stories[storyIndex].processingStatus = .uploading
                    if localAssets.count > index {
                        self.stories[userStories].stories[storyIndex].localAssets = localAssets[index]
                        index += 1
                    } else {
                        self.stories[userStories].stories.remove(at: storyIndex)
                    }
                }
            }
        }
        self.setStories(story: stories)
    }
    
    func createDummyStory(count:Int) {
        var thisStory =  Post(comments: nil, totalLikes: nil, eventID: nil, groupID: nil, userID: Cache.shared.user?.userID ?? "", postID: "\(arc4random())", reactions: nil, profileImage: nil, coverPhoto: nil, profileThumbnail: nil, instituteName: nil, name: nil, postName: nil, isBackground: nil, withTags: nil, postType: nil, privacy: nil, postDeletionSettings: nil, tagFriends: nil, statusType: nil, feelings: nil, cityID: nil, city: nil, country: nil, countryCode: nil, latitude: nil, locatedIn: nil, longitude: nil, locationName: nil, region: nil, regionID: nil, state: nil, street: nil, zipCode: nil, placeID: nil, placeName: nil, overallRating: nil, postAsset: nil, postActive: nil, status: nil, user: Cache.shared.user, myReaction: nil, backgroundColors: nil, backgroundColorsPosition: nil, tagFriendsProfile: nil, updatedAt: nil, createdAt: nil, medias: [], groupInfo: nil, isFavourite: nil, school: nil)
        thisStory.processingStatus  = .processing
        thisStory.createdAt = Date().stringValue(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", timeZone: TimeZone(identifier: "UTC"))
        thisStory.updatedAt = Date().stringValue(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", timeZone: TimeZone(identifier: "UTC"))
        if let userStories = self.stories.firstIndex(where: {$0.user.userID == Cache.shared.user?.userID}) {
            self.stories[userStories].stories.insert(contentsOf: Array.init(repeating: thisStory, count: count), at: 0)
        } else {
            self.stories.insert(Story(user: Cache.shared.user!, stories: Array.init(repeating: thisStory, count: count)), at: 0)
        }
        self.setStories(story: stories)
    }
    
    func createStory(_ mediaFiles : [Media]) {
        
        self.isGetStories = true
        let parameters: [String: Any] = [
            "post_name" : "",
            "background_colors": "",
            "background_colors_position": "",
            "is_background": false,
            "post_type": "story",
            "post_deletion_settings": "a_day",
            "privacy": "friends"
        ]
            
            
        parent?.view.endEditing(true)
//        parent?.view.isUserInteractionEnabled = false
//            progressBar.isHidden = false
//            self.addBlurView(top: progressBar.bottom, bottom: 0, left: 0, right: 0, style: .dark)
//            btnDone.startAnimation()
            
            
            APIManager.fileUploader.createPost(parameters: parameters, media: mediaFiles) { [weak self] progress in
//                guard let self = self else { return }
//                self.progressBar.progress = progress
            } completion: { [weak self] response, error in
                guard let self = self else { return }
                
//                self.progressBar.isHidden = true
//                self.btnDone.stopAnimation()
//                self.removeBlurView()
//                self.popBack(2)
                parent?.getStories()//refresh stories
                
//                parent?.view.isUserInteractionEnabled = true
                if error == nil {
                  //  parent?.dismiss(animated: true, completion: nil)
                } else {
                    parent?.showErrorWith(message: error!.message)
                }
                
            }
        
    }
}

